"use strict"

baseElement = require "./base"
elementConstants = require "./constants"


div = ->
  anElm = do baseElement.base
  anElm.name = "div"
  anElm.validChildElementTypes = elementConstants.flowTypes
  return anElm


makeSimpleContainerTag = (tagName) ->
  ->
    anElm = do baseElement.base
    anElm.name = tagName
    anElm.validChildElementTypes = elementConstants.flowTypes
    return anElm


p = ->
  anElm = do baseElement.base
  anElm.name = "p"
  anElm.validChildElementTypes = elementConstants.inlineTypes
  return anElm


headerTypeMaker = (tagName) ->
  ->
    anElm = do p
    anElm.name = tagName
    return anElm


module.exports =
  div: div
  p: p
  h1: headerTypeMaker "h1"
  h2: headerTypeMaker "h2"
  h3: headerTypeMaker "h3"
  h4: headerTypeMaker "h4"
  h5: headerTypeMaker "h5"
  h6: headerTypeMaker "h6"
  article: makeSimpleContainerTag "article"
  header: makeSimpleContainerTag "header"
  footer: makeSimpleContainerTag "footer"
  aside: makeSimpleContainerTag "aside"
