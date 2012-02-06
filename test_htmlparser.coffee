util = require('util')
QUnit = require('./qunit.js').QUnit
qunitTap = require('./qunit-tap.js').qunitTap
HTMLParser = require('./HTMLParser.coffee')
regex = HTMLParser.regex

class EventCollector extends HTMLParser.HTMLParser
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
    handle_decl: (data) ->
        @append ['decl', data]
    handle_pi: (data) ->
        @append ['pi', data]
    unknown_decl: (data) ->
        @append ['unknown dec', data]

get_events = (data) ->
    parser = new EventCollector
    for s in data
        parser.feed(s)
    parser.close()
    parser.get_events()

qunitTap(QUnit, util.puts, {
    noPlan: true
})

QUnit.init()
QUnit.config.updateRate = 0

test = QUnit.test
ok = QUnit.ok
equal = QUnit.equal
raises = QUnit.raises

deep_equal = (arr1, arr2) ->
    return false unless arr1.length is arr2.length
    for i in [0...arr1.length]
        if arr1[i] instanceof Array and arr2[i] instanceof Array
            return false unless deep_equal(arr1[i], arr2[i])
        else
            return false if arr1[i] isnt arr2[i]
    true
assert_ok = (name, actual) ->
    test(name, ->
        actual = actual() if typeof actual is 'function'
        ok actual
    )
assert_equal = (name, actual, expected) ->
    test(name, ->
        actual = actual() if typeof actual is 'function'
        expected = expected() if typeof expected is 'function'
        equal actual, expected
    )
assert_deep = (name, actual, expected) ->
    test(name, ->
        actual = actual() if typeof actual is 'function'
        expected = expected() if typeof expected is 'function'
        QUnit.push(deep_equal(actual, expected),
            util.inspect(actual),
            util.inspect(expected))
    )

assert_raises = (name, handler) ->
    test(name, ->
        raises handler
    )

assert_deep 'assert_deep', [], []
assert_deep 'assert_deep', ['foo'], ['foo']
assert_deep 'assert_deep', [['foo', 'bar']], [['foo', 'bar']]

assert_ok 'string::startswith', -> 'foobar'.startswith('foo')
assert_ok 'string::startswith', -> 'foobar'.startswith('oob', 1)
assert_equal 'string::startswith', 'foobar'.startswith('bar'), false
assert_equal 'string::strip', '  foo bar  '.strip(), 'foo bar'
assert_equal 'string::strip', 'foo bar'.strip(), 'foo bar'
assert_equal 'string::count', 'aaabbbccc'.count(/a/g), 3
assert_equal 'string::count', 'aaabbbccc'.count(/[a|b]/g), 6
assert_equal 'string::count', 'aaabbbccc'.count(/z/g), 0
assert_ok 'string::in', 'foo'.in('foobar')
assert_equal 'string::in', 'foo'.in('bar'), false

assert_equal 'string::unescape_htmlentities',
    '&#bad;'.unescape_htmlentities(), '&#bad;'
assert_equal 'string::unescape_htmlentities',
    '&gt;'.unescape_htmlentities(), '>'
assert_equal 'string::unescape_htmlentities',
    '&#0038;'.unescape_htmlentities(), '&'

assert_equal 'RegExp::search',
    -> /xyz/g.search('abcdefg')
    null
test 'RegExp::search', ->
    re = /def/g
    str = 'abcdefzdef'
    result1 = re.search str
    result2 = re.search str
    result3 = re.search str
    equal result1.match, 'def'
    equal result1.start, 3
    equal result1.end, 6
    equal result2.match, 'def'
    equal result2.start, 7
    equal result2.end, 10
    equal result3, null
    re = /def/g
    result4 = re.search str, 6
    equal result4.match, 'def'
    equal result4.start, 7
    equal result4.end, 10

test 'RegExp::match', ->
    re = /def/
    str = 'abcdefzdef'
    result1 = re.match str
    re = /def/
    result2 = re.match str, 3
    equal result1, null
    equal result2.match, 'def'

assert_ok 'regex.interesting_normal',
    -> regex.interesting_normal.test '&'
assert_ok 'regex.interesting_normal',
    -> regex.interesting_normal.test '<'
assert_ok 'regex.incomplete',
    -> regex.incomplete.test '&a#'
assert_ok 'regex.incomplete',
    -> regex.incomplete.test '&A#'
assert_ok 'regex.entityref',
    -> regex.entityref.test '&a-0Aaz#'
assert_ok 'regex.charref',
    -> regex.charref.test '&#123~'
assert_ok 'regex.starttagopen',
    -> regex.starttagopen.test '<a'
assert_ok 'regex.starttagopen',
    -> regex.starttagopen.test '<A'
assert_ok 'regex.piclose',
    -> regex.piclose.test 'foo>'
assert_ok 'regex.tagfind',
    -> regex.tagfind.test 'A-dD3:_-fF4:_'
assert_ok 'regex.endendtag',
    -> regex.endendtag.test 'foo>'
