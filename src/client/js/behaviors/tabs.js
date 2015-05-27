(function() {
  var __hasProp = {}.hasOwnProperty;

  jQuery(function($) {
    return window.CRISP.behaviorSettings.tabs.forEach(function(settings) {
      var $tab, $tabsElm, $target, tabId, tabs, tabsId, targetId, targets, _ref;
      tabsId = settings.id;
      $tabsElm = $("#" + tabsId);
      targets = {};
      tabs = {};
      _ref = settings.map;
      for (tabId in _ref) {
        if (!__hasProp.call(_ref, tabId)) continue;
        targetId = _ref[tabId];
        $tab = $("#" + tabId);
        $target = $("#" + targetId);
        targets[tabId] = $target;
        tabs[tabId] = $tab;
        $tab.click(function() {
          var $targetElm, aTabId, clickedTabId;
          clickedTabId = $(this).attr("id");
          for (aTabId in targets) {
            if (!__hasProp.call(targets, aTabId)) continue;
            $targetElm = targets[aTabId];
            if (aTabId === clickedTabId) {
              tabs[aTabId].addClass("active");
              $targetElm.show();
            } else {
              tabs[aTabId].removeClass("active");
              $targetElm.hide();
            }
          }
          return false;
        });
      }
      return $tabsElm.find("> li:first").click();
    });
  });

}).call(this);
