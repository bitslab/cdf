(function() {
  "use strict";
  var mergeScripts, mergeSettingsParams,
    __indexOf = [].indexOf || function(item) { for (var i = 0, l = this.length; i < l; i++) { if (i in this && this[i] === item) return i; } return -1; };

  mergeSettingsParams = function(aBehavior, bBehavior) {
    return aBehavior.concat(bBehavior);
  };

  mergeScripts = function(aScripts, bScripts) {
    var combined, elm, item, _i, _j, _len, _len1, _ref;
    combined = [];
    _ref = [aScripts, bScripts];
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      item = _ref[_i];
      for (_j = 0, _len1 = item.length; _j < _len1; _j++) {
        elm = item[_j];
        if (__indexOf.call(combined, item) < 0) {
          combined.push(item);
        }
      }
    }
    return combined;
  };

}).call(this);
