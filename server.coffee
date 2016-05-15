http = require("http")
dispatcher = require("httpdispatcher")
pug = require("pug")
less = require("less")
_ = require("underscore")
fs = require("fs")
port = 3014

class AssetServer
  constructor: (@root_dir="#{__dirname}", @res) ->

  # ideally these both do something better than just read the path
  # they're given...
  serve_stylesheet: (path) ->
    console.log "AssetServer::stylesheet #{path}"
    @res.writeHead "200", "Content-Type: text/css"
    @res.end fs.readFileSync "#{@root_dir}#{path}"

  serve_javascript: (path) ->
    console.log "AssetServer::javascript #{path}"
    @res.writeHead "200", "Content-Type: text/javascript"
    @res.end fs.readFileSync "#{@root_dir}#{path}"

  serve_image: (path) ->
    console.log "AssetServer::image #{path}"
    @res.writeHead "200", "Content-Type: text/#{path.substr(path.lastIndexOf('.'))}"
    @res.end fs.readFileSync "#{@root_dir}#{path}"


handleRequest = (req, res) ->
  console.log "url hit: #{req.url}"
  url = req.url
  html = null
  asset_server = new AssetServer("#{__dirname}/assets/", res)

  if url.match(/css\/[a-zA-Z\/]+\.css/)
    asset_server.serve_stylesheet url, res
  else if url.match(/(coffee|lib)\/[a-zA-Z\/\.\-_0-9]+\.js/)
    asset_server.serve_javascript url, res
  else if url.match(/images\/[a-zA-Z\/\.\-_0-9]+\.(jpg|png)/)
    asset_server.serve_image url, res
  else
    dispatcher.dispatch req, res

  unless html?
    # todo: implement 
    # html = pug.renderFile "#{__dirname}/views/404.pug"
    html = "404, whoops"

  res.end html

dispatcher.setStatic "assets"

server = http.createServer handleRequest

dispatcher.onGet "/", (req, res) ->
  res.writeHead "200", "Content-Type: text/plain"
  html = pug.renderFile "#{__dirname}/views/beats.pug", {}
  res.end html

server.listen port, ->
  console.log "Server started on port #{port}"
