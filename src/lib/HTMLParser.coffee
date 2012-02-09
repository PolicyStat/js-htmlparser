##
# http://hg.python.org/cpython/file/2.7/Lib/HTMLParser.py
# Copyright (c) 2001, 2002, 2003, 2004, 2005, 2006 Python Software Foundation; All Rights Reserved
##
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
    declname: /[a-zA-Z][-_.a-zA-Z0-9]*\s*/
    declstringlit: /('[^']*'|"[^"]*")\s*/
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
            \s*                 # whitespace before attribute name
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

htmlentitydefs =
    'apos': 39,
    'AElig': 198, 'Aacute': 193, 'Acirc': 194, 'Agrave': 192, 'Alpha': 913, 'Aring': 197, 'Atilde': 195, 'Auml': 196, 'Beta': 914, 'Ccedil': 199, 'Chi': 935, 'Dagger': 8225, 'Delta': 916, 'ETH': 208, 'Eacute': 201, 'Ecirc': 202, 'Egrave': 200, 'Epsilon': 917, 'Eta': 919, 'Euml': 203, 'Gamma': 915, 'Iacute': 205, 'Icirc': 206, 'Igrave': 204, 'Iota': 921, 'Iuml': 207,
    'Kappa': 922, 'Lambda': 923, 'Mu': 924, 'Ntilde': 209, 'Nu': 925, 'OElig': 338, 'Oacute': 211, 'Ocirc': 212, 'Ograve': 210, 'Omega': 937, 'Omicron': 927, 'Oslash': 216, 'Otilde': 213, 'Ouml': 214, 'Phi': 934, 'Pi': 928, 'Prime': 8243, 'Psi': 936, 'Rho': 929, 'Scaron': 352, 'Sigma': 931, 'THORN': 222, 'Tau': 932, 'Theta': 920, 'Uacute': 218, 'Ucirc': 219,
    'Ugrave': 217, 'Upsilon': 933, 'Uuml': 220, 'Xi': 926, 'Yacute': 221, 'Yuml': 376, 'Zeta': 918, 'aacute': 225, 'acirc': 226, 'acute': 180, 'aelig': 230, 'agrave': 224, 'alefsym': 8501, 'alpha': 945, 'amp': 38, 'and': 8743, 'ang': 8736, 'aring': 229, 'asymp': 8776, 'atilde': 227, 'auml': 228, 'bdquo': 8222, 'beta': 946, 'brvbar': 166, 'bull': 8226, 'cap': 8745,
    'ccedil': 231, 'cedil': 184, 'cent': 162, 'chi': 967, 'circ': 710, 'clubs': 9827, 'cong': 8773, 'copy': 169, 'crarr': 8629, 'cup': 8746, 'curren': 164, 'dArr': 8659, 'dagger': 8224, 'darr': 8595, 'deg': 176, 'delta': 948, 'diams': 9830, 'divide': 247, 'eacute': 233, 'ecirc': 234, 'egrave': 232, 'empty': 8709, 'emsp': 8195, 'ensp': 8194, 'epsilon': 949,
    'equiv': 8801, 'eta': 951, 'eth': 240, 'euml': 235, 'euro': 8364, 'exist': 8707, 'fnof': 402, 'forall': 8704, 'frac12': 189, 'frac14': 188, 'frac34': 190, 'frasl': 8260, 'gamma': 947, 'ge': 8805, 'gt': 62, 'hArr': 8660, 'harr': 8596, 'hearts': 9829, 'hellip': 8230, 'iacute': 237, 'icirc': 238, 'iexcl': 161, 'igrave': 236, 'image': 8465, 'infin': 8734,
    'int': 8747, 'iota': 953, 'iquest': 191, 'isin': 8712, 'iuml': 239, 'kappa': 954, 'lArr': 8656, 'lambda': 955, 'lang': 9001, 'laquo': 171, 'larr': 8592, 'lceil': 8968, 'ldquo': 8220, 'le': 8804, 'lfloor': 8970, 'lowast': 8727, 'loz': 9674, 'lrm': 8206, 'lsaquo': 8249, 'lsquo': 8216, 'lt': 60, 'macr': 175, 'mdash': 8212, 'micro': 181, 'middot': 183,
    'minus': 8722, 'mu': 956, 'nabla': 8711, 'nbsp': 160, 'ndash': 8211, 'ne': 8800, 'ni': 8715, 'not': 172, 'notin': 8713, 'nsub': 8836, 'ntilde': 241, 'nu': 957, 'oacute': 243, 'ocirc': 244, 'oelig': 339, 'ograve': 242, 'oline': 8254, 'omega': 969, 'omicron': 959, 'oplus': 8853, 'or': 8744, 'ordf': 170, 'ordm': 186, 'oslash': 248, 'otilde': 245,
    'otimes': 8855, 'ouml': 246, 'para': 182, 'part': 8706, 'permil': 8240, 'perp': 8869, 'phi': 966, 'pi': 960, 'piv': 982, 'plusmn': 177, 'pound': 163, 'prime': 8242, 'prod': 8719, 'prop': 8733, 'psi': 968, 'quot': 34, 'rArr': 8658, 'radic': 8730, 'rang': 9002, 'raquo': 187, 'rarr': 8594, 'rceil': 8969, 'rdquo': 8221, 'real': 8476, 'reg': 174,
    'rfloor': 8971, 'rho': 961, 'rlm': 8207, 'rsaquo': 8250, 'rsquo': 8217, 'sbquo': 8218, 'scaron': 353, 'sdot': 8901, 'sect': 167, 'shy': 173, 'sigma': 963, 'sigmaf': 962, 'sim': 8764, 'spades': 9824, 'sub': 8834, 'sube': 8838, 'sum': 8721, 'sup': 8835, 'sup1': 185, 'sup2': 178, 'sup3': 179, 'supe': 8839, 'szlig': 223, 'tau': 964, 'there4': 8756,
    'theta': 952, 'thetasym': 977, 'thinsp': 8201, 'thorn': 254, 'tilde': 732, 'times': 215, 'trade': 8482, 'uArr': 8657, 'uacute': 250, 'uarr': 8593, 'ucirc': 251, 'ugrave': 249, 'uml': 168, 'upsih': 978, 'upsilon': 965, 'uuml': 252, 'weierp': 8472, 'xi': 958, 'yacute': 253, 'yen': 165, 'yuml': 255, 'zeta': 950, 'zwj': 8205, 'zwnj': 8204

