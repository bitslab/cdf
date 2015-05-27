"use strict"

blockElements = require "./block"
baseElement = require "./base"
consts = require "./constants"


ul = ->
  anElm = do baseElement.base
  anElm.name = "ul"
  anElm.validChildElementTypes = ["li"]
  return anElm


ol = ->
  anElm = do ul
  anElm.name = "ol"
  return anElm


dl = ->
  anElm = do baseElement.base
  anElm.name = "dl"
  anElm.validChildElementTypes = ["dt", "dd"]
  return anElm


makeListItemType = (tagName) ->
  ->
    anElm = do blockElements.div
    anElm.name = tagName
    anElm.validChildElementTypes = consts.flowTypes
    return anElm


module.exports =
  ul: ul
  ol: ol
  dl: dl
  li: makeListItemType "li"
  dt: makeListItemType "dt"
  dd: makeListItemType "dd"
