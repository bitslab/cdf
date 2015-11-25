"use strict"

deltasRegistery = window.CRISP.deltas

# Defines a delta that removes a section of the DOM.
#
# Deltas of this type take the following settings:
#
#  - inclusive (bool):  whether the selected node should be remove too,
#                       or whether we're just removing the part of the tree
#                       that starts with the children of the selected nodes.
#                       Defaults to "false."
deltasRegistery["remove-subtree"] = (settings, domNodes) ->
  jQueryFuncName = if settings.inclusive then "remove" else "empty"
  do domNodes[jQueryFuncName]


deltasRegistery["update-subtree"] = (settings, domNodes) ->

  # The validation process ensures that action will exist and will be
  # one of four strings: "append", "prepend" and "replace", all of which
  # map onto jQuery methods, or "replace-sub", which is just a combination of
  # emptying and replacing HTML
  changeHTML = settings.change
  if settings.action is "replace"
    domNodes.replaceWith changeHTML
    return

  if settings.action in ["append", "prepend"]
    domNodes[settings.action] changeHTML
    return

  if settings.action is "replace-sub"
    do domNodes.empty
    domNodes.html changeHTML
    return
