(function() {
  "use strict";
  var baseElement, blockElements, consts, dl, makeListItemType, ol, ul;

  blockElements = require("./block");

  baseElement = require("./base");

  consts = require("./constants");

  ul = function() {
    var anElm;
    anElm = baseElement.base();
    anElm.name = "ul";
    anElm.validChildElementTypes = ["li"];
    return anElm;
  };

  ol = function() {
    var anElm;
    anElm = ul();
    anElm.name = "ol";
    return anElm;
  };

  dl = function() {
    var anElm;
    anElm = baseElement.base();
    anElm.name = "dl";
    anElm.validChildElementTypes = ["dt", "dd"];
    return anElm;
  };

  makeListItemType = function(tagName) {
    return function() {
      var anElm;
      anElm = blockElements.div();
      anElm.name = tagName;
      anElm.validChildElementTypes = consts.flowTypes;
      return anElm;
    };
  };

  module.exports = {
    ul: ul,
    ol: ol,
    dl: dl,
    li: makeListItemType("li"),
    dt: makeListItemType("dt"),
    dd: makeListItemType("dd")
  };

}).call(this);
