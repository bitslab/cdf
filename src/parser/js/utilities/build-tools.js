(function() {
  "use strict";
  var errors, makeBuildState, preprocessNode, typeRegistry;

  typeRegistry = require("./type-registry");

  errors = require("./errors");

  preprocessNode = function(cdfNode, buildState) {
    var cdfType, children, error, func, preProcessFuncs, _i, _len;
    try {
      cdfType = typeRegistry.getType(cdfNode);
    } catch (_error) {
      error = _error;
      return errors.generateErrorWithTrace(error, cdfNode);
    }
    preProcessFuncs = cdfType.preprocessingFunctions;
    for (_i = 0, _len = preProcessFuncs.length; _i < _len; _i++) {
      func = preProcessFuncs[_i];
      func(cdfNode, buildState);
    }
    children = cdfType.childNodes(cdfNode);
    return children.forEach(function(childNode) {
      return preprocessNode(childNode, buildState);
    });
  };

  makeBuildState = function() {
    var _config, _events, _html, _scripts;
    _html = [];
    _events = [];
    _scripts = {};
    _config = {};
    return {
      html: function() {
        return _html.join("\n");
      },
      addHtml: function(newHtml) {
        return _html.push(newHtml);
      },
      events: function() {
        return _events;
      },
      addEvent: function(newEvent) {
        return _events.push(newEvent);
      },
      scriptFiles: function() {
        return Object.keys(_scripts);
      },
      addScriptFile: function(newScriptFile) {
        return _scripts[newScriptFile] = true;
      },
      config: function(key) {
        if (!_config[key]) {
          _config[key] = {};
        }
        return _config[key];
      }
    };
  };

  module.exports = {
    preprocessNode: preprocessNode,
    makeBuildState: makeBuildState
  };

}).call(this);
