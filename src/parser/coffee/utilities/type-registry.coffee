"use strict"

allTypes =
  "behavior":
    "modify-timer": "behaviors/modify-timer"
    "states": "behaviors/states"
    "update": "behaviors/update"
  "delta":
    "classes": "deltas/attributes"
    "properties": "deltas/attributes"
    "remove-subtree": "deltas/structure"
    "update-subtree": "deltas/structure"
  "element":
    "div": "elements/block"
    "p": "elements/block"
    "h1": "elements/block"
    "h2": "elements/block"
    "h3": "elements/block"
    "h4": "elements/block"
    "h5": "elements/block"
    "h6": "elements/block"
    "article": "elements/block"
    "header": "elements/block"
    "footer": "elements/block"
    "aside": "elements/block"
    "form": "elements/form"
    "select": "elements/form"
    "option": "elements/form"
    "label": "elements/form"
    "button": "elements/form"
    "input": "elements/form"
    "textarea": "elements/form"
    "span": "elements/inline"
    "strong": "elements/inline"
    "em": "elements/inline"
    "small": "elements/inline"
    "text": "elements/inline"
    "a": "elements/inline"
    "img": "elements/inline"
    "ul": "elements/list"
    "ol": "elements/list"
    "dl": "elements/list"
    "li": "elements/list"
    "dt": "elements/list"
    "dd": "elements/list"
    "html": "elements/structure"
    "head": "elements/structure"
    "body": "elements/structure"
    "meta": "elements/structure"
    "title": "elements/structure"
    "link": "elements/structure"
    "table": "elements/table"
    "tfoot": "elements/table"
    "tbody": "elements/table"
    "tr": "elements/table"
    "td": "elements/table"
    "thead": "elements/table"
    "th": "elements/table"
  "event":
    "click": "events/interaction"
    "disappear": "events/interaction"
    "mouseout": "events/interaction"
    "mouseleave": "events/interaction"
    "mouseover": "events/interaction"
    "mouseenter": "events/interaction"
    "doubleclick": "events/interaction"
    "appear": "events/interaction"
    "keyup": "events/interaction"
    "keydown": "events/interaction"
    "timer": "events/timer"


knownTypes = {}
for typeGroupName, typeGroup of allTypes
  for typeName, typePath of typeGroup
    knownTypes[typeName] = typePath


instantiatedTypes = {}


getTypeByName = (typeName) ->
  if not knownTypes[typeName]
    throw "Unknown type requested: '#{typeName}'"

  if not instantiatedTypes[typeName]
    module = require "../#{ knownTypes[typeName] }"
    instantiatedTypes[typeName] = do module[typeName]

  return instantiatedTypes[typeName]


# Returns the type definition for the given CDF node, if one exists.
# Throws an exception if the type definition could not be determined
# for the given object.
#
# @param object cdfNode
#   An instance object of a CDF type
#
# @return object
#   A CDF type definition object
getType = (cdfNode) ->
  # Purely as a convenience to CDF document authors, "text" elements are not
  # require to advertise their type as type "text".  We just assume any
  # node with a .text property is of type txt.
  typeName = if typeof cdfNode.text isnt "undefined" then "text" else cdfNode.t

  try
    getTypeByName typeName
  catch error
    throw "#{ error } for object: '#{ cdfNode }'"


# Returns the category of the type of the given CDF instance, or null if the
# type couldn't be determined.
#
# @param object cdfNode
#   An instance object of a CDF type
#
# @return string|null
#   Null if the given object isn't a valid CDF type instance, otherwise
#   one of the following strings: "event", "element", "delta", "behavior"
typeCategory = (cdfNode) ->

  try
    cdfType = getType cdfNode
  catch error
    return null

  for typeGroupName in Object.keys allTypes
    if allTypes[typeGroupName][cdfType.name]
      return typeGroupName


module.exports =
  getType: getType
  getTypeByName: getTypeByName
  typeCategory: typeCategory
