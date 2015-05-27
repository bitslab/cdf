(function() {
  "use strict";
  var behaviorRegistery, crisp, makeAState, makeStateSet, stateSetRegistery;

  crisp = window.CRISP;

  behaviorRegistery = crisp.behaviors;

  stateSetRegistery = {};

  behaviorRegistery.states = function(settings) {
    var stateId, stateSetObject;
    stateId = settings.stateId;
    if (!stateId) {
      throw "Missing an identifier for state behaivor";
    }
    stateSetObject = stateSetRegistery[stateId];
    if (settings.index !== void 0 && settings.index !== null) {
      return stateSetObject.setState(settings.index);
    } else if (settings.advance) {
      return stateSetObject.advance();
    } else {
      return stateSetObject.retreat();
    }
  };

  behaviorRegistery.states.register = function(settings) {
    var aStateDef, boundStateSet, commonState, isWrapping, stateDefinitions, stateId, stateSetObject;
    stateId = settings.stateId;
    if (!stateId) {
      throw "Missing an identifier for state behaivor";
    }
    stateSetObject = stateSetRegistery[stateId];
    if (stateSetObject) {
      return;
    }
    stateDefinitions = settings.states;
    if (!stateDefinitions) {
      throw "Reference to undefined state definition '" + stateId + "'";
    }
    isWrapping = settings.wrap;
    commonState = settings.common;
    boundStateSet = (function() {
      var _i, _len, _results;
      _results = [];
      for (_i = 0, _len = stateDefinitions.length; _i < _len; _i++) {
        aStateDef = stateDefinitions[_i];
        _results.push(makeAState(aStateDef));
      }
      return _results;
    })();
    stateSetRegistery[stateId] = makeStateSet(boundStateSet, isWrapping, commonState);
    if (settings.initial !== void 0) {
      return stateSetRegistery[stateId].setState(settings.initial);
    }
  };

  makeStateSet = function(states, wraps, commonState) {
    var advanceStateIndex, applyCurrentState, checkIsValidStateIndex, commonStateFunc, currentStateIndex, isFirstState, isLastState, numStates, retreatStateIndex, stateSetObject;
    if (wraps == null) {
      wraps = false;
    }
    if (commonState == null) {
      commonState = null;
    }
    commonStateFunc = commonState ? makeAState(commonState) : null;
    numStates = states.length;
    currentStateIndex = 0;
    isLastState = function() {
      return currentStateIndex === numStates - 1;
    };
    isFirstState = function() {
      return currentStateIndex === 0;
    };
    advanceStateIndex = function() {
      if (isLastState()) {
        return currentStateIndex = 0;
      } else {
        return currentStateIndex += 1;
      }
    };
    retreatStateIndex = function() {
      if (isFirstState()) {
        return currentStateIndex = numStates - 1;
      } else {
        return currentStateIndex -= 1;
      }
    };
    applyCurrentState = function() {
      if (commonStateFunc) {
        commonStateFunc();
      }
      return states[currentStateIndex]();
    };
    checkIsValidStateIndex = function(aStateIndex, wrapDirection) {
      var isAdvancing, isRetreating;
      if (typeof aStateIndex !== "number") {
        throw "Invalid requested state index.  Not a number: '" + aStateIndex + "'";
      }
      if (Math.floor(aStateIndex !== aStateIndex)) {
        throw "Invalid requested state index.  Not an integer: '" + aStateIndex + "'";
      }
      if (aStateIndex < 0) {
        throw "Invalid requested state index.  Less than zero: '" + aStateIndex + "'";
      }
      if (aStateIndex >= numStates) {
        throw "Invalid requested state index '" + aStateIndex + "'.  Larger than number of states: '" + numStates + "'";
      }
      if (!wrapDirection) {
        return true;
      }
      isAdvancing = (function() {
        switch (false) {
          case wrapDirection !== "advancing":
            return true;
          case wrapDirection !== "retreating":
            return false;
          default:
            return null;
        }
      })();
      if (isAdvancing && aStateIndex < currentStateIndex && !wraps) {
        throw "Invalid requested state index.  Requested index '" + aStateIndex + "' is before the current state index '" + currentStateIndex + "' and we're not configured to wrap";
      }
      isRetreating = !isAdvancing;
      if (isRetreating && aStateIndex > currentStateIndex && !wraps) {
        throw "Invalid requested state index.  Requested index '" + aStateIndex + "' is after the current state index '" + currentStateIndex + "' and we're not configured to wrap";
      }
      return true;
    };
    stateSetObject = {
      advance: function() {
        if (isLastState() && !wraps) {
          return;
        }
        advanceStateIndex();
        return applyCurrentState();
      },
      retreat: function() {
        if (isFirstState() && !wraps) {
          return;
        }
        retreatStateIndex();
        return applyCurrentState();
      },
      advanceTo: function(newStateIndex) {
        var _results;
        checkIsValidStateIndex(newStateIndex, "advancing");
        _results = [];
        while (currentStateIndex !== newStateIndex) {
          _results.push(stateSetObject.advance());
        }
        return _results;
      },
      retreatTo: function(newStateIndex) {
        var _results;
        checkIsValidStateIndex(newStateIndex, "retreating");
        _results = [];
        while (currentStateIndex !== newStateIndex) {
          _results.push(stateSetObject.retreat());
        }
        return _results;
      },
      setState: function(newStateIndex) {
        checkIsValidStateIndex(newStateIndex);
        currentStateIndex = newStateIndex;
        return applyCurrentState();
      }
    };
    return stateSetObject;
  };

  makeAState = function(aStateDef) {
    var boundFunctions, cssSelector, deltaInst, _i, _len, _ref;
    boundFunctions = [];
    for (_i = 0, _len = aStateDef.length; _i < _len; _i++) {
      _ref = aStateDef[_i], cssSelector = _ref[0], deltaInst = _ref[1];
      boundFunctions.push(crisp.utils.bindDelta(cssSelector, deltaInst));
    }
    return function() {
      var func, _j, _len1, _results;
      _results = [];
      for (_j = 0, _len1 = boundFunctions.length; _j < _len1; _j++) {
        func = boundFunctions[_j];
        _results.push(func());
      }
      return _results;
    };
  };

}).call(this);
