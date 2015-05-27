'use strict'
fs = require 'fs'
path = require 'path'
yaml = require 'js-yaml'
watch = require 'node-watch'
cdfParser = require '../../index'
connect = require 'connect'
http = require 'http'
serveStatic = require 'serve-static'
bodyParser = require 'body-parser'

connectServer = do connect
connectServer.use bodyParser.urlencoded({ extended: false })
connectServer.use serveStatic path.join __dirname, "webroot"
httpServer = http.createServer connectServer

mainFileCDF = path.join 'templates', 'index.yaml'
updateFileCDF = path.join 'templates', 'update.yaml'

mainFileHTML = path.join 'webroot', "index.html"
updateFileHTML = path.join 'webroot', "update.html"

connectServer.use "/double", (req, res, next) ->
  integer = req.body['value[]']
  double = integer * 2;
  res.setHeader 'Content-Type', 'application/json'
  response =
    t: "properties"
    s:
      change:
        value: double
  res.end JSON.stringify [response]


rebuild = (filename) ->
  if filename in [mainFileHTML, updateFileHTML]
    return

  try
    do httpServer.close
    console.log "Caught change, restarting the server..."
    console.log ""

  try
    console.log "Rendering index page (index.html)"
    console.log "----------"
    contents = fs.readFileSync mainFileCDF, 'utf8'
    data = yaml.load contents
    [wasRendered, result] = cdfParser.renderDocument data
    if wasRendered is false
      console.log "Parse Error in Document: #{ result }"
      fs.writeFileSync mainFileHTML, "<pre>#{ result }</pre>"
      return
    else
      console.log "Wrote new version document"
      fs.writeFileSync mainFileHTML, result

    console.log ""
    console.log "Rendering update deltas (update.html)"
    console.log "----------"

    updateContents = fs.readFileSync updateFileCDF, 'utf8'
    updateData = yaml.load updateContents
    [wasRendered, updateRenderResult] = cdfParser.renderUpdate updateData
    if wasRendered is false
      console.log "Parse Error in Update: #{ updateRenderResult }"
      fs.writeFileSync updateFileHTML, "<pre>#{ updateRenderResult }</pre>"
    else
      console.log "Wrote new update"
      fs.writeFileSync updateFileHTML, updateRenderResult

    httpServer.listen 8888

  catch err
    console.log err.stack or err

watch "templates", rebuild
do rebuild
