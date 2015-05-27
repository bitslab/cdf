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

module.exports = function(grunt) {

  grunt.initConfig({
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

  grunt.loadNpmTasks('grunt-contrib-coffee');
  grunt.loadNpmTasks('grunt-contrib-compass');
  grunt.registerTask('default', ['coffee', 'compass']);
};
