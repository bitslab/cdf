(function() {
  "use strict";
  var app, bodyParser, cdfParser, crispClientPath, escape, express, fetchCDF, path, prettyjson, request, server, serverURL;

  express = require('express');

  bodyParser = require('body-parser');

  request = require('request');

  path = require('path');

  escape = require("escape-html");

  prettyjson = require("prettyjson");

  cdfParser = require('../../../index');

  serverURL = "http://localhost:8001";

  app = express();

  app.use(bodyParser.urlencoded({
    extended: true
  }));

  fetchCDF = function(res) {
    return request(serverURL + "/", function(requestError, response, body) {
      var cdfData, parseError, responseStr, result, safeBody, wasRendered, _ref;
      if (requestError || response.statusCode !== 200) {
        responseStr = ("<h1>Error requesting CDF from: " + serverURL + "</h1>") + ("<pre>" + requestError + "</pre>");
        res.status(400).send(responseStr);
        return;
      }
      try {
        cdfData = JSON.parse(body);
      } catch (_error) {
        parseError = _error;
        safeBody = escape;
        responseStr = ("<h1>Error parsing JSON from: " + serverURL + "</h1>") + "<label>JSON Parse Error:</label>" + ("<p>" + parseError + "</p>") + "<label>Received JSON</label>" + "<textarea rows='10' style='width: 100%;'>" + safeBody + "</textarea>";
        res.status(400).send(responseStr);
        return;
      }
      _ref = cdfParser.render(cdfData), wasRendered = _ref[0], result = _ref[1];
      if (wasRendered === false) {
        safeBody = escape(prettyjson.render(cdfData, {
          noColor: true
        }));
        responseStr = ("<h1>Error parsing CDF data from: " + serverURL + "</h1>") + "<label>CDF Parse Error:</label>" + ("<p>" + result + "</p>") + "<label>Received Structure</label>" + "<textarea rows='10' style='width: 100%;'>" + safeBody + "</textarea>";
        res.status(400).send(responseStr);
        return;
      }
      return res.send(result);
    });
  };

  crispClientPath = path.join(__dirname, 'crisp-client');

  app.use('/crisp-client', express["static"](crispClientPath));

  app.get('/', function(req, res) {
    return fetchCDF(res);
  });

  app.post('/', function(req, res) {
    var params;
    params = {
      url: serverURL + "/",
      form: {
        comment: req.param("comment"),
        category: req.param("category") === "one" ? "one" : "two"
      }
    };
    return request.post(params, function(requestError, response, body) {
      return fetchCDF(res);
    });
  });

  app.get('/stylesheets/*', function(req, res) {
    if (!req.accepts('text/css')) {
      res.status(403).end();
    }
    return request(serverURL + req.path, function(requestError, response, body) {
      res.set('Content-Type', 'text/css');
      res.status(response.statusCode);
      return res.send(body);
    });
  });

  server = app.listen(8000, function() {
    var host, port;
    host = server.address().address;
    port = server.address().port;
    return console.log('Starting crisp proxy at http://%s:%s', host, port);
  });

}).call(this);