String::startswith = (str, pos=0) ->
    this.indexOf(str, pos) == pos
String::strip = ->
    return this.replace /^\s+|\s+$/g, ""
String::count = (pattern) ->
    result = this.match(pattern)
    return if result? then result.length else 0
String::contains = (haystack) ->
    if haystack? then this.indexOf(haystack) >= 0 else false
String::unescape_htmlentities = ->
    if not this.contains '&'
        return this.toString()
    this.replace(
        ///
            &(
                \#?
                [xX]?
                (?:
                    [0-9a-fA-F]+
                    |
                    \w{1,8}
                )
            );
        ///g,
        (_, match) ->
            str = match
            if str[0] == '#'
                str = str[1..]
                if str[0] in ['x', 'X']
                    c = parseInt(str[1..], 16)
                else
                    c = parseInt(str, 10)
                if c
                    code = String.fromCharCode(c)
                    if code isnt '\u0000'
                        return code
                return '&#'+str+';'
            else
                if htmlentitydefs[str]?
                    code = String.fromCharCode(htmlentitydefs[str])
                    if code isnt '\u0000'
                        return code
                return '&'+str+';'
            return match
    )

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
                if regex.starttagopen.match(@rawdata, i)?
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
                match = regex.charref.match @rawdata, i
                if match?
                    name = match.match[2...-1]
                    @handle_charref name
                    k = match.end
                    if not @rawdata.startswith(';', k-1)
                        k = k - 1
                    i = @updatepos i, k
                    continue
                else
                    if @rawdata[i..]?.contains ';' # bail by consuming &#
                        @handle_data @rawdata[0...2]
                        i = @updatepos i, 2
                    break
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
        j = i + 2
        if @rawdata[i...j] != '<!'
            @error 'unexpected call to parse_declaration'
        if @rawdata[j..j] == '>'
            # the empty comment <!>
            return j + 1
        if @rawdata[j..j] in ['-', '']
            # Start of comment followed by buffer boundary,
            # or just a buffer boundary.
            return -1
        if @rawdata[j...j+2] == '--'
            # Locate --.*-- as the body of the comment
            return @parse_comment i
        else if @rawdata[j] == '['
            return @parse_marked_section i
        else
            [decltype, j] = @_scan_name j, i
        if j < 0
            return j
        if decltype == 'doctype'
            @_decl_otherchars = ''
        while j < @rawdata.length
            c = @rawdata[j]
            if c == '>'
                # end of declaration syntax
                data = @rawdata[i+2...j]
                if decltype == 'doctype'
                    @handle_decl data
                else
                    # According to the HTML5 specs sections "8.2.4.44 Bogus
                    # comment state" and "8.2.4.45 Markup declaration open
                    # state", a comment token should be emitted.
                    # Calling unknown_decl provides more flexibility though.
                    @unknown_decl data
                return j + 1
            if /'|"/.test(c)
                m = regex.declstringlit.match @rawdata, j
                if not m?
                    return -1 # incomplete
                j = m.end
            else if /[a-zA-Z]/.test(c)
                [name, j] = @_scan_name j, i
            else if @_decl_otherchars?.contains c
                j = j + 1
            else
                @error 'unexpected character "#{c}" in declaration'
            if j < 0
                return j
        return -1

    _scan_name: (i, declstartpos) ->
        if i == @rawdata.length
            return [null, -1]
        m = regex.declname.match @rawdata, i
        if m?
            s = m.match
            name = s.strip()
            if i + s.length == @rawdata.length
                return [null, -1]
            return [name.toLowerCase(), m.end]
        else
            @updatepos declstartpos, i
            @error 'expected name token'

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
            m = regex.attrfind.match @rawdata, k
            if not m
                break
            [attrname, rest, attrvalue] = m.group[1..3]
            if not rest?
                attrvalue = null
            else if (attrvalue[...1] == "'" == attrvalue[-1..]) or
                    (attrvalue[...1] == '"' == attrvalue[-1..])
                attrvalue = attrvalue[1...-1]
            if attrvalue?
                attrvalue = attrvalue.unescape_htmlentities()
            attrs.push [attrname.toLowerCase(), attrvalue]
            k = m.end

        end = @rawdata[k...endpos]?.strip()
        if end not in ['>', '/>']
            [lineno, offset] = @getpos
            if @__starttag_text?.contains '\n'
                lineno += @__starttag_text.count(/\n/g)
                offset = @__starttag_text.length - @__starttag_text.lastIndexOf('\n')
            else
                offset += @__starttag_text.length
            @error 'junk characters in start tag'
        if end == '/>'
            @handle_startendtag(tag, attrs)
        else
            @handle_starttag(tag, attrs)
            if @cdata_elem?.contains tag
                @set_cdata_mode(tag)
        return endpos

    check_for_whole_start_tag: (i) ->
        match = regex.locatestarttagend.match @rawdata, i
        if match?
            j = match.end
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
            if /[a-zA-Z=\/]/.test(next)
                return -1
            @updatepos(i, j)
            @error 'malformed start tag'
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

namespace =
    regex: regex
    HTMLParseError: HTMLParseError
    HTMLParser: HTMLParser

if not module? or not require?
    window.HTMLParser = namespace
else
    module.exports = namespace
