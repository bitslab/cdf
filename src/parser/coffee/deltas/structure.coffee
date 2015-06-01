"use strict"

# These behaviors modify the structure of a CDF document, either by adding,
# removing, or replacing subtrees of elements from the tree.


baseDelta = require "../base"
buildTools = require "../utilities/build-tools"
typeRegistry = require "../utilities/type-registry"
iter = require "../utilities/iteration"
errorHanding = require "../utilities/errors"


removeSubtreeDeltaSettings = (cdfNode, buildState) ->
  cdfType = typeRegistry.getType cdfNode
  cdfType.clientScripts.forEach (script) -> buildState.addScriptFile script

  settings =
    t: cdfType.name
    s:
      inclusive: cdfNode.s.inclusive
  return settings


# Used to remove a subtree of the CDF document.  This removes the targeted
# node and all of the children of it.
#
# Deltas of this type take the following settings:
#
#  - inclusive (bool):  whether the selected node should be remove too,
#                       or whether we're just removing the part of the tree
#                       that starts with the children of the selected nodes.
#                       Defaults to "false."
#
# {
#   t: "remove-subtree"
#   s: {
#     inclusive: false
#   }
# }
removeSubtree = ->
  base = do baseDelta.base
  base.name = "remove-subtree"
  base.clientScripts.push "deltas/structure"

  base.defaultSettings.inclusive = false
  base.validSettings.inclusive = "bool"

  base.deltaSettings = removeSubtreeDeltaSettings

  return base


# ============================== #
# ! Update-Tree Delta functions  #
# ============================== #

# Renders the HTML needed to represent a single CDF node.  It ignores any
# script files or script parameters (since, as a child of a delta, we
# should only have element nodes).
#
# @param object cdfNode
#   A CDF node, of an element type
#
# @return string
#   Returns the rendered HTML for the subtree of CDF nodes.
_renderHtmlForChildNodes = (cdfNode) ->
  subTreebuildState = do buildTools.makeBuildState
  cdfType = typeRegistry.getType cdfNode
  cdfType.render cdfNode, subTreebuildState
  do subTreebuildState.html


updateTreeDeltaSettings = (cdfNode, buildState) ->
  cdfType = typeRegistry.getType cdfNode
  cdfType.clientScripts.forEach (script) -> buildState.addScriptFile script

  children = cdfType.childNodes cdfNode
  buildStateHtml = children.map _renderHtmlForChildNodes

  settings = {}
  settings.t = cdfType.name
  settings.s =
    action: cdfNode.s.action
    change: buildStateHtml.join "\n"
  return settings


updateTreeDeltaChildNodes = (cdfNode) ->
  cdfNode.s.change


# ========================================= #
# ! Update Tree Delta validation functions  #
# ========================================= #

# The change setting of update-tree deltas must be an array of CDF element
# objects.  Below we define two validation functions (in place, to avoid
# needing to create unnecessary functions.  First, one to check that
# a single node is a valid CDF element object, and then a second function
# that applies that first function to event node in the change setting.
validateAChangeNode = (cdfNode) ->

  # Check and make sure that the type we found corresponds to a valid
  # element type.
  nodeType = typeRegistry.getType cdfNode
  if not nodeType
    error = "Found declared type of '#{nodeTypeName}' for subtree in
             update-tree delta, which does not match a known element type."
    return generateErrorWithTrace error, cdfNode

  # Next check and make sure this item is valid to include in a subtree.
  if not nodeType.mayAppearInSubtrees
    error = "CDF type '#{cdfType.name}' is not valid to include in subtrees"
    return generateErrorWithTrace error, cdfNode

  # Last, perform the same above checks on the subtrees below these items.
  children = nodeType.childNodes cdfNode
  return iter.reduce children, validateAChangeNode


validateChangeNodes = (cdfNode, buildState) ->
  iter.reduce cdfNode.s.change, validateAChangeNode


# We also provide deltas for performing several ways of adding new subtrees
# of elements to an existing document.  The different options are for appending,
# prepending, or replacing the subtree in the document
#
# Required Settings
#
#  - action (string, one of: "append", "prepend", "replace", "sub-replace")
#     Specifies whether we're adding the described tree as the last child to
#     all specified nodes (append), adding the described tree as the first
#     child to all specified nodes (prepend), replacing the subtrees
#     starting with all specified nodes (replace), or replacing the tree below
#     the selected node (replace-sub).
# - change (array)
#     An array of one or more CDF elements
#
# Below is an example of a Delta that replaces matched nodes with a new header:
#   <div><h1>new header</h1></div>
# {
#   t: "update-tree",
#   s: {
#     action: "replace",
#     change: [
#       {
#         t: "div",
#         c: [
#           {
#             t: "h1",
#             c: [
#               {text: "new header"}
#             ]
#           }
#         ]
#       }
#     ]
#   }
# }
updateSubtree = (deltaName) ->
  base = do baseDelta.base
  base.name = "update-subtree"
  base.clientScripts.push "deltas/structure"

  base.validSettings.action = ["append", "prepend", "replace", "replace-sub"]
  base.requiredSettings.push "action"

  # The change described in these deltas are an array of CDF elements to
  # add / replace, etc in the CDF tree
  base.validSettings.change = "array"
  base.requiredSettings.push "change"

  base.validationFunctions.push validateChangeNodes

  base.childNodes = updateTreeDeltaChildNodes
  base.deltaSettings = updateTreeDeltaSettings

  return base


module.exports =
  "remove-subtree": removeSubtree
  "update-subtree": updateSubtree
