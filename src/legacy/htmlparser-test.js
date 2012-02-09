/*jslint newcap: false, node: true, multistr: true */

var util = require('util');
var QUnit = require('./qunit.js').QUnit;
var qunitTap = require('./qunit-tap.js').qunitTap;
var htmlparse = require('./htmlparser.js');
var HTMLtoXML = htmlparse.HTMLtoXML;

qunitTap(QUnit, util.puts, {
    noPlan: true
});

QUnit.init();
QUnit.config.updateRate = 0;

var equal = QUnit.equal;

function test(name, handler) {
    return QUnit.test(name, 1, handler);
}

test('it should handle an empty tag', function () {
    equal(
        HTMLtoXML('<span></span>'),
        '<span></span>'
    );
});
test('it should handle a tag with text', function () {
    equal(
        HTMLtoXML('<span>inner text</span>'),
        '<span>inner text</span>'
    );
});
test('it should handle a tag with a trailing single quote', function () {
    equal(
        HTMLtoXML('<span\'></span\'>'),
        '<span></span>'
    );
});
test('it should handle a tag with a trailing double quote', function () {
    equal(
        HTMLtoXML('<span"></span">'),
        '<span></span>'
    );
});
test('it should handle a case insensitve em tag', function () {
    equal(
        HTMLtoXML('<EM></EM>'),
        '<em></em>'
    );
});
test('it should handle a case insensitive style tag', function () {
    equal(
        HTMLtoXML('<STYLE></STYLE>'),
        '<style></style>'
    );
});
test('it should handle a case insenitive script tag', function () {
    equal(
        HTMLtoXML('<SCRIPT></SCRIPT>'),
        '<script></script>'
    );
});
test('it should add missing closing tags bold', function () {
    equal(
        HTMLtoXML('<b>foo'),
        '<b>foo</b>'
    );
});
test('it should parse comments embedded within style tag', function () {
    equal(
        HTMLtoXML('<style><!-- foo --></style>'),
        '<style><!-- foo --></style>'
    );
});
test('it should parse comments embedded newline within style tag',
     function () {
    equal(
        HTMLtoXML('<style><!-- \n --></style>'),
        '<style><!-- \n --></style>'
    );
});
test('it should parse comments embedded within style tag leading space',
     function () {
    equal(
        HTMLtoXML('<style> <!-- \n --></style>'),
        '<style> <!-- \n --></style>'
    );
});
test('it should parse a bare comment', function () {
    equal(
        HTMLtoXML('foo <!-- bar --> zoo'),
        'foo <!-- bar --> zoo'
    );
});
test('it should pass John Resigs missing end tag nested', function () {
    equal(
        HTMLtoXML('<p><b>Hello'),
        '<p><b>Hello</b></p>'
    );
});
test('it should pass John Resigs empty elements', function () {
    equal(
        HTMLtoXML('<img src=test.jpg>'),
        '<img src="test.jpg" />'
    );
});
test('it should pass John Resigs block vs inline', function () {
    equal(
        HTMLtoXML('<b>Hello <p>John'),
        '<b>Hello </b><p>John</p>'
    );
});
test('it should pass John Resigs self-closing tags', function () {
    equal(
        HTMLtoXML('<p>Hello<p>World'),
        '<p>Hello</p><p>World</p>'
    );
});
test('it should pass John Resigs attribute without values', function () {
    equal(
        HTMLtoXML('<input disabled>'),
        '<input disabled="disabled" />'
    );
});
test('it should parse end tags that have a < immediately after /', function () {
    equal(
        HTMLtoXML('<p>foo bar</<p>'),
        '<p>foo bar</p>'
    );
});
test('it should unwrap tags that do not make any sense', function () {
    equal(
        HTMLtoXML(
            '<div><class="underline"><span>foo bar</span></class="underline"></div>'),
        '<div><span>foo bar</span></div>'
    );
});
test('it should convert a floating < to &lt;', function () {
    equal(
        HTMLtoXML('<p>40 < 60</p>'),
        '<p>40 &lt; 60</p>'
    );
});
test('it should convert a floating < to &lt;', function () {
    equal(
        HTMLtoXML('<br />foo < 30<br />'),
        '<br />foo &lt; 30<br />'
    );
});
test('it should convert a floating > to &gt;', function () {
    equal(
        HTMLtoXML('<p>60 > 40</p>'),
        '<p>60 &gt; 40</p>'
    );
});
test('it should convert a floating > to &lt;', function () {
    equal(
        HTMLtoXML('<br />foo > 30<br />'),
        '<br />foo &gt; 30<br />'
    );
});
test('it should convert a floating > and <', function () {
    equal(
        HTMLtoXML('<p>one < two > three</p>'),
        '<p>one &lt; two &gt; three</p>'
    );
});

test('it should handle normal html without issue', function () {
    equal(
        HTMLtoXML('<h2>one</h2><p>two</p><h2>three</h2>'),
        '<h2>one</h2><p>two</p><h2>three</h2>'
    );
});

test('it should strip xml specification', function () {
    equal(
        HTMLtoXML('<?xml:namespace prefix = o ns = "urn:schemas-microsoft-com:office:office" />\
<p><?xml:namespace prefix = o ns = "urn:schemas-microsoft-com:office:office" /><p>foo</p>'),
        '<p></p><p>foo</p>'
    );
});

test('it should strip xml specification', function () {
    equal(
        HTMLtoXML('<?xml:namespace prefix = o ns = "urn:schemas-microsoft-com:office:office" ?>\
<p><?xml:namespace prefix = o ns = "urn:schemas-microsoft-com:office:office" ?><p>foo</p>'),
        '<p></p><p>foo</p>'
    );
});

test('it should handle a period after the tag name', function () {
    equal(
        HTMLtoXML('<ok.>foo</ok.>'),
        '<ok>foo</ok>'
    );
});

QUnit.start();
