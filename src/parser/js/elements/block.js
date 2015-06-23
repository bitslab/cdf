(function() {
  "use strict";
  var audio, baseElement, div, elementConstants, headerTypeMaker, makeSimpleContainerTag, p, video;

  baseElement = require("./base");

  elementConstants = require("./constants");

  div = function() {
    var anElm;
    anElm = baseElement.base();
    anElm.name = "div";
    anElm.validChildElementTypes = elementConstants.flowTypes;
    return anElm;
  };

  video = function() {
    var anElm;
    anElm = baseElement.base();
    anElm.name = "video";
    anElm.isSelfClosing = true;
    anElm.validSettings.src = "safe url";
    anElm.validSettings.poster = "safe url";
    anElm.validSettings.autoplay = ["autoplay"];
    anElm.validSettings.controls = ["controls"];
    anElm.validSettings.loop = ["loop"];
    anElm.validSettings.preload = ["none", "metadata", "auto"];
    anElm.requiredSettings = ["src"];
    return anElm;
  };

  audio = function() {
    var anElm;
    anElm = baseElement.base();
    anElm.name = "audio";
    anElm.isSelfClosing = true;
    anElm.validSettings.src = "safe url";
    anElm.validSettings.autoplay = ["autoplay"];
    anElm.validSettings.controls = ["controls"];
    anElm.validSettings.loop = ["loop"];
    anElm.validSettings.preload = ["none", "metadata", "auto"];
    anElm.requiredSettings = ["src"];
    return anElm;
  };

  makeSimpleContainerTag = function(tagName) {
    return function() {
      var anElm;
      anElm = baseElement.base();
      anElm.name = tagName;
      anElm.validChildElementTypes = elementConstants.flowTypes;
      return anElm;
    };
  };

  p = function() {
    var anElm;
    anElm = baseElement.base();
    anElm.name = "p";
    anElm.validChildElementTypes = elementConstants.inlineTypes;
    return anElm;
  };

  headerTypeMaker = function(tagName) {
    return function() {
      var anElm;
      anElm = p();
      anElm.name = tagName;
      return anElm;
    };
  };

  module.exports = {
    div: div,
    p: p,
    h1: headerTypeMaker("h1"),
    h2: headerTypeMaker("h2"),
    h3: headerTypeMaker("h3"),
    h4: headerTypeMaker("h4"),
    h5: headerTypeMaker("h5"),
    h6: headerTypeMaker("h6"),
    article: makeSimpleContainerTag("article"),
    header: makeSimpleContainerTag("header"),
    footer: makeSimpleContainerTag("footer"),
    aside: makeSimpleContainerTag("aside"),
    video: video,
    audio: audio
  };

}).call(this);
