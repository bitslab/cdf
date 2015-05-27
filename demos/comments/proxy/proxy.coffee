# In this very simple example of how a proxy could work, we just have,
# two end points defined.  When the user requests a page, we request
# CDF (as JSON) from the server, convert it to an HTML+JS document,
# and funnel it back to the client.
#
# The other supported end point is POST on the same path "/".  When
# we receive this, we just funnel the request back to the server,
# and then re-request the same document.
#
# Note that this is done in an extremely simple way, we block the loop
# when rendering CDF->HTML+JS, etc.  Just a demo :)
#
# Expects that the included sample server script is running on the same
# machine on port 8001

"use strict"

express = require 'express'
bodyParser = require 'body-parser'
request = require 'request'
path = require 'path'
escape = require "escape-html"
prettyjson = require "prettyjson"
cdfParser = require '../../../index'

serverURL = "http://localhost:8001"
app = do express
app.use bodyParser.urlencoded({ extended: true })

fetchCDF = (res) ->
  request serverURL + "/", (requestError, response, body) ->

    # First, try and just fetch the CDF from the server, which, if
    # all goes well, is just a simple GET request.
    if requestError or response.statusCode isnt 200
      responseStr = ("<h1>Error requesting CDF from: #{ serverURL }</h1>" +
                    "<pre>#{ requestError }</pre>")
      res.status(400).send responseStr
      return

    # Next, if we got a response from the server, hope that it is
    # is valid JSON.  If its not, display an error to the user
    # and try no more.
    try
      cdfData = JSON.parse body
    catch parseError
      safeBody = escape
      responseStr = ("<h1>Error parsing JSON from: #{ serverURL }</h1>" +
                    "<label>JSON Parse Error:</label>" +
                    "<p>#{ parseError }</p>" +
                    "<label>Received JSON</label>" +
                    "<textarea rows='10' style='width: 100%;'>" + safeBody +
                    "</textarea>")
      res.status(400).send responseStr
      return

    # If we're able to parse the JSON document correctly, check and see
    # if it parses as valid CDF.  If not, again, error out and be done
    # with it all...
    [wasRendered, result] = cdfParser.render cdfData
    if wasRendered is false
      safeBody = escape prettyjson.render cdfData, {noColor: true}
      responseStr = ("<h1>Error parsing CDF data from: #{ serverURL }</h1>" +
                    "<label>CDF Parse Error:</label>" +
                    "<p>#{ result }</p>" +
                    "<label>Received Structure</label>" +
                    "<textarea rows='10' style='width: 100%;'>" + safeBody +
                    "</textarea>")
      res.status(400).send responseStr
      return

    # Otherwise, all seems good, so spit all the HTML out...
    res.send result

crispClientPath = path.join __dirname, 'crisp-client'
app.use '/crisp-client', express.static crispClientPath

app.get '/', (req, res) ->
  fetchCDF res

app.post '/', (req, res) ->
  params =
    url: serverURL + "/"
    form:
      comment: req.param "comment"
      category: if req.param("category") is "one" then "one" else "two"
  request.post params, (requestError, response, body) ->
    fetchCDF res

# For stylesheet requests, just send them back to the server, and just
# pass back whatever we get
app.get '/stylesheets/*', (req, res) ->

  if not req.accepts 'text/css'
    res.status(403).end()

  request serverURL + req.path, (requestError, response, body) ->
    res.set 'Content-Type', 'text/css'
    res.status response.statusCode
    res.send body

server = app.listen 8000, ->
  host = server.address().address
  port = server.address().port
  console.log 'Starting crisp proxy at http://%s:%s', host, port
