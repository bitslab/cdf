(function() {
  'use strict';
  var bodyParser, cdfParser, connect, connectServer, fs, http, httpServer, mainFileCDF, mainFileHTML, path, rebuild, serveStatic, updateFileCDF, updateFileHTML, watch, yaml;

  fs = require('fs');

  path = require('path');

  yaml = require('js-yaml');

  watch = require('node-watch');

  cdfParser = require('../../index');

  connect = require('connect');

  http = require('http');

  serveStatic = require('serve-static');

  bodyParser = require('body-parser');

  connectServer = connect();

  connectServer.use(bodyParser.urlencoded({
    extended: false
  }));

  connectServer.use(serveStatic(path.join(__dirname, "webroot")));

  httpServer = http.createServer(connectServer);

  mainFileCDF = path.join('templates', 'index.yaml');

  updateFileCDF = path.join('templates', 'update.yaml');

  mainFileHTML = path.join('webroot', "index.html");

  updateFileHTML = path.join('webroot', "update.html");

  connectServer.use("/double", function(req, res, next) {
    var double, integer, response;
    integer = req.body['value[]'];
    double = integer * 2;
    res.setHeader('Content-Type', 'application/json');
    response = {
      t: "properties",
      s: {
        change: {
          value: double
        }
      }
    };
    return res.end(JSON.stringify([response]));
  });

  rebuild = function(filename) {
    var contents, data, err, result, updateContents, updateData, updateRenderResult, wasRendered, _ref, _ref1;
    if (filename === mainFileHTML || filename === updateFileHTML) {
      return;
    }
    try {
      httpServer.close();
      console.log("Caught change, restarting the server...");
      console.log("");
    } catch (_error) {}
    try {
      console.log("Rendering index page (index.html)");
      console.log("----------");
      contents = fs.readFileSync(mainFileCDF, 'utf8');
      data = yaml.load(contents);
      _ref = cdfParser.renderDocument(data), wasRendered = _ref[0], result = _ref[1];
      if (wasRendered === false) {
        console.log("Parse Error in Document: " + result);
        fs.writeFileSync(mainFileHTML, "<pre>" + result + "</pre>");
        return;
      } else {
        console.log("Wrote new version document");
        fs.writeFileSync(mainFileHTML, result);
      }
      console.log("");
      console.log("Rendering update deltas (update.html)");
      console.log("----------");
      updateContents = fs.readFileSync(updateFileCDF, 'utf8');
      updateData = yaml.load(updateContents);
      _ref1 = cdfParser.renderUpdate(updateData), wasRendered = _ref1[0], updateRenderResult = _ref1[1];
      if (wasRendered === false) {
        console.log("Parse Error in Update: " + updateRenderResult);
        fs.writeFileSync(updateFileHTML, "<pre>" + updateRenderResult + "</pre>");
      } else {
        console.log("Wrote new update");
        fs.writeFileSync(updateFileHTML, updateRenderResult);
      }
      return httpServer.listen(8888);
    } catch (_error) {
      err = _error;
      return console.log(err.stack || err);
    }
  };

  watch("templates", rebuild);

  rebuild();

}).call(this);
