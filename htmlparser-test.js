/*jslint newcap: false */
/*global test, ok, equal, expect, HTMLtoXML */
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
