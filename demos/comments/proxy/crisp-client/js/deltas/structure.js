(function() {
  "use strict";
  var deltasRegistery;

  deltasRegistery = window.CRISP.deltas;

  deltasRegistery["remove-subtree"] = function(settings, domNodes) {
    var jQueryFuncName;
    jQueryFuncName = settings.inclusive ? "remove" : "empty";
    return domNodes[jQueryFuncName]();
  };

  deltasRegistery["update-subtree"] = function(settings, domNodes) {
    var changeHTML, _ref;
    changeHTML = settings.change;
    if (settings.action === "replace") {
      domNodes.replaceWith(changeHTML);
      return;
    }
    if ((_ref = settings.action) === "append" || _ref === "prepend") {
      domNodes[settings.action](changeHTML);
      return;
    }
    if (settings.action === "replace-sub") {
      domNodes.empty();
      domNodes.html(changeHTML);
    }
  };

}).call(this);
