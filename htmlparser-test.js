/*jslint newcap: false, node: true */

var util = require('util');
var QUnit = require('./qunit.js').QUnit;
var qunitTap = require('./qunit-tap.js');
var htmlparse = require('./htmlparser.js');
var HTMLtoXML = htmlparse.HTMLtoXML;

qunitTap.qunitTap(QUnit, util.puts, {
    noPlan: true,
    showDetailsOnFailure: true
});

QUnit.init();
QUnit.config.updateRate = 0;

var test = QUnit.test;
var equal = QUnit.equal;

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

test('it should parse comments', 2, function () {
    equal(
        HTMLtoXML('<style><!-- foo --></style>'),
        '<style><!-- foo --></style>',
        'embedded within style tags'
    );
    equal(
        HTMLtoXML('<style><!-- \n --></style>'),
        '<style><!-- \n --></style>',
        'embedded newlines within style tags'
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
