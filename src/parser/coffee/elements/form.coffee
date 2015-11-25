"use strict"

blockElements = require "./block"
inlineElements = require "./inline"
consts = require "./constants"
arrayTools = require "../utilities/array"


baseAttrs = consts.baseAttributes
inputAttrs = ["value", "name", "readonly", "disabled"]


_addStandardInputAttrs = (anElm) ->
  anElm.validSettings.value = "string"
  anElm.validSettings.name = "string"
  anElm.validSettings.readonly = ["", "readonly"]
  anElm.validSettings.disabled = ["", "disabled"]


form = ->
  anElm = do blockElements.div
  anElm.name = "form"

  anElm.validSettings.name = "string"
  anElm.validSettings.enctype = ["application/x-www-form-urlencoded",
                                 "multipart/form-data",
                                 "text/plain"]
  anElm.validSettings.action = "local url"
  anElm.validSettings.method = ["GET", "POST"]

  anElm.validChildElementTypes = arrayTools.remove consts.flowTypes, "form"
  return anElm


input = ->
  anElm = do inlineElements.span
  anElm.name = "input"

  _addStandardInputAttrs anElm
  anElm.validSettings.type = "string"
  anElm.validSettings.checked = ["checked", ""]
  anElm.validSettings.placeholder = "string"
  anElm.validSettings.required = ["required", ""]

  anElm.isSelfClosing = true
  anElm.validChildElementTypes = []
  return anElm


select = ->
  anElm = do inlineElements.span
  anElm.name = "select"
  anElm.validSettings.name = "string"
  anElm.validSettings.disabled = ["", "disabled"]
  anElm.validChildElementTypes = ["option"]
  return anElm


option = ->
  anElm = do inlineElements.span
  anElm.name = "option"
  anElm.validSettings.selected = ["", "selected"]
  anElm.validSettings.value = "string"
  anElm.validChildElementTypes = ["text"]
  return anElm


label = ->
  anElm = do inlineElements.span
  anElm.name = "label"
  anElm.validSettings.for = "string"
  anElm.validChildElementTypes = arrayTools.remove consts.inlineTypes, "label"
  return anElm


button = ->
  anElm = do inlineElements.span
  anElm.name = "button"

  _addStandardInputAttrs anElm
  anElm.validSettings.type = ["button", "reset", "submit"]

  invalidBtnChildren = ["a", "input", "select", "textarea", "label", "form"]
  validButtonChildren = arrayTools.removeMany consts.flowTypes, invalidBtnChildren

  anElm.validChildElementTypes = validButtonChildren
  return anElm


textarea = ->
  anElm = do inlineElements.span
  anElm.name = "textarea"

  _addStandardInputAttrs anElm
  anElm.validSettings.cols = "uint"
  anElm.validSettings.rows = "uint"

  anElm.validChildElementTypes = ["text"]
  return anElm


module.exports =
  form: form
  input: input
  select: select
  option: option
  label: label
  button: button
  textarea: textarea