assert_ok 'regex.endtagfind',
    -> regex.endtagfind.test '</  A-dD3:_-fF4:_   >'
assert_ok 'regex.endtagfind',
    -> regex.endtagfind.test '</A-dD3:_-fF4:_>'
assert_ok 'regex.commentclose',
    -> regex.commentclose.test '-->'
assert_ok 'regex.commentclose',
    -> regex.commentclose.test '  -->'
assert_ok 'regex.commentclose',
    -> regex.commentclose.test '  --  >'
assert_ok 'regex.attrfind',
    -> regex.attrfind.test ' foo="bar" '
assert_ok 'regex.attrfind',
    -> regex.attrfind.test " foo='bar' "
assert_ok 'regex.attrfind',
    -> regex.attrfind.test " foo=bar "
assert_equal 'regex.locatestarttagend',
    -> regex.locatestarttagend.exec("<a foo='bar'>")?[0]
    "<a foo='bar'"
assert_equal 'regex.locatestarttagend',
    -> regex.locatestarttagend.exec('<a foo="bar">')?[0]
    '<a foo="bar"'
assert_equal 'regex.locatestarttagend',
    -> regex.locatestarttagend.exec('<a foo=bar>')?[0]
    '<a foo=bar'

assert_deep 'data check',
    -> get_events(['foo'])
    [['data', 'foo']]
assert_deep 'comment check',
    -> get_events(['<!-- foo -->'])
    [['comment', ' foo ']]
assert_deep 'simple self-closing tag check',
    -> get_events(['<p/>'])
    [['starttagend', 'p', []]]
assert_deep 'simple tag check',
    -> get_events(['<p>foo</p>'])
    [
        ['starttag', 'p', [] ],
        ['data', 'foo'],
        ['endtag', 'p']
    ]
# Strangely, this *is* supposed to test that overlapping
# elements are allowed.  HTMLParser is more geared toward
# lexing the input that parsing the structure.
assert_deep 'bad nesting',
    -> get_events(['<a><b></a></b>'])
    [
        ['starttag', 'a', []],
        ['starttag', 'b', []],
        ['endtag', 'a'],
        ['endtag', 'b']
    ]

assert_deep 'simple attribute check',
    -> get_events(['<p class="foo">bar</p>'])
    [
        ['starttag', 'p', [['class', 'foo']] ],
        ['data', 'bar'],
        ['endtag', 'p']
    ]

assert_deep 'multiple attribute check',
    -> get_events(['<p class="foo" style="moo">bar</p>'])
    [
        ['starttag', 'p', [
            ['class', 'foo'], ['style', 'moo']
        ]],
        ['data', 'bar'],
        ['endtag', 'p']
    ]

assert_deep 'self-closing tag with attributes',
    -> get_events(['<p class="foo" style="moo"/>'])
    [
        ['starttagend', 'p', [
            ['class', 'foo'], ['style', 'moo']
        ]]
    ]

assert_deep 'bare ampersands',
    -> get_events(['this text & contains & ampersands &'])
    [['data', 'this text & contains & ampersands &']]

assert_deep 'bare pointy/angle brackets',
    -> get_events(['this < text > contains < bare>pointy< brackets'])
    [['data', 'this < text > contains < bare>pointy< brackets']]

assert_raises 'parse error on </>',
    -> get_events(['</>'])

assert_deep 'declaration',
    -> get_events(['<!DOCTYPE html>'])
    [['decl', 'DOCTYPE html']]

assert_deep 'empty declaration',
    -> get_events(['<!>'])
    []

assert_deep 'simple entity ref',
    -> get_events(['<p>&entity;&#32;</p>'])
    [
        ['starttag', 'p', []],
        ['entityref', 'entity'],
        ['charref', '32'],
        ['endtag', 'p']
    ]

assert_deep 'simple html',
    -> get_events(["""
                    <!DOCTYPE html PUBLIC 'foo'>
                    <HTML>&entity;&#32;
                    <!--comment1a
                    -></foo><bar>&lt;<?pi?></foo<bar
                    comment1b-->
                    <Img sRc='Bar' isMAP>sample
                    text
                    &#x201C;
                    <!--comment2a-- --comment2b--><!>
                    </Html>
                    """])
    [
        ['decl', 'DOCTYPE html PUBLIC \'foo\''],
        ['data', '\n'],
        ['starttag', 'html', []],
        ['entityref', 'entity'],
        ['charref', '32'],
        ['data', '\n'],
        ['comment', 'comment1a\n-></foo><bar>&lt;<?pi?></foo<bar\ncomment1b'],
        ['data', '\n'],
        ['starttag', 'img', [['src', 'Bar'], ['ismap', null]]],
        ['data', 'sample\ntext\n'],
        ['charref', 'x201C'],
        ['data', '\n'],
        ['comment', 'comment2a-- --comment2b'],
        ['data', '\n'],
        ['endtag', 'html']
    ]

QUnit.start()
