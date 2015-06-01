fs = require("fs");
path = require("path");
glob = require("glob");

var coffeeFiles = {
    'demos/proxy/server.js': 'demos/proxy/server.coffee',
    'demos/comments/proxy/proxy.js': 'demos/comments/proxy/proxy.coffee',
    'demos/comments/server/server.js': 'demos/comments/server/server.coffee',
    'demos/simple/server.js': 'demos/simple/server.coffee',
    'src/client/js/crisp.js': 'src/client/coffee/crisp.coffee',
  },
  coffeeDirs = [
    path.join(__dirname, "src", "client", "coffee"),
    path.join(__dirname, "src", "proxy", "coffee")
  ];

coffeeDirs.forEach(function (aPath) {
  glob.sync(aPath + "/**/*.coffee").forEach(function (aCoffeeFile) {
    var jsFileName = aCoffeeFile.replace(/coffee/g, "js");
    coffeeFiles[jsFileName] = aCoffeeFile;
  });
});

module.exports = function (grunt) {

  var docAssetPath = path.join(__dirname, "docs", "assets"),
    cssMarkdownPath = docAssetPath + "/github-markdown.css",
    cssMarkdown = fs.readFileSync(cssMarkdownPath, {encoding: "utf8"}),
    cssHighlightPath = docAssetPath + "/highlight.min.css",
    cssHighlight = fs.readFileSync(cssHighlightPath, {encoding: "utf8"}); 

  grunt.initConfig({
    markdown: {
      all: {
        options: {
          postCompile: function (src, context) {
            var injectedCss = "<style type='text/css'>" + cssMarkdown + "\n" + cssHighlight + "</style>",
              parts = [
                injectedCss,
                '<article class="markdown-body">',
                src,
                '</article>'
              ];

            src = parts.join("\n");
            return src;
          },
          markdownOptions: {
            highlight: 'auto',
            gfm: true
          }
        },
        files: [
          {
            expand: true,
            flatten: true,
            src: 'docs/markdown/*.md',
            dest: 'docs/html/',
            ext: '.html'
          }
        ]
      }
    },
    compass: {
      options: {
        config: 'demos/simple/config.rb',
        sassDir: 'demos/simple/sass',
        cssDir: 'demos/simple/stylesheets',
      },
      dist: {}
    },
    coffee: {
      compile: {
        files: coffeeFiles
      },
      glob_to_multiple: {
        expand: true,
        flatten: false,
        cwd: "src/parser/coffee",
        src: [
          "*/*.coffee",
          "*.coffee",
        ],
        dest: "src/parser/js",
        ext: '.js'
      }
    }
  });

  grunt.loadNpmTasks('grunt-markdown');
  grunt.loadNpmTasks('grunt-contrib-coffee');
  grunt.loadNpmTasks('grunt-contrib-compass');
  grunt.registerTask('default', ['coffee', 'compass', 'markdown']);
};
