(function() {
  "use strict";
  var app, bodyParser, commentFile, commentToCDF, express, fs, jsonTemplates, pageTemplateFile, path, renderedPage, server, styleSheetsPath, submittedComments, templatesDir;

  express = require('express');

  bodyParser = require('body-parser');

  path = require('path');

  jsonTemplates = require('./json-templates/templates');

  fs = require('fs');

  app = express();

  app.use(bodyParser.urlencoded({
    extended: true
  }));

  templatesDir = path.join(__dirname, 'templates');

  commentFile = path.join(__dirname, "comments.json");

  pageTemplateFile = path.join(templatesDir, "page.json");

  styleSheetsPath = path.join(__dirname, 'static', 'stylesheets');

  commentToCDF = function(comment) {
    return {
      t: "li",
      a: {
        "class": ["comment"]
      },
      c: [
        {
          t: "strong",
          a: {
            "class": ["date"]
          },
          c: [
            {
              t: "text",
              text: comment.date
            }
          ]
        }, {
          t: "p",
          a: {
            "class": ["comment-body"]
          },
          c: [
            {
              t: "text",
              text: comment.body
            }
          ]
        }
      ]
    };
  };

  submittedComments = function(callback) {
    return fs.readFile(commentFile, "utf8", function(err, data) {
      var comment, commentStr, comments, _i, _len, _ref;
      comments = {};
      if (err) {
        callback([false, err]);
        return;
      }
      _ref = data.trim().split("\n");
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        commentStr = _ref[_i];
        if (!commentStr) {
          continue;
        }
        comment = JSON.parse(commentStr);
        if (comments[comment.category] === void 0) {
          comments[comment.category] = [];
        }
        comments[comment.category].push(commentToCDF(comment));
      }
      return callback([true, comments]);
    });
  };

  renderedPage = function(res) {
    return submittedComments(function(_arg) {
      var commentData, comments, isSuccess;
      isSuccess = _arg[0], commentData = _arg[1];
      if (isSuccess === false) {
        comments = {
          "catOne": [],
          "catTwo": []
        };
      } else {
        comments = {
          catOne: commentData.one || [],
          catTwo: commentData.two || []
        };
      }
      return fs.readFile(pageTemplateFile, "utf8", function(err, templateData) {
        var bodyTemplate, renderedBody;
        bodyTemplate = JSON.parse(templateData);
        renderedBody = jsonTemplates.applyParams(bodyTemplate, comments);
        return res.json(renderedBody);
      });
    });
  };

  app.use('/stylesheets/', express["static"](styleSheetsPath));

  app.get('/', function(req, res) {
    return renderedPage(res);
  });

  app.post('/', function(req, res) {
    var rec, recordJSON;
    rec = {
      body: req.param("comment"),
      category: req.param("category") === "one" ? "one" : "two",
      date: new Date().toISOString()
    };
    recordJSON = JSON.stringify(rec);
    return fs.appendFile(commentFile, "\n" + recordJSON, function(err) {
      return renderedPage(res);
    });
  });

  server = app.listen(8001, function() {
    var host, port;
    host = server.address().address;
    port = server.address().port;
    return console.log('Starting CDF server at http://%s:%s', host, port);
  });

}).call(this);
