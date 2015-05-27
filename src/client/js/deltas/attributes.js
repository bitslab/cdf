(function() {
  "use strict";
  var deltasRegistry;

  deltasRegistry = window.CRISP.deltas;

  deltasRegistry.classes = function(settings, domNodes) {
    var cssClassNames, func;
    func = settings.action === "add" ? "addClass" : "removeClass";
    cssClassNames = settings.change.join(" ");
    return domNodes[func](cssClassNames);
  };

  deltasRegistry.properties = function(settings, domNodes) {
    var attrName, attrValue, attrsToChange, _results;
    attrsToChange = settings.change;
    _results = [];
    for (attrName in attrsToChange) {
      attrValue = attrsToChange[attrName];
      if (attrValue === null) {
        _results.push(domNodes.removeAttr(attrName));
      } else {
        _results.push(domNodes.attr(attrName, attrValue));
      }
    }
    return _results;
  };

}).call(this);
