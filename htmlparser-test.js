/*jslint newcap: false, node: true */

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

var test = QUnit.test;
var equal = QUnit.equal;

test('it should handle basic html', 7, function () {
    equal(
        HTMLtoXML('<span></span>'),
        '<span></span>',
        'empty tag'
    );
    equal(
        HTMLtoXML('<span>inner text</span>'),
        '<span>inner text</span>',
        'tag with text'
    );
    equal(
        HTMLtoXML('<span\'></span\'>'),
        '<span></span>',
        'tag has trailing single quote'
    );
    equal(
        HTMLtoXML('<span"></span">'),
        '<span></span>',
        'tag has trailing double quote'
    );
    equal(
        HTMLtoXML('<EM></EM>'),
        '<em></em>',
        'case insensitive em tag'
    );
    equal(
        HTMLtoXML('<STYLE></STYLE>'),
        '<style></style>',
        'case insensitive style tag'
    );
    equal(
        HTMLtoXML('<SCRIPT></SCRIPT>'),
        '<script></script>',
        'case insensitive script tag'
    );
});

test('it should add missing closing tags', 2, function () {
    equal(
        HTMLtoXML('<b>foo'),
        '<b>foo</b>',
        'bold'
    );
    equal(
        HTMLtoXML('<i>foo'),
        '<i>foo</i>',
        'italic'
    );
});

test('it should parse comments', 4, function () {
    equal(
        HTMLtoXML('<style><!-- foo --></style>'),
        '<style><!-- foo --></style>',
        'embedded within style tags'
    );
    equal(
        HTMLtoXML('<style><!-- \n --></style>'),
        '<style><!-- \n --></style>',
        'embedded newline within style tags'
    );
    equal(
        HTMLtoXML('<style> <!-- \n --></style>'),
        '<style> <!-- \n --></style>',
        'embedded newline within style tags leading space'
    );
    equal(
        HTMLtoXML('foo <!-- bar --> zoo'),
        'foo <!-- bar --> zoo',
        'bare comment'
    );
});

test('it should pass John Resigs tests', 5, function () {
    equal(
        HTMLtoXML('<p><b>Hello'),
        '<p><b>Hello</b></p>',
        'Missing end tags nested'
    );
    equal(
        HTMLtoXML('<img src=test.jpg>'),
        '<img src="test.jpg"/>',
        'Empty Elements'
    );
    equal(
        HTMLtoXML('<b>Hello <p>John'),
        '<b>Hello </b><p>John</p>',
        'Block vs. Inline Elements'
    );
    equal(
        HTMLtoXML('<p>Hello<p>World'),
        '<p>Hello</p><p>World</p>',
        'Self-closing Elements'
    );
    equal(
        HTMLtoXML('<input disabled>'),
        '<input disabled="disabled"/>',
        'Attributes Without Values'
    );
});

QUnit.start();
