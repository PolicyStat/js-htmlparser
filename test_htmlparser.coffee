util = require('util')
QUnit = require('./qunit.js').QUnit
qunitTap = require('./qunit-tap.js').qunitTap
HTMLParser = require('./HTMLParser.coffee')

qunitTap(QUnit, util.puts, {
    noPlan: true
})

QUnit.init()
QUnit.config.updateRate = 0

test = QUnit.test
ok = QUnit.ok
equal = QUnit.equal

assert_ok = (name, actual) ->
    test(name, ->
        ok actual
    )
assert_equal = (name, actual, expected) ->
    test(name, ->
        equal actual, expected
    )

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
    result = re.search str
    equal result.match, 'def'
    equal result.start, 3
    equal result.end, 6
    result = re.search str
    equal result.match, 'def'
    equal result.start, 7
    equal result.end, 10
    equal re.search str, null

QUnit.start()
