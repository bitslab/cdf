(function() {
  "use strict";
  var a, aRender, baseElement, baseRenderFunction, blockElements, consts, escape, img, makeSimpleInlineTag, span, text, textRender;

  baseElement = require("./base");

  blockElements = require("./block");

  consts = require("./constants");

  escape = require("escape-html");

  baseRenderFunction = baseElement.origRender;

  span = function() {
    var anElm;
    anElm = baseElement.base();
    anElm.name = "span";
    anElm.validChildElementTypes = consts.inlineTypes.concat(["span"]);
    return anElm;
  };

  aRender = function(cdfNode, buildState) {
    cdfNode.s.rel = "noreferrer";
    return baseRenderFunction(cdfNode, buildState);
  };

  a = function() {
    var anElm;
    anElm = span();
    anElm.name = "a";
    anElm.validSettings.href = "safe url";
    anElm.validSettings.title = "string";
    anElm.validSettings.name = "string";
    baseRenderFunction = anElm.render;
    anElm.render = aRender;
    return anElm;
  };

  makeSimpleInlineTag = function(tagName) {
    return function() {
      var anElm;
      anElm = span();
      anElm.name = tagName;
      return anElm;
    };
  };

  textRender = function(cdfNode, buildState) {
    var safeText;
    safeText = escape(cdfNode.text);
    return buildState.addHtml(safeText);
  };

  text = function() {
    var anElm;
    anElm = span();
    anElm.name = "text";
    anElm.validProperties.text = "string";
    anElm.requiredProperties = ["text"];
    anElm.render = textRender;
    return anElm;
  };

  img = function() {
    var anElm;
    anElm = span();
    anElm.name = "img";
    anElm.validSettings.alt = "string";
    anElm.validSettings.width = "string";
    anElm.validSettings.height = "string";
    anElm.validSettings.src = "safe url";
    anElm.requiredSettings = ["src"];
    anElm.isSelfClosing = true;
    return anElm;
  };

  module.exports = {
    span: span,
    a: a,
    strong: makeSimpleInlineTag("strong"),
    em: makeSimpleInlineTag("em"),
    small: makeSimpleInlineTag("small"),
    text: text,
    img: img
  };

}).call(this);
