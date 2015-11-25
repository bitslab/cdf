(function() {
  "use strict";
  var applyDelta, behaviorRegistery, crisp, deltasRegistry, fetchValuesFromSelector;

  crisp = window.CRISP;

  behaviorRegistery = crisp.behaviors;

  deltasRegistry = crisp.deltas;

  applyDelta = function(selectorDeltaPair) {
    var cssSelector, deltaInst, deltaSettings, deltaType, domNodes;
    cssSelector = selectorDeltaPair[0], deltaInst = selectorDeltaPair[1];
    domNodes = jQuery(cssSelector);
    deltaSettings = deltaInst.s;
    deltaType = deltasRegistry[deltaInst.t];
    return deltaType(deltaSettings, domNodes);
  };

  fetchValuesFromSelector = function(cssSelector) {
    var nodes, nodesAsArray;
    nodes = jQuery(cssSelector);
    nodesAsArray = nodes.toArray();
    return nodesAsArray.map(function(item) {
      var $item;
      $item = jQuery(item);
      if ($item.is("input, select, textarea")) {
        return $item.val();
      } else {
        return $item.html();
      }
    });
  };

  behaviorRegistery.update = function(settings) {
    var cssSelector, params, valueName, _i, _len, _ref, _ref1;
    if (settings.loading) {
      settings.loading.forEach(applyDelta);
    }
    params = {};
    if (settings.values) {
      _ref = settings.values;
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        _ref1 = _ref[_i], cssSelector = _ref1[0], valueName = _ref1[1];
        params[valueName] = fetchValuesFromSelector(cssSelector);
      }
    }
    return jQuery.ajax({
      url: settings.url,
      method: settings.method,
      data: params,
      timeout: settings.timeout * 1000,
      dataType: "json"
    }).done(function(returnedDeltas) {
      var delta, deltasToApply, i, numDeltasToApply, targetsToApply, _j, _len1, _results;
      if (settings.complete) {
        settings.complete.forEach(applyDelta);
      }
      if (!returnedDeltas) {
        return;
      }
      if (!settings.targets) {
        return;
      }
      numDeltasToApply = Math.min(settings.targets.length, returnedDeltas.length);
      targetsToApply = settings.targets.slice(0, numDeltasToApply);
      deltasToApply = returnedDeltas.slice(0, numDeltasToApply);
      _results = [];
      for (i = _j = 0, _len1 = targetsToApply.length; _j < _len1; i = ++_j) {
        cssSelector = targetsToApply[i];
        delta = deltasToApply[i];
        _results.push(applyDelta([cssSelector, delta]));
      }
      return _results;
    }).fail(function() {
      if (settings.error) {
        return settings.error.forEach(applyDelta);
      }
    });
  };

}).call(this);
