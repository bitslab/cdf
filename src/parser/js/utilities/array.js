(function() {
  "use strict";
  var objectToArray, remove, removeMany;

  objectToArray = function(anObject) {
    var keyNames;
    keyNames = Object.keys(anObject);
    return keyNames.map(function(aKeyName) {
      return [aKeyName, anObject[aKeyName]];
    });
  };

  remove = function(anArray, elm) {
    var indexOfElm;
    indexOfElm = anArray.indexOf(elm);
    switch (indexOfElm) {
      case -1:
        return anArray.slice(0);
      case 0:
        return anArray.slice(1);
      case anArray.length - 1:
        return anArray.slice(0);
      default:
        return anArray.slice(0, indexOfElm).concat(anArray.slice(indexOfElm + 1));
    }
  };

  removeMany = function(anArray, elements) {
    return elements.reduce(remove, anArray);
  };

  module.exports = {
    objectToArray: objectToArray,
    remove: remove,
    removeMany: removeMany
  };

}).call(this);
