"use strict"

buildTools = require "./utilities/build-tools"
typeRegistry = require "./utilities/type-registry"
deltasValidation = require "./deltas/validation"
elementsUtils = require "./utilities/elements"
validation = require "./utilities/validation"
iter = require "./utilities/iteration"


# Attempts to render a HTML+JS version of the document described by the
# give CDF document.
#
# Returns two values.  The first a boolean description of whether the
# rendering was successful.  If the first value is true, the second
# value is the computed HTML+JS document.  If the second value is false,
# the second value is an error message, attempting to provide
# description of why the rendering was not possible
renderDocument = (cdfDoc) ->

  buildState = do buildTools.makeBuildState

  # First just check and make sure the root of the whole thing is an HTML
  # element.  If its not, we can stop real fast.
  if cdfDoc.t isnt "html"
    return [false, "Root of a CDF document must be HTML element"]

  preprocessError = buildTools.preprocessNode cdfDoc, buildState
  if preprocessError
    return preprocessError

  [isSimpleCheck, err] = validation.checkTreeForDisallowedProperties cdfDoc
  if not isSimpleCheck
    return [false, err]

  [isValid, error] = validation.validateNode cdfDoc, buildState
  if not isValid
    return [false, error]

  # We don't need to check that this look up succeeds, since it was already
  # checked and confirmed successful in the validate call
  htmlType = typeRegistry.getType cdfDoc
  htmlType.render cdfDoc, buildState

  return [true, do buildState.html]


_preprocessDeltaNode = (buildState, childNode) ->
  buildTools.preprocessNode childNode, buildState
  return buildState


renderUpdate = (deltaNodes) ->

  buildState = do buildTools.makeBuildState
  deltaNodes.reduce _preprocessDeltaNode, buildState

  validationFunc = validation.validateNode
  [areValid, error] = iter.reduce deltaNodes, validationFunc, buildState
  if not areValid
    return [false, error]

  renderedSettings = deltaNodes.map (childNode) ->
    deltaType = typeRegistry.getType childNode
    deltaType.deltaSettings childNode, buildState

  return [true, JSON.stringify renderedSettings]


module.exports =
  renderDocument: renderDocument
  renderUpdate: renderUpdate
