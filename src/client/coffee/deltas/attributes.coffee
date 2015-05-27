"use strict"

deltasRegistry = window.CRISP.deltas

# A delta used for adding or removing classes from elements in the DOM
#
# Valid settings are as follows:
#   - action (string):  Either "add" or "remove".  Specifies whether
#                       we're adding or removing classes to elements
#   - change (array):   An array of valid CSS classes, to be added (or
#                       removed) from the found nodes.
deltasRegistry.classes = (settings, domNodes) ->
  func = if settings.action is "add" then "addClass" else "removeClass"
  cssClassNames = settings.change.join " "
  domNodes[func] cssClassNames

# This delta type defines a way of modifying the attributes of nodes in the
# document.  For example, setting the "value" of a node, or the "disabled"
# property.
#
# Valid settings are as follows:
#   - change (object):  An object, with the keys being an allowed-listed
#                       set of properties that are safe to modify
#                       in the document, and the values being either strings
#                       (for properties to set / modify) or `null`,
#                       indicating the properity should be removed.
deltasRegistry.properties = (settings, domNodes) ->
  attrsToChange = settings.change
  for attrName, attrValue of attrsToChange
    if attrValue is null
      domNodes.removeAttr attrName
    else
      domNodes.attr attrName, attrValue
