# This script is a simple, sample server that only serves CDF.  It serves
# a simple page that includes comments on it.  Commenters can send comments
# that will be included in the page.  Comments are saved in, and served
# out of a static JSON file on disk (not fancy).
#
# The important part is that the client never communicates directly with this
# service (since all it would get back is a benign JSON string).  Instead,
# the client communicates with this service through the proxy.

"use strict"

express = require 'express'
bodyParser = require 'body-parser'
path = require 'path'
jsonTemplates = require './json-templates/templates'
fs = require 'fs'

app = do express
app.use bodyParser.urlencoded({ extended: true })

# Calculate a bunch of the absolute paths used in the server, since they
# won't ever change, we can just do them once and be done with it.
#
# Absolute path to where all the JSON / CDF template are stored
templatesDir = path.join __dirname, 'templates' 

# Similar absolute path to where all the comment are stored (in a single
# flat file of JSON strings).
commentFile = path.join __dirname, "comments.json"

# Absolute path to the main page template on disk.
pageTemplateFile = path.join templatesDir, "page.json"

# And again, this time the absolute path to where style sheets are served
# from (these are generated from sass)
styleSheetsPath = path.join __dirname, 'static', 'stylesheets'

# Function that takes a javascript object, representing a comment
# read from the premanet store, and returns another javascript object,
# this time a CDF object
commentToCDF = (comment) ->
  t: "li"
  a: {class: ["comment"]}
  c: [{
        t: "strong"
        a: {class: ["date"]}
        c: [{
          t: "text",
          text: comment.date
        }]
      },
      {
        t: "p"
        a: {class: ["comment-body"]}
        c: [{
          t: "text"
          text: comment.body
        }]
      }]


# Parse the comments out of the json file on disk, and return them
# in an object, with the categories as keys
submittedComments = (callback) ->
  fs.readFile commentFile, "utf8", (err, data) ->
    comments = {}
    if err
      callback [false, err]
      return
    for commentStr in data.trim().split "\n"
      if not commentStr
        continue
      comment = JSON.parse commentStr
      if comments[comment.category] is undefined
        comments[comment.category] = []
      comments[comment.category].push commentToCDF comment
    callback [true, comments]


# Return a JSON string describing the current page, including the comments
# and all that
renderedPage = (res) ->
  submittedComments ([isSuccess, commentData]) ->
    if isSuccess is false
      comments = {"catOne": [], "catTwo": []}
    else
      comments =
        catOne: commentData.one or []
        catTwo: commentData.two or []

    fs.readFile pageTemplateFile, "utf8", (err, templateData) ->
      bodyTemplate = JSON.parse templateData
      renderedBody = jsonTemplates.applyParams bodyTemplate, comments
      res.json renderedBody

app.use '/stylesheets/', express.static styleSheetsPath

app.get '/', (req, res) ->
  renderedPage res

app.post '/', (req, res) ->
  rec =
    body: req.param "comment"
    category: if req.param("category") is "one" then "one" else "two"
    date: new Date().toISOString()
  recordJSON = JSON.stringify rec
  fs.appendFile commentFile, "\n" + recordJSON, (err) ->
    renderedPage res

server = app.listen 8001, ->
  host = server.address().address
  port = server.address().port
  console.log 'Starting CDF server at http://%s:%s', host, port
