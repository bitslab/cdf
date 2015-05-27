'use strict'

path = require 'path'
watch = require 'node-watch'
connect = require 'connect'
http = require 'http'
serveStatic = require 'serve-static'
morgan = require "morgan"

webRootPath = path.join __dirname, "webroot"
connectServer = do connect

connectServer.use morgan ':remote-addr - :remote-user [:date[clf]] ":method :url HTTP/:http-version" :status :res[content-length] ":referrer" ":user-agent" ":req[cookie]"'

staticServer = serveStatic webRootPath
connectServer.use staticServer

httpServer = http.createServer connectServer

httpServer.listen 8888
