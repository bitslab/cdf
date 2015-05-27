(function() {
  "use strict";
  var buildTools, deltasValidation, elementsUtils, iter, renderDocument, renderUpdate, typeRegistery, validation, _preprocessDeltaNode;

  buildTools = require("./utilities/build-tools");

  typeRegistery = require("./utilities/type-registery");

  deltasValidation = require("./deltas/validation");

  elementsUtils = require("./utilities/elements");

  validation = require("./utilities/validation");

  iter = require("./utilities/iteration");

  renderDocument = function(cdfDoc) {
    var buildState, err, error, htmlType, isSimpleCheck, isValid, preprocessError, _ref, _ref1;
    buildState = buildTools.makeBuildState();
    if (cdfDoc.t !== "html") {
      return [false, "Root of a CDF document must be HTML element"];
    }
    preprocessError = buildTools.preprocessNode(cdfDoc, buildState);
    if (preprocessError) {
      return preprocessError;
    }
    _ref = validation.checkTreeForDisallowedProperties(cdfDoc), isSimpleCheck = _ref[0], err = _ref[1];
    if (!isSimpleCheck) {
      return [false, err];
    }
    _ref1 = validation.validateNode(cdfDoc, buildState), isValid = _ref1[0], error = _ref1[1];
    if (!isValid) {
      return [false, error];
    }
    htmlType = typeRegistery.getType(cdfDoc);
    htmlType.render(cdfDoc, buildState);
    return [true, buildState.html()];
  };

  _preprocessDeltaNode = function(buildState, childNode) {
    buildTools.preprocessNode(childNode, buildState);
    return buildState;
  };

  renderUpdate = function(deltaNodes) {
    var areValid, buildState, error, renderedSettings, validationFunc, _ref;
    buildState = buildTools.makeBuildState();
    deltaNodes.reduce(_preprocessDeltaNode, buildState);
    validationFunc = validation.validateNode;
    _ref = iter.reduce(deltaNodes, validationFunc, buildState), areValid = _ref[0], error = _ref[1];
    if (!areValid) {
      return [false, error];
    }
    renderedSettings = deltaNodes.map(function(childNode) {
      var deltaType;
      deltaType = typeRegistery.getType(childNode);
      return deltaType.deltaSettings(childNode, buildState);
    });
    return [true, JSON.stringify(renderedSettings)];
  };

  module.exports = {
    renderDocument: renderDocument,
    renderUpdate: renderUpdate
  };

}).call(this);
