(function() {
  "use strict";
  var baseValidation, iter, typeRegistery, validateCssSelectorDeltaPair, validateCssSelectorDeltaPairs;

  baseValidation = require("../utilities/validation");

  typeRegistery = require("../utilities/type-registery");

  iter = require("../utilities/iteration");

  validateCssSelectorDeltaPair = function(cssSelectorDeltaPair) {
    var cssSelector, deltaInst, error, isSafeSelector, isValid, _ref, _ref1;
    if (!Array.isArray(cssSelectorDeltaPair)) {
      return [false, "Given [css selector, delta] pair is not an array, must be an array of length two.  Given value: '" + cssSelectorDeltaPair + "'."];
    }
    if (cssSelectorDeltaPair.length !== 2) {
      return [false, "[css selector, delta] pair is not the right shape, should be an array of length two: '" + cssSelectorDeltaPair + "'"];
    }
    cssSelector = cssSelectorDeltaPair[0], deltaInst = cssSelectorDeltaPair[1];
    _ref = baseValidation.isSafeCSSSelector(cssSelector), isSafeSelector = _ref[0], error = _ref[1];
    if (!isSafeSelector) {
      return [false, error];
    }
    _ref1 = baseValidation.validateNode(deltaInst), isValid = _ref1[0], error = _ref1[1];
    if (!isValid) {
      return [false, error];
    }
    return [true, null];
  };

  validateCssSelectorDeltaPairs = function(cssSelectorDeltaPairs) {
    return iter.reduce(cssSelectorDeltaPairs, validateCssSelectorDeltaPair);
  };

  module.exports = {
    validateCssSelectorDeltaPairs: validateCssSelectorDeltaPairs,
    validateCssSelectorDeltaPair: validateCssSelectorDeltaPair
  };

}).call(this);
