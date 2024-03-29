(function() {
  "use strict";
  var allTypes, getType, getTypeByName, instantiatedTypes, knownTypes, typeCategory, typeGroup, typeGroupName, typeName, typePath;

  allTypes = {
    "behavior": {
      "modify-timer": "behaviors/modify-timer",
      "states": "behaviors/states",
      "update": "behaviors/update"
    },
    "delta": {
      "classes": "deltas/attributes",
      "properties": "deltas/attributes",
      "remove-subtree": "deltas/structure",
      "update-subtree": "deltas/structure"
    },
    "element": {
      "video": "elements/block",
      "audio": "elements/block",
      "div": "elements/block",
      "p": "elements/block",
      "h1": "elements/block",
      "h2": "elements/block",
      "h3": "elements/block",
      "h4": "elements/block",
      "h5": "elements/block",
      "h6": "elements/block",
      "article": "elements/block",
      "header": "elements/block",
      "footer": "elements/block",
      "aside": "elements/block",
      "form": "elements/form",
      "select": "elements/form",
      "option": "elements/form",
      "label": "elements/form",
      "button": "elements/form",
      "input": "elements/form",
      "textarea": "elements/form",
      "span": "elements/inline",
      "strong": "elements/inline",
      "em": "elements/inline",
      "small": "elements/inline",
      "text": "elements/inline",
      "a": "elements/inline",
      "img": "elements/inline",
      "ul": "elements/list",
      "ol": "elements/list",
      "dl": "elements/list",
      "li": "elements/list",
      "dt": "elements/list",
      "dd": "elements/list",
      "html": "elements/structure",
      "head": "elements/structure",
      "body": "elements/structure",
      "meta": "elements/structure",
      "title": "elements/structure",
      "link": "elements/structure",
      "table": "elements/table",
      "tfoot": "elements/table",
      "tbody": "elements/table",
      "tr": "elements/table",
      "td": "elements/table",
      "thead": "elements/table",
      "th": "elements/table"
    },
    "event": {
      "click": "events/interaction",
      "disappear": "events/interaction",
      "mouseout": "events/interaction",
      "mouseleave": "events/interaction",
      "mouseover": "events/interaction",
      "mouseenter": "events/interaction",
      "doubleclick": "events/interaction",
      "appear": "events/interaction",
      "keyup": "events/interaction",
      "keydown": "events/interaction",
      "timer": "events/timer"
    }
  };

  knownTypes = {};

  for (typeGroupName in allTypes) {
    typeGroup = allTypes[typeGroupName];
    for (typeName in typeGroup) {
      typePath = typeGroup[typeName];
      knownTypes[typeName] = typePath;
    }
  }

  instantiatedTypes = {};

  getTypeByName = function(typeName) {
    var module;
    if (!knownTypes[typeName]) {
      throw "Unknown type requested: '" + typeName + "'";
    }
    if (!instantiatedTypes[typeName]) {
      module = require("../" + knownTypes[typeName]);
      instantiatedTypes[typeName] = module[typeName]();
    }
    return instantiatedTypes[typeName];
  };

  getType = function(cdfNode) {
    var error;
    typeName = typeof cdfNode.text !== "undefined" ? "text" : cdfNode.t;
    try {
      return getTypeByName(typeName);
    } catch (_error) {
      error = _error;
      throw "" + error + " for object: '" + cdfNode + "'";
    }
  };

  typeCategory = function(cdfNode) {
    var cdfType, error, _i, _len, _ref;
    try {
      cdfType = getType(cdfNode);
    } catch (_error) {
      error = _error;
      return null;
    }
    _ref = Object.keys(allTypes);
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      typeGroupName = _ref[_i];
      if (allTypes[typeGroupName][cdfType.name]) {
        return typeGroupName;
      }
    }
  };

  module.exports = {
    getType: getType,
    getTypeByName: getTypeByName,
    typeCategory: typeCategory
  };

}).call(this);
