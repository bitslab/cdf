"use strict"

# Adapted from http://www.cs.tut.fi/~jkorpela/html/nesting.html
inlineTypes = [
  "text", "span", "a", "strong", "em", "input", "select", "label", "button",
  "img", "textarea", "small"
]

blockTypes = [
  "header", "aside", "article", "footer", "p", "h1", "h2", "h3", "h4", "h5",
  "h6", "ul", "div", "form", "table", "ol", "dl"
]

module.exports =
  inlineTypes: inlineTypes
  blockTypes: blockTypes
  flowTypes: inlineTypes.concat blockTypes
