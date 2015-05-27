"use strict"

blockElements = require "./block"
consts = require "./constants"


table = ->
  anElm = do blockElements.div
  anElm.name = "table"
  anElm.validChildElementTypes = ["thead", "tbody", "tfoot"]
  return anElm


tableElementMaker = (tagName) ->
  ->
    anElm = do blockElements.div
    anElm.name = tagName
    anElm.validChildElementTypes = ["tr"]
    return anElm


tr = ->
  anElm = do blockElements.div
  anElm.name = "tr"
  anElm.validChildElementTypes = ["td", "th"]
  return anElm


td = ->
  anElm = do blockElements.div
  anElm.name = "td"
  anElm.validSettings.colspan = "int"
  anElm.validSettings.rowspan = "int"
  anElm.validChildElementTypes = consts.flowTypes
  return anElm


th = ->
  anElm = do td
  anElm.name = "th"
  anElm.validSettings.colspan = "int"
  anElm.validSettings.rowspan = "int"
  anElm.validSettings.scope = ["col", "colgroup", "row", "rowgroup"]
  return anElm


module.exports =
  table: table
  thead: tableElementMaker "thead"
  tfoot: tableElementMaker "tfoot"
  tbody: tableElementMaker "tbody"
  tr: tr
  td: td
  th: th
