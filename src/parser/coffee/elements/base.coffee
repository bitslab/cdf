"use strict"

# Element types describe the content of a CDF document, or the structure of the
# tree.  Element items in general follow the below pattern.
#
# t (string, required): the element "type" that this is an instance of
# s (object, optional): "settings" for configuring this instance of the type
# c (array, optional):  "child" element items that should be rendered below
#                       this element in the tree
# e (array, optional):  "event" items that describe when interactivity
#                       should be triggered with this element
#
# ----
# {
#   t: <element type name>,
#   s: {
#     id: <html id>
#     class: [<first html class>, <second html class>]
#   },
#   c: [],
#   e: [<first event object>]
# }
#

consts = require "./constants"
validators = require "../utilities/validation"
errors = require "../utilities/errors"
renderUtils = require "../utilities/render"
typeRegistry = require "../utilities/type-registry"
iter = require "../utilities/iteration"
cdfBase = require "../base"
escape = require "escape-html"
uuid = require "node-uuid"


# ================================== #
# ! Element Preprocessing Functions  #
# ================================== #

# Add a reference from this object to each of its children.  This is mainly
# used for generating traces in the tree to a problematic element, but is
# also used in some places for validation
addParentConnectionToChildren = (cdfNode, buildState) ->

  nodeType = typeRegistry.getType cdfNode
  children = nodeType.childNodes cdfNode
  children.forEach (childNode) ->
    childNode._parent = cdfNode


# Adds a unique HTML id to any elements that have events attached, where the
# element does not have one defined.
#
# @param object cdfNode
#   A reference to the CDF element is an instance of the given type
# @param object builder
#   A document builder, defined in document.coffee, that stores the HTML,
#   event definitions, and configuration settings needed to build the
#   document.
addHtmlIdsWhereEvents = (cdfNode, buildState) ->

  # If there are not events defined on this element, then there is nothing
  # we need to do here (since we don't care, for the purposes of this
  # step, if there is an HTML id defined)
  if not cdfNode.e or cdfNode.e.length is 0
    return

  # Otherwise, if there are events for this element, we need to make sure that
  # there is an HTML id defined
  if not cdfNode.s
    cdfNode.s = {}

  if not cdfNode.s.id
    cdfNode.s.id = "cdf-#{ do uuid.v4 }"


# =============================== #
# ! Element Validation Functions  #
# =============================== #


# Checks to make sure that all the IDs in the document encountered so far
# have unique HTML ids.
validateUniqueIds = (cdfNode, buildState) ->

  # If the current element does not have an ID defined on it, then it trivailly
  # does not have a pre-used id.
  if not cdfNode.s or not cdfNode.s.id
    return [true, null]

  currentElementId = cdfNode.s.id

  existingIds = buildState.config "ids"
  if existingIds[currentElementId]
    err = "Found duplicate usage of id '#{ currentElementId }'"
    return errors.generateErrorWithTrace err, cdfNode

  existingIds[currentElementId] = true
  [true, null]


# Checks that all of the child elements of this node are valid element types,
# and that they are valid for this type of element.
#
# @param object cdfNode
#   A reference to the CDF element is an instance of the given type
# @param object buildState
#   A document builder, defined in document.coffee, that stores the HTML, event
#   definitions, and configuration settings needed to build the document.
#
# @return array
#   Returns an array of length two.  The first element is a bool describing
#   whether all of the subtrees starting with the child elements of this node
#   are valid.  If it is valid, the second value will be null.  If not,
#   the second value will be a string describing the error message.
validateChildElms = (cdfNode, buildState) ->

  # If there are no children defined for this element instance, the child
  # elements are trivially valid.
  if cdfNode.c is undefined
    return [true, null]

  # Check and make sure that all the child elements have a declared type that
  # maps to a know element type.  Then, check and make sure that the subtree
  # starting with each of those child elements is also valid.
  #
  # Note that we know that if there is a "c" property, its an array due to
  # the `validateProperties` function in the base type
  cdfType = typeRegistry.getType cdfNode
  [isSuccess, error] = iter.reduce cdfNode.c, _isValidChild, cdfType
  if not isSuccess
    return errors.generateErrorWithTrace error, cdfNode
  [true, null]


# Checks to see if a child element is a valid child of a parent type (ie
# <a> can be a child of <p>, but <a> cannot be a child of <img>)
#
# @param object childElm
#   A cdf node instance of a element type
# @param object parentType
#   A cdf type instance, also of a element type
#
# @return array
#   An array of length two.
#
#   The first value is a boolean description of whether the parent accepts
#   the child's type as a vailid child.
#
#   If the first value is true, then the second value is null.  If the first
#   value if false, the second value is a string describing the error case.
_isValidChild = (childElm, parentType) ->

  # First check and and make sure that the given child element has
  # a type declared.
  try
    childType = typeRegistry.getType childElm
  catch error
    return [false, error]

  # Then, make sure that the given type is valid as a child for the current
  # instance's type
  if childType.name not in parentType.validChildElementTypes
    error = "Element of type '#{ childType.name }' is not valid as a child of
             a '#{ parentType.name }' instance"
    return [false, error]

  return [true, null]


