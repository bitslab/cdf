(function() {
  "use strict";
  var blockElements, consts, table, tableElementMaker, td, th, tr;

  blockElements = require("./block");

  consts = require("./constants");

  table = function() {
    var anElm;
    anElm = blockElements.div();
    anElm.name = "table";
    anElm.validChildElementTypes = ["thead", "tbody", "tfoot"];
    return anElm;
  };

  tableElementMaker = function(tagName) {
    return function() {
      var anElm;
      anElm = blockElements.div();
      anElm.name = tagName;
      anElm.validChildElementTypes = ["tr"];
      return anElm;
    };
  };

  tr = function() {
    var anElm;
    anElm = blockElements.div();
    anElm.name = "tr";
    anElm.validChildElementTypes = ["td", "th"];
    return anElm;
  };

  td = function() {
    var anElm;
    anElm = blockElements.div();
    anElm.name = "td";
    anElm.validSettings.colspan = "uint";
    anElm.validSettings.rowspan = "uint";
    anElm.validChildElementTypes = consts.flowTypes;
    return anElm;
  };

  th = function() {
    var anElm;
    anElm = td();
    anElm.name = "th";
    anElm.validSettings.colspan = "uint";
    anElm.validSettings.rowspan = "uint";
    anElm.validSettings.scope = ["col", "colgroup", "row", "rowgroup"];
    return anElm;
  };

  module.exports = {
    table: table,
    thead: tableElementMaker("thead"),
    tfoot: tableElementMaker("tfoot"),
    tbody: tableElementMaker("tbody"),
    tr: tr,
    td: td,
    th: th
  };

}).call(this);
