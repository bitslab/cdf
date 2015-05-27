(function() {
  "use strict";
  var allTypeGroups, blocks, cdfTypeCache, forms, getType, inlines, lists, structures, tables;

  blocks = require("./block");

  forms = require("./form");

  inlines = require("./inline");

  lists = require("./list");

  tables = require("./table");

  structures = require("./structure");

  allTypeGroups = [blocks, forms, inlines, lists, tables, structures];

  cdfTypeCache = {};

  getType = function(typeName) {
    var foundType, typeGroup, _i, _len;
    if (cdfTypeCache[typeName]) {
      return cdfTypeCache[typeName];
    }
    foundType = null;
    for (_i = 0, _len = allTypeGroups.length; _i < _len; _i++) {
      typeGroup = allTypeGroups[_i];
      if (typeGroup[typeName]) {
        foundType = typeGroup[typeName]();
        break;
      }
    }
    if (foundType === null) {
      throw Error("No type definition for type '" + typeName + "'");
    }
    cdfTypeCache[typeName] = foundType;
    return foundType;
  };

  module.exports.getType = getType;

}).call(this);
