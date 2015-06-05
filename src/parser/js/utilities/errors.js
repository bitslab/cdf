(function() {
  "use strict";
  var generateErrorWithTrace, generatePathFromRoot, throwExceptionWithTrace, throwUnimplementedMethod, util;

  util = require("util");

  throwUnimplementedMethod = function(cdfType, buildState) {
    throw "Need Unimplemented function in '" + cdfType.name + "' type";
  };

  generatePathFromRoot = function(cdfNode) {
    var currentDepth, currentNode, indentedNodeNames, node, nodeName, nodes, tabsForDepth, tabsForDepthCounter;
    nodes = [];
    currentNode = cdfNode;
    while (currentNode) {
      nodes.push(currentNode);
      currentNode = currentNode._parent;
    }
    nodes.reverse();
    currentDepth = 0;
    indentedNodeNames = (function() {
      var _i, _len, _results;
      _results = [];
      for (_i = 0, _len = nodes.length; _i < _len; _i++) {
        node = nodes[_i];
        nodeName = node.t;
        tabsForDepthCounter = currentDepth;
        tabsForDepth = (function() {
          var _results1;
          _results1 = [];
          while (tabsForDepthCounter-- > 0) {
            _results1.push("\t");
          }
          return _results1;
        })();
        currentDepth += 1;
        _results.push(tabsForDepth.join("") + nodeName);
      }
      return _results;
    })();
    return indentedNodeNames.join(" ->\n");
  };

  generateErrorWithTrace = function(error, cdfNode) {
    var errorString, treeTraceString;
    treeTraceString = generatePathFromRoot(cdfNode);
    errorString = "" + error + " \n \nElement \n--------- \n" + (util.inspect(cdfNode)) + " \n \nTrace \n---------- \n" + treeTraceString;
    return [false, errorString];
  };

  throwExceptionWithTrace = function(exception, cdfNode) {
    var isError, origExceptionDesc, wrappedErrorDesc, _ref;
    origExceptionDesc = exception.toString();
    _ref = generateErrorWithTrace(origExceptionDesc, cdfNode), isError = _ref[0], wrappedErrorDesc = _ref[1];
    throw new Error(wrappedErrorDesc);
  };

  module.exports = {
    throwExceptionWithTrace: throwExceptionWithTrace,
    generateErrorWithTrace: generateErrorWithTrace,
    throwUnimplementedMethod: throwUnimplementedMethod
  };

}).call(this);
