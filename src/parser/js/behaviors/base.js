(function() {
  "use strict";
  var attachDeltasToBehavior, baseBehavior, baseType, errors, typeRegistery, validators;

  validators = require("../utilities/validation");

  errors = require("../utilities/errors");

  baseType = require("../base");

  typeRegistery = require("../utilities/type-registery");

  attachDeltasToBehavior = function(cdfNode, buildState) {
    var cdfType, deltaInst, _i, _len, _ref, _results;
    cdfType = typeRegistery.getType(cdfNode);
    _ref = cdfType.childNodes(cdfNode);
    _results = [];
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      deltaInst = _ref[_i];
      _results.push(deltaInst._parent = cdfNode);
    }
    return _results;
  };

  baseBehavior = function() {
    var base;
    base = baseType.base();
    base.clientScripts = [];
    base.preprocessingFunctions.push(attachDeltasToBehavior);
    base.behaviorSettings = errors.throwUnimplementedMethod;
    return base;
  };

  module.exports = {
    base: baseBehavior
  };

}).call(this);
