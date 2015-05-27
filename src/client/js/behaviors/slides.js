(function() {
  jQuery(function($) {
    return window.CRISP.behaviorSettings.slides.forEach(function(settings) {
      var activeClass, advanceSlider, advancerElements, assignNewActiveElement, autoTimeoutId, childElements, currentElement, currentIndex, doNextAutoAdvance, endRangeClass, initialChildIndex, lastChildIndex, msTillNextAutoAdvance, retreatSlider, retreatererElements, scheduleNextAutoAdvance, shouldWrap, slideElements;
      slideElements = $("#" + settings.id);
      initialChildIndex = settings.initial;
      activeClass = settings["class"];
      msTillNextAutoAdvance = settings.autoadvance;
      endRangeClass = settings.endRangeClass;
      autoTimeoutId = void 0;
      if (settings.advancer) {
        advancerElements = $("." + settings.advancer);
        advancerElements.click(function() {
          advanceSlider();
          return false;
        });
      }
      if (settings.retreater) {
        retreatererElements = $("." + settings.retreater);
        retreatererElements.click(function() {
          retreatSlider();
          return false;
        });
      }
      shouldWrap = settings.wrap;
      childElements = slideElements.children();
      lastChildIndex = childElements.length - 1;
      currentIndex = initialChildIndex;
      currentElement = $($(childElements).get(initialChildIndex));
      assignNewActiveElement = function(newElementIndex) {
        currentElement.removeClass(activeClass);
        currentElement = $($(childElements).get(newElementIndex));
        currentElement.addClass(activeClass);
        currentIndex = newElementIndex;
        if (!shouldWrap) {
          if (settings.advancer) {
            if (currentIndex === lastChildIndex) {
              advancerElements.addClass(endRangeClass);
            } else {
              advancerElements.removeClass(endRangeClass);
            }
          }
          if (settings.retreater) {
            if (currentIndex === 0) {
              retreatererElements.addClass(endRangeClass);
            } else {
              retreatererElements.removeClass(endRangeClass);
            }
          }
        }
        window.clearTimeout(autoTimeoutId);
        return true;
      };
      advanceSlider = function() {
        var newElementIndex;
        newElementIndex = null;
        if (currentIndex === lastChildIndex) {
          if (!shouldWrap) {
            return false;
          } else {
            newElementIndex = 0;
          }
        } else {
          newElementIndex = currentIndex + 1;
        }
        return assignNewActiveElement(newElementIndex);
      };
      retreatSlider = function() {
        var newElementIndex;
        if (currentIndex === 0) {
          if (!shouldWrap) {
            return false;
          } else {
            newElementIndex = childElements.length - 1;
          }
        } else {
          newElementIndex = currentIndex - 1;
        }
        return assignNewActiveElement(newElementIndex);
      };
      doNextAutoAdvance = function() {
        if (advanceSlider()) {
          return scheduleNextAutoAdvance();
        }
      };
      scheduleNextAutoAdvance = function() {
        window.clearTimeout(autoTimeoutId);
        if (msTillNextAutoAdvance === 0) {
          return;
        }
        return autoTimeoutId = window.setTimeout(doNextAutoAdvance, msTillNextAutoAdvance);
      };
      assignNewActiveElement(initialChildIndex);
      return scheduleNextAutoAdvance();
    });
  });

}).call(this);
