/*
 * HTML Parser By John Resig (ejohn.org)
 * Original code by Erik Arvidsson, Mozilla Public License
 * http://erik.eae.net/simplehtmlparser/simplehtmlparser.js
 *
 * // Use like so:
 * HTMLParser(htmlString, {
 *     start: function(tag, attrs, unary) {},
 *     end: function(tag) {},
 *     chars: function(text) {},
 *     comment: function(text) {}
 * });
 *
 * // or to get an XML string:
 * HTMLtoXML(htmlString);
 *
 * // or to get an XML DOM Document
 * HTMLtoDOM(htmlString);
 *
 * // or to inject into an existing document/DOM node
 * HTMLtoDOM(htmlString, document);
 * HTMLtoDOM(htmlString, document.body);
 *
 */

/*jslint regexp: false, node: true, newcap: false */
/*global DOMDocument */

function makeMap(str) {
    var obj = {}, items = str.split(',');
    for (var i = 0; i < items.length; i++) {
        obj[items[i]] = true;
    }
    return obj;
}

// Regular Expressions for parsing tags and attributes
var startTag = /^<([-A-Za-z0-9_]+)['"\.]?((?:\s+\w+(?:\s*=\s*(?:(?:"[^"]*")|(?:'[^']*')|[^>\s]+))?)*)\s*(\/?)>/,
endTag = /^<\/<?([-A-Za-z0-9_]+)[^>]*>/,
attr = /([-A-Za-z0-9_]+)(?:\s*=\s*(?:(?:"((?:\\.|[^"])*)")|(?:'((?:\\.|[^'])*)')|([^>\s]+)))?/g;

var comment = {
    start: '<!--',
    end: '-->'
};

// Empty Elements - HTML 4.01
var empty = makeMap('area,base,basefont,br,col,frame,hr,img,input,isindex,link,meta,param,embed');

// Block Elements - HTML 4.01
var block = makeMap('address,applet,blockquote,button,center,dd,del,dir,div,dl,dt,fieldset,form,frameset,hr,iframe,ins,isindex,li,map,menu,noframes,noscript,object,ol,p,pre,script,table,tbody,td,tfoot,th,thead,tr,ul');

// Inline Elements - HTML 4.01
var inline = makeMap('a,abbr,acronym,applet,b,basefont,bdo,big,br,button,cite,code,del,dfn,em,font,i,iframe,img,input,ins,kbd,label,map,object,q,s,samp,script,select,small,span,strike,strong,sub,sup,textarea,tt,u,var');

// Elements that you can, intentionally, leave open
// (and which close themselves)
var closeSelf = makeMap('colgroup,dd,dt,li,options,p,td,tfoot,th,thead,tr');

// Attributes that have their values filled in disabled='disabled'
var fillAttrs = makeMap('checked,compact,declare,defer,disabled,ismap,multiple,nohref,noresize,noshade,nowrap,readonly,selected');

// Special Elements (can contain anything)
var special = makeMap('script,style');

var handler_noop = {
    start: function () { },
    end: function () { },
    chars: function () { },
    comment: function () { },
    raw_tag: function () { return ''; }
};

