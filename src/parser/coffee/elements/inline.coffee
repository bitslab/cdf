"use strict"

baseElement = require "./base"
blockElements = require "./block"
consts = require "./constants"
escape = require "escape-html"


baseRenderFunction = baseElement.origRender


span = ->
  anElm = do baseElement.base
  anElm.name = "span"
  anElm.validChildElementTypes = consts.inlineTypes.concat ["span"]
  return anElm


aRender = (cdfNode, buildState) ->
  cdfNode.s.rel = "noreferrer"
  baseRenderFunction cdfNode, buildState

a = ->
  anElm = do span
  anElm.name = "a"

  anElm.validSettings.href = "safe url"
  anElm.validSettings.title = "string"
  anElm.validSettings.name = "string"

  baseRenderFunction = anElm.render
  anElm.render = aRender
  return anElm


makeSimpleInlineTag = (tagName) ->
  ->
    anElm = do span
    anElm.name = tagName
    return anElm


# Note that text types are represented with no tags at all.
textRender = (cdfNode, buildState) ->
  safeText = escape cdfNode.text
  buildState.addHtml safeText

text = ->
  anElm = do span
  anElm.name = "text"
  anElm.validProperties.text = "string"
  anElm.requiredProperties = ["text"]
  anElm.render = textRender
  return anElm


# Note that image types are represented with specially
# formatted div tags, which are then rendered into images
# in the client
img = ->
  anElm = do span
  anElm.name = "img"

  anElm.validSettings.alt = "string"
  anElm.validSettings.width = "string"
  anElm.validSettings.height = "string"
  anElm.validSettings.src = "safe url"

  anElm.requiredSettings = ["src"]
  anElm.isSelfClosing = true

  return anElm


module.exports =
  span: span
  a: a
  strong: makeSimpleInlineTag "strong"
  em: makeSimpleInlineTag "em"
  small: makeSimpleInlineTag "small"
  text: text
  img: img
