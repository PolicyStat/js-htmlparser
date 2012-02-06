regex =
    interesting_normal: /[&<]/
    incomplete: /&[a-zA-Z#]/
    entityref: ///
        &
        (
            [a-zA-Z]
            [-.a-zA-Z0-9]*
        )
        [^a-zA-Z0-9]
    ///
    charref: /&#(?:[0-9]+|[xX][0-9a-fA-F]+)[^0-9a-fA-F]/
    starttagopen: /<[a-zA-Z]/
    piclose: />/
    tagfind: /[a-zA-Z][-.a-zA-Z0-9:_]*/
    # Javascript does not support positive lookbehind assertion, so we have
    # attempted to mimick it here
    attrfind: ///
        \s*
        ['"\s]
        (
            [^\s/>]
            [^\s/=>]*
        )
        (
            \s*
            =+
            \s*                 # value indicator
            (
                '
                [^\']*
                ' | "
                [^"]*
                " |
                (?
                    !['"]
                )
                [^>\s]*
            )
        )?
    ///
    # Javascript does not support positive lookbehind assertion, so we have
    # attempted to mimick it here
    locatestarttagend: ///
        <
        [a-zA-Z]
        [-.a-zA-Z0-9:_]*        # tag name
        (?:
            \s+                 # whitespace before attribute name
            ['"\s]
            (?:
                [^\s/>]
                [^\s/=>]*       # attribute name
                (?:
                    \s*
                    =+
                    \s*         # value indicator
                    (?:
                        '[^']*' # LITA-enclosed value
                        |
                        "[^"]*" # LIT-enclosed value
                        |
                        (?
                            !['"]
                        )
                        [^>\s]* # bare value
                    )
                )?
                \s*
            )*
        )?
        \s*                     # trailing whitespace
    ///
    endendtag: />/
    endtagfind: ///
        </
        \s*
        (
            [a-zA-Z]
            [-.a-zA-Z0-9:_]*
        )
        \s*
        >
    ///
    commentclose: /\-\-\s*>/

String::startswith = (str, pos=0) ->
    this.indexOf(str, pos) == pos
String::strip = ->
    return this.replace /^\s+|\s+$/g, ""
String::count = (pattern) ->
    result = this.match(pattern)
    return if result? then result.length else 0
String::in = (haystack) ->
    haystack?.indexOf(this) >= 0
RegExp::search = (str, start=0) ->
    result = this.exec(str[start..])
    return null if not result?
    group: result
    match: result[0]
    start: result.index + start
    end: result.index + start + result[0].length
RegExp::match = (str, start=0) ->
    result = this.search(str, start)
    return null if not result?
    if result.start == start then result else null

class HTMLParseError
    constructor: (@message, @pos) ->
    toString: ->
        result = @message
        if @pos[0]?
            result += ", at line #{@pos[0]}"
        if @pos[1]?
            result += ", at column #{@pos[1]+1}"
        result

class ParserBase
    reset: ->
        @lineno = 1
        @offset = 0
    getpos: ->
        return [@lineno, @offset]

    # Internal -- update line number and offset.  This should be
    # called for each piece of data exactly once, in order -- in other
    # words the concatenation of all the input strings to this
    # function should be exactly the entire input.
    updatepos: (i, j) ->
        return j if i >= j
        slice = @rawdata[i...j]
        nlines = slice.count(/\n/g)
        if nlines > 0
            pos = slice.lastIndexOf('\n')
            @lineno += nlines
            @offset = j - (pos + 1)
        else
            @offset += (j - i)
        return j

    # Internal -- parse comment, return length or -1 if not terminated
    parse_comment: (i, report=1) ->
        if @rawdata[i...i+4] != '<!--'
            @error 'unexpected call to parse_comment'
        match = regex.commentclose.search @rawdata, i+4
        return -1 if not match?
        @handle_comment @rawdata[i+4...match.start] if report
        return match.end

class HTMLParser extends ParserBase
    constructor: ->
        super
        @__starttag_text = null
        @entitydefs = null
        @reset()
    reset: ->
        super
        @rawdata = ''
        @lasttag = '???'
        @interesting = regex.interesting_normal
        @cdata_elem = null
    feed: (data) ->
        @rawdata += data
        @goahead 0
    close: ->
        @goahead 1
    error: (message) ->
        throw new HTMLParseError(message, @getpos())
    get_starttag_text: ->
        @__starttag_text
    set_cdata_mode: (elem) ->
        elem = @cdata_elem = elem.toLowercase()
        @interesting = new RegExp("</\s*#{elem}\s*", 'i')
    clear_cdata_mode: ->
        @interesting = regex.interesting_normal
        @cdata_elem = null

    # Internal -- handle data as far as reasonable.  May leave state
    # and data to be processed by a subsequent call.  If 'end' is
    # true, force handling all data as if followed by EOF marker.
    goahead: (end) ->
        i = 0
        n = @rawdata.length
        while i < n
            match = @interesting.search @rawdata, i
            if match?
                j = match.start
            else
                break if @cdata_elem?
                j = n
            @handle_data(@rawdata[i...j]) if i < j
            i = @updatepos(i, j)
            break if i == n
            if @rawdata.startswith('<', i)
                if regex.starttagopen.search(@rawdata, i)?
                    k = @parse_starttag i
                else if @rawdata.startswith('</', i)
                    k = @parse_endtag i
                else if @rawdata.startswith('<!--', i)
                    k = @parse_comment i
                else if @rawdata.startswith('<?', i)
                    k = @parse_pi i
                else if @rawdata.startswith('<!', i)
                    k = @parse_declaration i
                else if (i + 1) < n
                    @handle_data '<'
                    k = i + 1
                else
                    break
                if k < 0
                    @error 'EOF in middle of construct' if end
                    break
                i = @updatepos(i, k)
            else if @rawdata.startswith('&#', i)
                @error 'goahead &# not implemented'
            else if @rawdata.startswith('&', i)
                match = regex.entityref.match @rawdata, i
                if match?
                    name = match.group[1]
                    @handle_entityref name
                    k = match.end
                    if not @rawdata.startswith(';', k-1)
                        k = k - 1
                    i = @updatepos i, k
                    continue
                match = regex.incomplete.match @rawdata, i
                if match?
                    # match.group() will contain at least 2 chars
                    if end and match.match == @rawdata[i..]
                        @error 'EOF in middle of entity or charref'
                    # incomplete
                    break
                else if (i + 1) < n
                    # not the end of the buffer, and can't be confused
                    # with some other construct
                    @handle_data '&'
                    i = @updatepos i, i+1
                else
                    break
            else
                @error 'interesting.search() lied'
        if end and i < n and not @cdata_elem?
            @handle_data(@rawdata[i...n])
            i = @updatepos(i, n)
        @rawdata = @rawdata[i..]

    parse_declaration: (i) ->
        @error 'parse_declaration not implemented'

    parse_pi: (i) ->
        @error 'parse_pi not implemented'

    parse_starttag: (i) ->
        @__starttag_text = null
        endpos = @check_for_whole_start_tag(i)
        if endpos < 0
            return endpos
        @__starttag_text = @rawdata[i...endpos]

        attrs = []
        match = regex.tagfind.search @rawdata, i+1
        if not match
            @error 'unexpected call to parse_starttag'
        k = match.end
        @lasttag = tag = @rawdata[i+1...k].toLowerCase()

        while k < endpos
            m = regex.attrfind.search @rawdata, k
            if not m
                break
            k = m.end

        end = @rawdata[k...endpos]?.strip()
        if end not in ['>', '/>']
            [lineno, offset] = @getpos
            if '\n'.in @__starttag_text
                lineno += @__starttag_text.count(/\n/g)
                offset = @__starttag_text.length - @__starttag_text.lastIndexOf('\n')
            else
                offset += @__starttag_text.length
            @error 'junk characters in start tag'
        if end == '/>'
            @handle_startendtag(tag, attrs)
        else
            @handle_starttag(tag, attrs)
            if tag.in @cdata_elem
                @set_cdata_mode(tag)
        return endpos

    check_for_whole_start_tag: (i) ->
        match = regex.locatestarttagend.search @rawdata, i
        if match
            j = match.end
            next = @rawdata[j]
            if next == '>'
                return j + 1
            if next == '/'
                if @rawdata.startswith('/>', j)
                    return j + 2
                if @rawdata.startswith('/', j)
                    return -1
                @updatepos(i, j + 1)
                @error 'malformed empty start tag'
            if next == ''
                return -1
            if next.in 'abcdefghijklmnopqrstuvwxyz=/ABCDEFGHIJKLMNOPQRSTUVWXYZ'
                return -1
            @updatepos(i, j)
            @error 'we should never get here'
        @error 'we should never get here'

    parse_endtag: (i) ->
        @error 'unexpected call to parse_endtag' if @rawdata[i...i+2] != '</'
        match = regex.endendtag.search @rawdata, i+1
        return -1 if not match?
        j = match.end
        match = regex.endtagfind.match @rawdata, i
        if not match?
            if @cdata_elem?
                @handle_data @rawdata[i...j]
                return j
            @error "bad end tag: #{@rawdata[i...j]}"
        elem = match.group[1].toLowerCase()
        if @cdata_elem?
            if elem isnt @cdata_elem
                @handle_data @rawdata[i...j]
                return j
        @handle_endtag elem
        @clear_cdata_mode()
        return j

    handle_startendtag: (tag, attrs) ->
        @handle_starttag(tag, attrs)
        @handle_endtag(tag)

    handle_starttag: (tag, attrs) ->
    handle_endtag: (tag) ->
    handle_charref: (name) ->
    handle_entityref: (name) ->
    handle_data: (data) ->
    handle_comment: (data) ->
    handle_decl: (decl) ->
    handle_pi: (data) ->
    unknown_decl: (data) ->
        @error "unknown declaration #{data}"

    unescape: (s) ->
        @error 'unescape not implemented'

module?.exports =
    regex: regex
    HTMLParseError: HTMLParseError
    HTMLParser: HTMLParser
