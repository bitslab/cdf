"use strict"

argparse = require "argparse"
url = require "url"
path = require "path"
fs = require "fs"
http = require 'http'
request = require 'request'
prettyjson = require 'prettyjson'
escape = require 'escape-html'
cdfParser = require '../../parser/js/render'

parser = new argparse.ArgumentParser
  version: 0.2
  addHelp: true
  description: "HTTP proxy that passes on HTTP requests from the client
                to the server, and then either coverts the server's CDF
                response into HTML and javascript to be rendered in the
                browser, or an HTML document describing why the server's
                response was invalid."

parser.addArgument ['-d', '--debug'],
  help: "Whether to print out error / debug information to the console."
  action: "storeTrue"

parser.addArgument ['-p', '--port'],
  help: "The port that the proxy should listen on.  Defaults to 5050."
  defaultValue: 5050
  type: 'int'

args = do parser.parseArgs

clientCodePath = path.join __dirname

trustedInlineMimeTypes = [
  # Audio types for <audio>
  "audio/webm", "audio/mp4", "audio/ogg", "audio/mpeg"

  # Well known image types
  "image/gif", "image/jpeg", "image/jpg", "image/png", "image/svg+xml",
  "image/x-icon", "image/vnd.microsoft.icon",

  # Video types
  "video/mp4", "video/ogg", "video/webm",

  # Other things that are allowed for presentation
  "text/css", "application/font-woff", "font/opentype", "application/font-sfnt",
  "application/x-font-opentype", "application/x-font-ttf"
]
wrappedMimeTypes = trustedInlineMimeTypes.map (x) -> "<li>#{x}</li>\n"


cdfMimeTypes = [
  "text/cdf", "application/x-netcdf"
]


debugMessage = (msg) ->
  if not args.debug
    return
  console.log msg


# Attempts to determine the advertised content type of the request.
# If the type cannot be determined, null is returned.
#
# This function mainly serves to normalize between header responses
# that look like "text/html" and "text/html; encoding=utf-8"
#
# @param object response
#   A response, as returned by the `http.ServerResponse` function
#
# @return string|null
#   If the advertised content type could be determined, that type, as a
#   string, otherwise, null.
responseContentType = (response) ->
  if !response or !response.headers
    return null

  contentType = response.headers["content-type"]
  if !contentType
    return null

  contentType.split(";")[0]


proxyServer = http.createServer (originalRequest, proxyResponse) ->

  requestBody = ""

  originalRequest.on "data", (chunk) -> requestBody += chunk
  originalRequest.on "end", ->

    debugMessage "Received request for: #{originalRequest.url}"

    requestMethod = originalRequest.method
    requestUrl = originalRequest.url
    urlParts = url.parse requestUrl
    requestPath = urlParts.path

    # Before doing anything further, see if this is a request for
    # CDF client code.  If so, then we can just return it ourselves, off
    # disk.
    if requestPath.indexOf("/crisp-client") is 0
      try
        possibleJSLocation = path.join clientCodePath, requestPath
        jsFileContents = fs.readFileSync possibleJSLocation
        proxyResponse.statusCode = 200
        proxyResponse.end jsFileContents
        return
      catch error
        console.log error
        return

    requestOptions =
      strictSSL: true
      url: requestUrl
      method: requestMethod
      gzip: true
      json: false
      headers: {}

    if requestBody
      requestOptions.form = requestBody

    origRequestCookies = originalRequest.headers.cookie
    if origRequestCookies
      requestOptions.headers.cookie = origRequestCookies

    proxyRequest = request requestOptions, (error, response, body) ->
      # Last, if we're here in the flow, it means that the server advertiesed
      # the content as CDF.  So, first step is to attempt to parse it as JSON.
      try
        cdfData = JSON.parse body
      catch parseError
        safeBody = escape prettyjson.render body, {noColor: true}
        responseStr = "<h1>Error parsing CDF from: #{ requestUrl }</h1>
                      <label>JSON Parse Error:</label>
                      <pre>#{ parseError }</pre>
                      <hr />
                      <label>Received JSON</label>
                      <textarea rows='20' style='width: 100%;'>#{ safeBody }
                      </textarea>"
        proxyResponse.statusCode = 400
        proxyResponse.end responseStr
        return

      # If we're able to parse the JSON document correctly, check and see
      # if it parses as valid CDF.  If not, again, error out and be done
      # with it all...
      isUpdate = Array.isArray cdfData
      renderFunc = if isUpdate then cdfParser.renderUpdate else cdfParser.renderDocument
      [wasRendered, cdfDocument] = renderFunc cdfData
      if not wasRendered
        formattedJson = prettyjson.render body, {noColor: true}
        safeBody = escape formattedJson
        responseStr = "<h1>Error parsing CDF data from: #{ requestUrl }</h1>
                      <label>CDF Parse Error:</label>
                      <pre>#{ cdfDocument }</pre>
                      <hr />
                      <label>Received Structure</label>
                      <textarea rows='20' style='width: 100%;'>#{ safeBody }
                      </textarea>"
        proxyResponse.statusCode = 400
        proxyResponse.end responseStr
        return

      # Otherwise, all seems good, so spit all the HTML out...
      setCookieHeader = response.headers?['Set-Cookie']
      if setCookieHeader
          proxyResponse.setHeader 'Set-Cookie', setCookieHeader

      proxyResponse.setHeader "Content-Type", "text/html"
      proxyResponse.statusCode = 200
      proxyResponse.end cdfDocument


    proxyRequest.on "response", (proxyHeaderResponse) ->
      if proxyHeaderResponse.statusCode isnt 200
        do proxyRequest.end
        responseStr = "<h1>Error requesting from: #{ requestUrl }</h1>
                      <pre>#{ escape proxyHeaderResponse.body }</pre>"
        proxyResponse.statusCode = 400
        proxyResponse.end responseStr
        return

      receivedMimeType = responseContentType proxyHeaderResponse

      # Next, check and see if the remote content is CDF.  If it is not,
      # see if we should block the request, or allow it through.
      # If the request is something that we expect to see in the browser
      # (images, audio, etc) then we let it through.  Otherwise, we only
      # pass it through if it is an attachment.  In all other cases we
      # reject the request.
      if receivedMimeType not in cdfMimeTypes
        isTrustedContentType = receivedMimeType in trustedInlineMimeTypes
        isAttachment = proxyHeaderResponse.headers?['content-disposition'] is "attachment"

        if isTrustedContentType or isAttachment
          proxyRequest.pipe proxyResponse
          return

        do proxyRequest.end
        responseStr = "<h1>Error requesting from: #{requestUrl}</h1>
                     <p>Remote server sent content of mime type
                     #{receivedMimeType} to be displayed inline (ie not having
                     <code>Content-Disposition: Attachment</code>), so it was
                     not passed through to the client.</p>
                     <p>Only content of the following mime types are presented
                     to the client to be displated inline:</p>
                     <ul>#{wrappedMimeTypes.join ""}</ul>"
        proxyResponse.statusCode = 400
        proxyResponse.end responseStr
        debugMessage " - Reject, #{receivedMimeType}"
        return


    proxyRequest.on "error", (proxyRequestError) ->
      responseStr = "<h1>Error requesting from: #{ requestUrl }</h1>
                    <pre>#{ escape proxyRequestError }</pre>"
      proxyResponse.statusCode = 400
      proxyResponse.end responseStr


proxyServer.listen args.port
