"use strict"


typeRegistery = require "../utilities/type-registery"
baseElement = require "./base"
consts = require "./constants"
elementUtils = require "../utilities/elements"


html = ->
  anElm = do baseElement.base
  anElm.mayAppearInSubtrees = false
  anElm.name = "html"
  anElm.validSettings.lang = "string"
  anElm.validSettings.manifest = "local url"
  anElm.validChildElementTypes = ["head", "body"]

  anElm.render = (cdfNode, buildState) ->
    buildState.addHtml "<!DOCTYPE html>"
    buildState.addHtml baseElement.renderStartTag cdfNode

    cdfType = typeRegistery.getType cdfNode

    for childNode in cdfType.childNodes cdfNode
      childType = typeRegistery.getType childNode
      childType.render childNode, buildState

    buildState.addHtml baseElement.renderEndTag cdfNode

  return anElm


head = ->
  anElm = do baseElement.base
  anElm.mayAppearInSubtrees = false
  anElm.name = "head"
  anElm.validChildElementTypes = ["meta", "title", "link"]
  anElm.validSettings = []

  origRender = anElm.render
  anElm.render = (cdfNode, buildState) ->

    # Before we render the head element of the document, we need to insert
    # the CSP header to disable referrers.
    if not cdfNode.c
      cdfNode.c = []

    metaTag =
      t: "meta"
      s:
        "http-equiv": "Content-Security-Policy",
        "content": "referrer never"

    cdfNode.c.push metaTag
    origRender cdfNode, buildState

  return anElm


body = ->
  anElm = do baseElement.base
  anElm.mayAppearInSubtrees = false
  anElm.name = "body"
  anElm.validChildElementTypes = consts.flowTypes

  # We need to include the script tags needed for the current page before
  # we can finish the body element.
  anElm.render = (cdfNode, buildState) ->
    cdfType = typeRegistery.getType cdfNode
    buildState.addHtml baseElement.renderStartTag cdfNode

    for childNode in cdfType.childNodes cdfNode
      childType = typeRegistery.getType childNode
      childType.render childNode, buildState

    scriptFiles = do buildState.scriptFiles
    if scriptFiles.length
      buildState.addHtml "<script type='text/javascript' src='/crisp-client/js/contrib/jquery.min.js'></script>"
      buildState.addHtml "<script type='text/javascript' src='/crisp-client/js/crisp.js'></script>"
      for script in scriptFiles
        buildState.addHtml "<script type='text/javascript' src='/crisp-client/js/#{ script }.js'></script>"

      events = do buildState.events
      buildState.addHtml "<script type='text/javascript'>"
      buildState.addHtml "window.CRISP.eventInstances = #{ JSON.stringify events };"
      buildState.addHtml "</script>"
    buildState.addHtml baseElement.renderEndTag cdfNode

  return anElm


meta = ->
  anElm = do baseElement.base
  anElm.mayAppearInSubtrees = false
  anElm.name = "meta"
  anElm.isSelfClosing = true
  anElm.validSettings["http-equiv"] = "string"
  anElm.validSettings.name = "string"
  anElm.validSettings.content = "string"
  anElm.validSettings.charset = "string"
  return anElm


title = ->
  anElm = do baseElement.base
  anElm.mayAppearInSubtrees = false
  anElm.name = "title"
  anElm.validSettings = []
  anElm.validChildElementTypes = ["text"]
  return anElm


link = ->
  anElm = do baseElement.base
  anElm.mayAppearInSubtrees = false
  anElm.name = "link"
  anElm.isSelfClosing = true
  # Valid "rel" settings are specified by w3c
  # http://www.w3.org/wiki/HTML/Elements/link
  anElm.validSettings.rel = ["alternate", "archives", "author", "first", "help",
                             "icon", "index", "last", "license", "next",
                             "pingback", "prefetch", "prev", "search",
                             "stylesheet", "sidebar", "tag", "up"]
  anElm.validSettings.rev = "string"
  anElm.validSettings.href = "local url"
  anElm.validSettings.title = "string"
  anElm.validSettings.media = "string"
  anElm.validSettings.type = "string"
  return anElm


module.exports =
  html: html
  head: head
  body: body
  meta: meta
  title: title
  link: link
