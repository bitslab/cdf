(function() {
  "use strict";
  var baseElement, body, consts, elementUtils, head, html, link, meta, title, typeRegistry;

  typeRegistry = require("../utilities/type-registry");

  baseElement = require("./base");

  consts = require("./constants");

  elementUtils = require("../utilities/elements");

  html = function() {
    var anElm;
    anElm = baseElement.base();
    anElm.mayAppearInSubtrees = false;
    anElm.name = "html";
    anElm.validSettings.lang = "string";
    anElm.validSettings.manifest = "local url";
    anElm.validChildElementTypes = ["head", "body"];
    anElm.render = function(cdfNode, buildState) {
      var cdfType, childNode, childType, _i, _len, _ref;
      buildState.addHtml("<!DOCTYPE html>");
      buildState.addHtml(baseElement.renderStartTag(cdfNode));
      cdfType = typeRegistry.getType(cdfNode);
      _ref = cdfType.childNodes(cdfNode);
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        childNode = _ref[_i];
        childType = typeRegistry.getType(childNode);
        childType.render(childNode, buildState);
      }
      return buildState.addHtml(baseElement.renderEndTag(cdfNode));
    };
    return anElm;
  };

  head = function() {
    var anElm, origRender;
    anElm = baseElement.base();
    anElm.mayAppearInSubtrees = false;
    anElm.name = "head";
    anElm.validChildElementTypes = ["meta", "title", "link"];
    anElm.validSettings = [];
    origRender = anElm.render;
    anElm.render = function(cdfNode, buildState) {
      var metaTag;
      if (!cdfNode.c) {
        cdfNode.c = [];
      }
      metaTag = {
        t: "meta",
        s: {
          "http-equiv": "Content-Security-Policy",
          "content": "referrer never"
        }
      };
      cdfNode.c.push(metaTag);
      return origRender(cdfNode, buildState);
    };
    return anElm;
  };

  body = function() {
    var anElm;
    anElm = baseElement.base();
    anElm.mayAppearInSubtrees = false;
    anElm.name = "body";
    anElm.validChildElementTypes = consts.flowTypes;
    anElm.render = function(cdfNode, buildState) {
      var cdfType, childNode, childType, events, script, scriptFiles, _i, _j, _len, _len1, _ref;
      cdfType = typeRegistry.getType(cdfNode);
      buildState.addHtml(baseElement.renderStartTag(cdfNode));
      _ref = cdfType.childNodes(cdfNode);
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        childNode = _ref[_i];
        childType = typeRegistry.getType(childNode);
        childType.render(childNode, buildState);
      }
      scriptFiles = buildState.scriptFiles();
      if (scriptFiles.length) {
        buildState.addHtml("<script type='text/javascript' src='/crisp-client/js/contrib/jquery.min.js'></script>");
        buildState.addHtml("<script type='text/javascript' src='/crisp-client/js/crisp.js'></script>");
        for (_j = 0, _len1 = scriptFiles.length; _j < _len1; _j++) {
          script = scriptFiles[_j];
          buildState.addHtml("<script type='text/javascript' src='/crisp-client/js/" + script + ".js'></script>");
        }
        events = buildState.events();
        buildState.addHtml("<script type='text/javascript'>");
        buildState.addHtml("window.CRISP.eventInstances = " + (JSON.stringify(events)) + ";");
        buildState.addHtml("</script>");
      }
      return buildState.addHtml(baseElement.renderEndTag(cdfNode));
    };
    return anElm;
  };

  meta = function() {
    var anElm;
    anElm = baseElement.base();
    anElm.mayAppearInSubtrees = false;
    anElm.name = "meta";
    anElm.isSelfClosing = true;
    anElm.validSettings["http-equiv"] = "string";
    anElm.validSettings.name = "string";
    anElm.validSettings.content = "string";
    anElm.validSettings.charset = "string";
    return anElm;
  };

  title = function() {
    var anElm;
    anElm = baseElement.base();
    anElm.mayAppearInSubtrees = false;
    anElm.name = "title";
    anElm.validSettings = [];
    anElm.validChildElementTypes = ["text"];
    return anElm;
  };

  link = function() {
    var anElm;
    anElm = baseElement.base();
    anElm.mayAppearInSubtrees = false;
    anElm.name = "link";
    anElm.isSelfClosing = true;
    anElm.validSettings.rel = ["alternate", "archives", "author", "first", "help", "icon", "index", "last", "license", "next", "pingback", "prefetch", "prev", "search", "stylesheet", "sidebar", "tag", "up"];
    anElm.validSettings.href = "local url";
    anElm.validSettings.title = "string";
    anElm.validSettings.media = "string";
    anElm.validSettings.type = "string";
    return anElm;
  };

  module.exports = {
    html: html,
    head: head,
    body: body,
    meta: meta,
    title: title,
    link: link
  };

}).call(this);