function HTMLParser(html, handler) {
    var index, chars, match, stack = [], last = html;
    stack.last = function () {
        return this[this.length - 1];
    };
    for (var k in handler_noop) {
        if (typeof handler[k] !== 'function') {
            handler[k] = handler_noop[k];
        }
    }
    function parseStartTag(tag, tagName, rest, unary) {
        tagName = tagName.toLowerCase();

        if (block[tagName]) {
            while (stack.last() && inline[stack.last()]) {
                parseEndTag('', stack.last());
            }
        }

        if (closeSelf[tagName] && stack.last() === tagName) {
            parseEndTag('', tagName);
        }

        unary = empty[tagName] || !!unary;

        if (!unary) {
            stack.push(tagName);
        }
        var attrs = [];
        rest.replace(attr, function (match, name) {
            var value = arguments[2] ? arguments[2] :
                arguments[3] ? arguments[3] :
                arguments[4] ? arguments[4] :
                fillAttrs[name] ? name : '';
            attrs.push({
                name: name,
                value: value,
                escaped: value.replace(/(^|[^\\])"/g, '$1\\\"') //"
            });
        });
        handler.start(tagName, attrs, unary);
    }

    function parseEndTag(tag, tagName) {
        var pos;
        // If no tag name is provided, clean shop
        if (!tagName) {
            pos = 0;
        }
        // Find the closest opened tag of the same type
        else {
            for (pos = stack.length - 1; pos >= 0; pos--) {
                if (stack[pos] === tagName) {
                    break;
                }
            }
        }
        if (pos >= 0) {
            // Close all the open elements, up the stack
            for (var i = stack.length - 1; i >= pos; i--) {
                handler.end(stack[i]);
            }
            // Remove the open elements from the stack
            stack.length = pos;
        }
    }

    function cdata_text_replace(all, text) {
        text = text.replace(/<!--(.*?)-->/g, '$1').replace(/<!\[CDATA\[(.*?)\]\]>/g, '$1');
        handler.chars(text);
        return '';
    }
    // it should strip xml specification
    html = html.replace(/<\?xml[^\/>]*[\/|\?]>/g, '');

    // it should convert a floating < to &lt;
    //html = html.replace(/(>.*[^>])<([^\/].*<\/)/, '$1&lt;$2');
    //html = html.replace(/(\/>.*)<(.*<)/, '$1&lt;$2');

    // it should convert a floating > to &gt;
    //html = html.replace(/(>.*[^\-])>(.*<\/)/, '$1&gt;$2');
    //html = html.replace(/(\/>.*)>(.*<)/, '$1&gt;$2');


    while (html) {
        index = html.indexOf('<');
        var text = index < 0 ? html : html.substring(0, index);
        html = index < 0 ? '' : html.substring(index);
        //handler.chars(text.replace('>', '&gt;'));
        handler.chars(text);

        // Comment
        var comment_start = html.indexOf(comment.start);
        if (comment_start === 0) {
            index = html.indexOf(comment.end, comment_start);
            if (index >= 0) {
                var comment_text = html.substring(comment_start +
                                                  comment.start.length,
                                                  index);
                handler.comment(comment_text);
                html = html.substring(index + comment.end.length);
            }
            // end tag
        }

        // Make sure we're not in a script or style element
        if (!stack.last() || !special[stack.last()]) {
            var open_pos = html.indexOf('<');
            if (html.indexOf('</') === 0) {
                match = html.match(endTag);
                if (match) {
                    html = html.substring(match[0].length);
                    match[0].replace(endTag, parseEndTag);
                } else {
                    console.log('NO MATCH END');
                }
            // start tag
            } else if (open_pos === 0) {
                match = html.match(startTag);
                if (match) {
                    html = html.substring(match[0].length);
                    match[0].replace(startTag, parseStartTag);
                //} else {
                    //var end_pos = html.indexOf('>', open_pos);
                    //var open_pos_2 = html.indexOf('<', open_pos + 1);
                    //var tag = html.substring(0, end_pos + 1);
                    //var context = stack.last();
                    //if (open_pos_2 < end_pos) {
                        //html = '&lt;' + html.substring(open_pos + 1);
                    //} else {
                        //if (context === 'undefined' || inline[context]) {
                            //console.log(tag, context);
                        //} else {
                            //html = handler.raw_tag(tag, context) +
                                //html.substring(end_pos + 1);
                        //}
                    //}
                }
            }

        } else {
            var tagName = stack.last();
            var re = new RegExp('(.*)<\/' + tagName + '[^>]*>', 'i');
            html = html.replace(re, cdata_text_replace);
            parseEndTag('', tagName);
        }

        if (html === last) {
            throw 'Parse Error: ' + html;
        }
        last = html;
    }
    // Clean up any remaining tags
    parseEndTag();
}

function HTMLtoXML(html) {
    var results = '';
    HTMLParser(html, {
        start: function (tag, attrs, unary) {
            results += '<' + tag;
            for (var i = 0; i < attrs.length; i++) {
                results += ' ' + attrs[i].name + '="' + attrs[i].escaped + '"';
            }
            results += (unary ? ' /' : '') + '>';
        },
        end: function (tag) {
            results += '</' + tag + '>';
        },
        chars: function (text) {
            results += text;
        },
        comment: function (text) {
            results += '<!--' + text + '-->';
        }
    });
    return results;
}
function HTMLtoDOM(html, doc) {
    // There can be only one of these elements
    var one = makeMap('html,head,body,title');
    // Enforce a structure for the document
    var structure = {
        link: 'head',
        base: 'head'
    };
    if (!doc) {
        if (typeof DOMDocument !== 'undefined') {
            doc = new DOMDocument();
        }
        else if (typeof document !== 'undefined' && document.implementation && document.implementation.createDocument) {
            doc = document.implementation.createDocument('', '', null);
        }
        else if (typeof ActiveX !== 'undefined') {
            doc = new ActiveXObject('Msxml.DOMDocument');
        }
    } else {
        doc = doc.ownerDocument ||
            doc.getOwnerDocument && doc.getOwnerDocument() ||
            doc;
    }
    var elems = [],
    documentElement = doc.documentElement ||
        doc.getDocumentElement && doc.getDocumentElement();
    // If we're dealing with an empty document then we
    // need to pre-populate it with the HTML document structure
    if (!documentElement && doc.createElement)  {
        (function () {
            var html = doc.createElement('html');
            var head = doc.createElement('head');
            head.appendChild(doc.createElement('title'));
            html.appendChild(head);
            html.appendChild(doc.createElement('body'));
            doc.appendChild(html);
        }());
    }
    // Find all the unique elements
    if (doc.getElementsByTagName) {
        for (var i in one) {
            one[i] = doc.getElementsByTagName(i)[0];
        }
    }
    // If we're working with a document, inject contents into
    // the body element
    var curParentNode = one.body;
    HTMLParser(html, {
        start: function (tagName, attrs, unary) {
            // If it's a pre-built element, then we can ignore
            // its construction
            if (one[tagName]) {
                curParentNode = one[tagName];
                return;
            }
            var elem = doc.createElement(tagName);
            for (var attr in attrs) {
                elem.setAttribute(attrs[attr].name, attrs[attr].value);
            }
            if (structure[tagName] && typeof one[structure[tagName]] !== 'boolean') {
                one[structure[tagName]].appendChild(elem);
            }
            else if (curParentNode && curParentNode.appendChild) {
                curParentNode.appendChild(elem);
            }
            if (!unary) {
                elems.push(elem);
                curParentNode = elem;
            }
        },
        end: function (tag) {
            elems.length -= 1;
            // Init the new parentNode
            curParentNode = elems[elems.length - 1];
        },
        chars: function (text) {
            curParentNode.appendChild(doc.createTextNode(text));
        },
        comment: function (text) {
            // create comment node
        }
    });
    return doc;
}

module.exports = {
    HTMLParser: HTMLParser,
    HTMLtoXML: HTMLtoXML
};

