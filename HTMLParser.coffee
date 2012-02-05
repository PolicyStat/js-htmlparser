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
    commentclose: /\-\-\s*>/
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

String::startswith = (str, pos)->
    this.indexOf(str, pos) == pos
String::strip = ->
    return this.replace /^\s+|\s+$/g, ""

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
        nlines = @rawdata[i..j].match(/\n/g)?.length
        if nlines
            @lineno += nlines
            pos = @rawdata[i..j].lastIndexOf('\n')
            @offset = j - (pos + 1)
        else
            @offset += (j - i)
        return j

    # Internal -- parse comment, return length or -1 if not terminated
    parse_comment: (i, report=1) ->
        if @rawdata[i..i+4] != '<!--'
            @error 'unexpected call to parse_comment'
        match = @rawdata[i+4..].match(regex.commentclose)
        return -1 if not match?
        if report
            j = match.index
            @handle_comment(@rawdata[i+4..j])
        return match[0].length + match.index

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
            match = @rawdata[i..].search(@interesting)
            if match > -1
                j = match
            else
                break if @cdata_elem?
                j = n
            @handle_data(@rawdata[i..j]) if i < j
            i = @updatepos(i, j)
            break if i == n
            if @rawdata.startswith('<', i)
                if @rawdata[i..].search(regex.starttagopen) > -1
                    k = @parse_starttag(i)
                else
                    break
                if k < 0
                    @error 'EOF in middle of construct' if end
                    break
                i = @updatepos(i, k)
            else if @rawdata.startswith('&#', i)
                @error 'goahead &# not implemented'
            else if @rawdata.startswith('&', i)
                @error 'goahead & not implemented'
            else
                @error 'interesting.search() lied'
        if end and i < n and not @cdata_elem?
            @handle_data(@rawdata[i..n])
            i = @updatepos(i, n)
        @rawdata = @rawdata[i..]

    parse_pi: (i) ->
        @error 'parse_pi not implemented'

    parse_starttag: (i) ->
        @__starttag_text = null
        endpos = @check_for_whole_start_tag(i)
        if endpos < 0
            return endpos
        @__starttag_text = @rawdata[i..endpos]

        attrs = []
        match = @rawdata[i+1..].match(regex.tagfind)
        if not match
            @error 'unexpected call to parse_starttag'
        k = match[0].length + match.index
        @lasttag = tag = @rawdata[i+1..k].toLowerCase()

        while k < endpos
            m = @rawdata[k..].match(regex.attrfind)
            if not m
                console.log 'breaking'
                break
            @error 'parsing attrs not implemented'

        end = @rawdata[k+1..endpos-1]?.strip()
        if end not in ['>', '/>']
            pos = @getpos
            lineno = pos[0]
            offset = pos[1]
            if '\n' in @__starttag_text
                lineno += @__starttag_text.match(/\n/g)?.length
                offset = @__starttag_text.length - @__starttag_text.lastIndexOf('\n')
            else
                offset += @__starttag_text.length
            @error 'junk characters in start tag'
        console.log end
        #if end == '/>'
        #    @handle_startendtag(tag, attrs)
        #else
        @handle_starttag(tag, attrs)
        if tag in @cdata_elem
            @set_cdata_mode(tag)
        return endpos

    check_for_whole_start_tag: (i) ->
        match = @rawdata[i..].match(regex.locatestarttagend)
        if match
            j = match[0].length + match.index
            next = @rawdata[j..j]
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
            if next in 'abcdefghijklmnopqrstuvwxyz=/ABCDEFGHIJKLMNOPQRSTUVWXYZ'
                return -1
            @updatepos(i, j)
            @error 'we shuold never get here'
        @error 'we shuold never get here'

    parse_endtag: (i) ->
        @error 'parse_endtag not implemented'

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

class EventCollector extends HTMLParser
    constructor: ->
        @events = []
        super
    append: (item) ->
        @events.push(item)
    get_events: ->
        L = []
        prevtype = null
        for event in @events
            type = event[0]
            last = L.length - 1
            if type == prevtype == 'data'
                L[last] = ['data', L[last][1] + event[1]]
            else
                L.push(event)
            prevtype = type
        @events = L

    handle_starttag: (tag, attrs) ->
        console.log tag, attrs
        @append ['starttag', tag, attrs]
    handle_startendtag: (tag, attrs) ->
        @append ['starttagend', tag, attrs]
    handle_endtag: (tag) ->
        @append ['endtag', tag]
    handle_charref: (name) ->
        @append ['charref', name]
    handle_entityref: (name) ->
        @append ['entityref', name]
    handle_data: (data) ->
        @append ['data', data]
    handle_comment: (data) ->
        @append ['comment', data]
    handle_decl: (decl) ->
        @append ['decl', data]
    handle_pi: (data) ->
        @append ['pi', data]
    unknown_decl: (data) ->
        @append ['unknown dec', data]

class HTMLParserTestBase
    constructor: ->
        @passed = 0
        @total = 0
    deepEquals: (arr1, arr2) ->
        return false unless arr1.length is arr2.length
        for i in [0...arr1.length]
            if arr1[i] instanceof Array and arr2[i] instanceof Array
                return false unless @deepEquals(arr1[i], arr2[i])
            else
                return false if arr1[i] isnt arr2[i]
        true

    run_check: (name, source, expected_events, collector=EventCollector) ->
        parser = new collector
        for s in source
            parser.feed(s)
        parser.close()
        events = parser.get_events()
        @total += 1
        if @deepEquals(events, expected_events)
            @passed += 1
            console.log "Test '#{name}' passed"
        else
            console.log "Test '#{name}' failed"
            console.log """
                  Received events did not match expected events

                  Expected:
                  #{expected_events}

                  Received:
                  #{events}
                  """

class HTMLParserTestCase extends HTMLParserTestBase
    test_simple_html: ->
        @run_check('data check',
            [
                'foo'
            ],
            [
                ['data', 'foo']
            ]
        )
        @run_check('simple tag check',
            [
                '<p>foo</p>'
            ],
            [
                ['starttagopen', 'p', null],
                ['data', 'foo'],
                ['starttagend', 'p']
            ]
        )

module.exports =
    regex: regex
    HTMLParseError: HTMLParseError
    HTMLParser: HTMLParser
    run_tests: ->
        tester = new HTMLParserTestCase
        tester.test_simple_html()
        console.log "\n#{tester.total} tests run"
        console.log 'Passed:', tester.passed
