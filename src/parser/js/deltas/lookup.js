(function() {
  "use strict";
  var attributesDeltas, getType, structureDeltas, typeCache;

  attributesDeltas = require("./attributes");

  structureDeltas = require("./structure");

  typeCache = {};

  getType = function(typeName) {
    var foundType;
    if (typeCache[typeName]) {
      return typeCache[typeName];
    }
    foundType = null;
    if (attributesDeltas[typeName]) {
      foundType = attributesDeltas[typeName]();
    } else if (structureDeltas[typeName]) {
      foundType = structureDeltas[typeName]();
    }
    if (!foundType) {
      throw Error("No delta type of name '" + typeName + "'");
    }
    typeCache[typeName] = foundType;
    return foundType;
  };

  module.exports = {
    getType: getType
  };

}).call(this);
