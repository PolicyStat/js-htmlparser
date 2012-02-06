util = require('util')
QUnit = require('./qunit.js').QUnit
qunitTap = require('./qunit-tap.js').qunitTap
HTMLParser = require('./HTMLParser.coffee')

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

qunitTap(QUnit, util.puts, {
    noPlan: true
})

QUnit.init()
QUnit.config.updateRate = 0

test = QUnit.test
ok = QUnit.ok
equal = QUnit.equal

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
        ok actual
    )
assert_equal = (name, actual, expected) ->
    test(name, ->
        equal actual, expected
    )
assert_deep = (name, actual, expected) ->
    test(name, ->
        ok deep_equal actual, expected
    )

get_events = (data) ->
    parser = new EventCollector
    for s in data
        parser.feed(s)
    parser.close()
    parser.get_events()

assert_ok 'string::startswith', 'foobar'.startswith('foo')
assert_ok 'string::startswith', 'foobar'.startswith('oob', 1)
assert_equal 'string::startswith', 'foobar'.startswith('bar'), false
assert_equal 'string::strip', '  foo bar  '.strip(), 'foo bar'
assert_equal 'string::strip', 'foo bar'.strip(), 'foo bar'
assert_equal 'string::count', 'aaabbbccc'.count(/a/g), 3
assert_equal 'string::count', 'aaabbbccc'.count(/[a|b]/g), 6
assert_equal 'string::count', 'aaabbbccc'.count(/z/g), 0
assert_equal 'RegExp::search', /xyz/g.search('abcdefg'), null
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
assert_deep 'assert_deep', [], []
assert_deep 'assert_deep', ['foo'], ['foo']
assert_deep 'assert_deep', [['foo', 'bar']], [['foo', 'bar']]
assert_deep 'data check', get_events(['foo']), [['data', 'foo']]
#assert_deep 'simple tag check', get_events(['<p>foo</p>']), [
    #['starttagopen', 'p', null],
    #['data', 'foo'],
    #['starttagend', 'p']
#]

QUnit.start()