# ===================================== #
# ! Common Element Rendering Functions  #
# ===================================== #

elementChildNodes = (cdfNode) ->

  elementNodes = if Array.isArray(cdfNode.c) then cdfNode.c else []
  eventNodes = if Array.isArray(cdfNode.e) then cdfNode.e else []
  return elementNodes.concat eventNodes


elementRender = (cdfNode, buildState) ->
  startTag = renderStartTag cdfNode
  buildState.addHtml startTag

  cdfBase.render cdfNode, buildState

  endTag = renderEndTag cdfNode
  buildState.addHtml endTag


# ========================== #
# ! Render Helper Functions  #
# ========================== #

# Takes a CDF object and returns a string representation of all the settings
# declared on the instance as HTML attributes.
#
# Note that at this point we know that some of the settings (if they exist) are
# safe to print from the `validateSettings` function in the base type
# (specifically, the `id` and `class` settings).  All other values are
# untrusted and need to be escaped before rendered as a string.
#
# @param object cdfNode
#   A reference to the CDF element is an instance of the given type
#
# @return string
#   Returns a string that is safe to display as the attributes of an HTML tag
renderSettingsAsAttributes = (cdfNode) ->

  attrString = ""

  # If there are no settings defined on this element instance, then there
  # is nothing to render.
  if cdfNode.s is undefined
    return attrString

  # Again, the classes are known to be safe already, since they were verified
  # as valid HTML classes in the `validateSettings` function from the base
  # type.
  #
  # Similarly, we know that the `id`, if it exists, is a valid HTML id
  # from the `validateSettings` function, and so does not need to be further
  # sanitized.
  attrStrings = for settingName, settingValue of cdfNode.s
    safeValue = switch
      when settingName is "id" then settingValue
      when settingName is "class" then settingValue.join " "
      else escape settingValue
    "#{ settingName }=\"#{ safeValue }\""

  return attrStrings.join(" ")


# Returns a string representation of the opening tag for the HTML element.
# For elements that have attributes, this is included in the rendered opening
# tag.
#
# @param object cdfNode
#   A reference to the CDF element is an instance of the given type
#
# @return string
#   Returns a string that is safe to display as the starting tag for a HTML
#   element.
renderStartTag = (cdfNode) ->
  cdfType = typeRegistry.getType cdfNode
  attrString = renderSettingsAsAttributes cdfNode
  if attrString
    attrString = " " + attrString
  "<#{ cdfType.name }#{ attrString }>"


# Returns a string representation of the ending tag for the HTML element.
# For elements that do not have an closing tag (ex "<img />") this is an empty
# string.
#
# @param object cdfNode
#   A reference to the CDF element is an instance of the given type
#
# @return string
#   Returns a string that depicts the closing tag of a HTML element.
renderEndTag = (cdfNode) ->
  cdfType = typeRegistry.getType cdfNode
  if cdfType.isSelfClosing then "" else "</#{ cdfType.name }>"


baseElement = ->

  base = do cdfBase.base

  # Most element types are fine to include in subtrees, so for the common
  # case we swap the default to `true`.  Some types will need to flip this
  # again to `false` (ex <html>, <body>, etc.)
  base.mayAppearInSubtrees = true

  # A boolean description of whether this type of element can contain
  # children, or must be rendered as a self closing HTML tag
  base.isSelfClosing = false

  # Element types define what other types of elements can be set as children
  # (ie "span" can be a child of "a", but "a" cannot be a child of "img")
  base.validChildElementTypes = []

  # In addition to the pre-processing functions in the base class, elements
  # also need to add in the _parent link to each child in the tree, so that
  # we can build debug traces when we encounter an error
  #
  # Also, add a function that programatically adds in html ids to
  # elements with events attached (where an explicit html id isn't already
  # defined), so that we can tie together the event definition and the
  # resulting HTML
  base.preprocessingFunctions.push addParentConnectionToChildren
  base.preprocessingFunctions.push addHtmlIdsWhereEvents

  # In addition to the validation functions provided by the base type,
  # element types also need to check and make sure that the subtrees below
  # them are valid as well
  # base.validationFunctions.push validateUniqueIds
  base.validationFunctions.push validateChildElms

  # In addition to the settings defined in the base type, element types
  # can also contain child elements (an array of element definitions) in
  # property "c" (for children), and event definitions (an array of event
  # definitions) in property "e"
  base.validProperties.e = "array:object"
  base.validProperties.c = "array:object"

  # Also add some settings that will be common to all elements (these can
  # be added to in the specific element type definitions).
  base.validSettings =
    id: "html id"
    class: "array:html class"
    role: "string"
    tabindex: "uint"

  base.childNodes = elementChildNodes
  base.render = elementRender

  return base


module.exports =
  renderStartTag: renderStartTag
  renderEndTag: renderEndTag
  base: baseElement
