(function() {
  "use strict";
  var argparse, args, cdfMimeTypes, cdfParser, clientCodePath, constants, debugMessage, escape, fs, http, parser, path, prettyjson, proxyServer, request, responseContentType, trustedInlineMimeTypes, url, wrappedMimeTypes,
    __indexOf = [].indexOf || function(item) { for (var i = 0, l = this.length; i < l; i++) { if (i in this && this[i] === item) return i; } return -1; };

  constants = require("../../constants");

  argparse = require("argparse");

  url = require("url");

  path = require("path");

  fs = require("fs");

  http = require('http');

  request = require('request');

  prettyjson = require('prettyjson');

  escape = require('escape-html');

  cdfParser = require('../../parser/js/render');

  parser = new argparse.ArgumentParser({
    version: constants.version,
    addHelp: true,
    description: "HTTP proxy that passes on HTTP requests from the client to the server, and then either coverts the server's CDF response into HTML and javascript to be rendered in the browser, or an HTML document describing why the server's response was invalid."
  });

  parser.addArgument(['-d', '--debug'], {
    help: "Whether to print out error / debug information to the console.",
    action: "storeTrue"
  });

  parser.addArgument(['-p', '--port'], {
    help: "The port that the proxy should listen on.  Defaults to 5050.",
    defaultValue: 5050,
    type: 'int'
  });

  args = parser.parseArgs();

  clientCodePath = path.join(__dirname, "..", "..", "client", "js");

  trustedInlineMimeTypes = ["audio/webm", "audio/mp4", "audio/ogg", "audio/mpeg", "image/gif", "image/jpeg", "image/jpg", "image/png", "image/svg+xml", "image/x-icon", "image/vnd.microsoft.icon", "video/mp4", "video/ogg", "video/webm", "text/css", "application/font-woff", "font/opentype", "application/font-sfnt", "application/x-font-opentype", "application/x-font-ttf"];

  wrappedMimeTypes = trustedInlineMimeTypes.map(function(x) {
    return "<li>" + x + "</li>\n";
  });

  cdfMimeTypes = ["text/cdf", "application/x-netcdf"];

  debugMessage = function(msg) {
    if (!args.debug) {
      return;
    }
    return console.log(msg);
  };

  responseContentType = function(response) {
    var contentType;
    if (!response || !response.headers) {
      return null;
    }
    contentType = response.headers["content-type"];
    if (!contentType) {
      return null;
    }
    return contentType.split(";")[0];
  };

  proxyServer = http.createServer(function(originalRequest, proxyResponse) {
    var requestBody;
    requestBody = "";
    originalRequest.on("data", function(chunk) {
      return requestBody += chunk;
    });
    return originalRequest.on("end", function() {
      var error, jsFileContents, origRequestCookies, possibleJSLocation, proxyRequest, requestMethod, requestOptions, requestPath, requestUrl, urlParts;
      debugMessage("Received request for: " + originalRequest.url);
      requestMethod = originalRequest.method;
      requestUrl = originalRequest.url;
      urlParts = url.parse(requestUrl);
      requestPath = urlParts.path;
      if (requestPath.indexOf("/crisp-client") === 0) {
        try {
          possibleJSLocation = path.join(clientCodePath, requestPath);
          jsFileContents = fs.readFileSync(possibleJSLocation);
          proxyResponse.statusCode = 200;
          proxyResponse.end(jsFileContents);
          return;
        } catch (_error) {
          error = _error;
          console.log(error);
          return;
        }
      }
      requestOptions = {
        strictSSL: true,
        url: requestUrl,
        method: requestMethod,
        gzip: true,
        json: false,
        headers: {}
      };
      if (requestBody) {
        requestOptions.form = requestBody;
      }
      origRequestCookies = originalRequest.headers.cookie;
      if (origRequestCookies) {
        requestOptions.headers.cookie = origRequestCookies;
      }
      proxyRequest = request(requestOptions, function(error, response, body) {
        var cdfData, cdfDocument, formattedJson, isUpdate, parseError, renderFunc, responseStr, safeBody, setCookieHeader, wasRendered, _ref, _ref1;
        try {
          cdfData = JSON.parse(body);
        } catch (_error) {
          parseError = _error;
          safeBody = escape(prettyjson.render(body, {
            noColor: true
          }));
          responseStr = "<h1>Error parsing CDF from: " + requestUrl + "</h1> <label>JSON Parse Error:</label> <pre>" + parseError + "</pre> <hr /> <label>Received JSON</label> <textarea rows='20' style='width: 100%;'>" + safeBody + " </textarea>";
          proxyResponse.statusCode = 400;
          proxyResponse.end(responseStr);
          return;
        }
        isUpdate = Array.isArray(cdfData);
        renderFunc = isUpdate ? cdfParser.renderUpdate : cdfParser.renderDocument;
        _ref = renderFunc(cdfData), wasRendered = _ref[0], cdfDocument = _ref[1];
        if (!wasRendered) {
          formattedJson = prettyjson.render(body, {
            noColor: true
          });
          safeBody = escape(formattedJson);
          responseStr = "<h1>Error parsing CDF data from: " + requestUrl + "</h1> <label>CDF Parse Error:</label> <pre>" + (escape(cdfDocument)) + "</pre> <hr /> <label>Received Structure</label> <textarea rows='20' style='width: 100%;'>" + safeBody + " </textarea>";
          proxyResponse.statusCode = 400;
          proxyResponse.end(responseStr);
          return;
        }
        setCookieHeader = (_ref1 = response.headers) != null ? _ref1['Set-Cookie'] : void 0;
        if (setCookieHeader) {
          proxyResponse.setHeader('Set-Cookie', setCookieHeader);
        }
        proxyResponse.setHeader("Content-Type", "text/html; charset=utf-8");
        proxyResponse.statusCode = 200;
        return proxyResponse.end(cdfDocument);
      });
      proxyRequest.on("response", function(proxyHeaderResponse) {
        var isAttachment, isTrustedContentType, receivedMimeType, responseStr, _ref;
        if (proxyHeaderResponse.statusCode !== 200) {
          proxyRequest.end();
          responseStr = "<h1>Error requesting from: " + requestUrl + "</h1> <pre>" + (escape(proxyHeaderResponse.body)) + "</pre>";
          proxyResponse.statusCode = 400;
          proxyResponse.end(responseStr);
          return;
        }
        receivedMimeType = responseContentType(proxyHeaderResponse);
        if (__indexOf.call(cdfMimeTypes, receivedMimeType) < 0) {
          isTrustedContentType = __indexOf.call(trustedInlineMimeTypes, receivedMimeType) >= 0;
          isAttachment = ((_ref = proxyHeaderResponse.headers) != null ? _ref['content-disposition'] : void 0) === "attachment";
          if (isTrustedContentType || isAttachment) {
            proxyRequest.pipe(proxyResponse);
            return;
          }
          proxyRequest.end();
          responseStr = "<h1>Error requesting from: " + requestUrl + "</h1> <p>Remote server sent content of mime type " + receivedMimeType + " to be displayed inline (ie not having <code>Content-Disposition: Attachment</code>), so it was not passed through to the client.</p> <p>Only content of the following mime types are presented to the client to be displayed inline:</p> <ul>" + (wrappedMimeTypes.join("")) + "</ul>";
          proxyResponse.statusCode = 400;
          proxyResponse.end(responseStr);
          debugMessage(" - Reject, " + receivedMimeType);
        }
      });
      return proxyRequest.on("error", function(proxyRequestError) {
        var responseStr;
        responseStr = "<h1>Error requesting from: " + requestUrl + "</h1> <pre>" + (escape(proxyRequestError)) + "</pre>";
        proxyResponse.statusCode = 400;
        return proxyResponse.end(responseStr);
      });
    });
  });

  proxyServer.listen(args.port);

}).call(this);
