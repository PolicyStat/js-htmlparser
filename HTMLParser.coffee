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

class HTMLParseError
    constructor: (@message, @pos) ->
    toString: ->
        result = @message
        if @pos[0]?
            result += ", at line #{@pos[0]}"
        if @pos[1]?
            result += ", at column #{@pos[1]+1}"
        result

class HTMLParser

    constructor: ->
        @__starttag_text = null
        @entitydefs = null
        @reset()
    reset: ->
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
        throw HTMLParseError(message, @getpos())
    get_starttag_text: ->
        @__starttag_text
    set_cdata_mode: (elem) ->
        elem = @cdata_elem = elem.toLowercase()
        @interesting = new RegExp("</\s*#{elem}\s*", 'i')
    clear_cdata_mode: ->
        @interesting = regex.interesting_normal
        @cdata_elem = null

    goahead: (end) ->
        # TODO

    parse_pi: (i) ->
        # TODO

    parse_starttag: (i) ->
        # TODO

    check_for_whole_start_tag: (i) ->
        # TODO

    parse_endtag: (i) ->
        # TODO

    parse_endtag: (i) ->
        # TODO

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

    unescape: (s) ->
        # TODO

module.exports =
    regex: regex
    HTMLParseError: HTMLParseError
    HTMLParser: HTMLParser
