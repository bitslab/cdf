(function() {
  "use strict";
  var idUses, isChildOf, isImmediateChildOf, objectForId, parentElementOf;

  idUses = function(cdfObject) {
    var aSubId, child, ids, objects, _i, _len, _ref, _ref1;
    ids = {};
    if (cdfObject.a && cdfObject.a.id) {
      ids[cdfObject.a.id] = [cdfObject];
    }
    if (cdfObject.c) {
      _ref = cdfObject.c;
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        child = _ref[_i];
        _ref1 = idUses(child);
        for (aSubId in _ref1) {
          objects = _ref1[aSubId];
          if (ids[aSubId]) {
            ids[aSubId] = ids[aSubId].concat(objects);
          } else {
            ids[aSubId] = objects;
          }
        }
      }
    }
    return ids;
  };

  objectForId = function(cdfDoc, id) {
    var err, ids;
    ids = idUses(cdfDoc);
    if (!ids[id]) {
      return null;
    }
    if (ids[id].length > 1) {
      err = "More than one element in the CDF document using id " + id;
      throw Error(err);
    }
    return ids[id][0];
  };

  isChildOf = function(aCdfObject, anotherCdfObject) {
    var child, children, _i, _len;
    children = aCdfObject.c;
    if (!children) {
      return false;
    }
    for (_i = 0, _len = children.length; _i < _len; _i++) {
      child = children[_i];
      if (child === anotherCdfObject) {
        return true;
      }
      if (isChildOf(child, anotherCdfObject)) {
        return true;
      }
    }
    return false;
  };

  isImmediateChildOf = function(aCdfObject, anotherCdfObject) {
    var child, children, _i, _len;
    children = aCdfObject.c;
    if (!children) {
      return false;
    }
    for (_i = 0, _len = children.length; _i < _len; _i++) {
      child = children[_i];
      if (child === anotherCdfObject) {
        return true;
      }
    }
    return false;
  };

  parentElementOf = function(cdfObject, cdfDoc) {
    var child, childIsParentOfTarget, currentParent, _i, _len, _ref;
    currentParent = cdfDoc;
    if (isImmediateChildOf(currentParent, cdfObject)) {
      return currentParent;
    }
    _ref = currentParent.c;
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      child = _ref[_i];
      childIsParentOfTarget = parentElementOf(cdfObject, child);
      if (childIsParentOfTarget) {
        return;
      }
    }
    return null;
  };

  module.exports = {
    idUses: idUses,
    objectForId: objectForId,
    isChildOf: isChildOf,
    isImmediateChildOf: isImmediateChildOf,
    parentElementOf: parentElementOf
  };

}).call(this);
