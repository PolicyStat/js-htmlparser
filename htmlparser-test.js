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

