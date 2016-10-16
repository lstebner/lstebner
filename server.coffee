http = require("http")
dispatcher = require("httpdispatcher")
pug = require("pug")
less = require("less")
coffee = require("coffee-script")
_ = require("underscore")
fs = require("fs")
port = 3020

config =
  sidebar_enabled: false
  topbar_enabled: true

class AssetServer
  less_opts: { compress: false, paths: ["./assets/less"] }
  coffee_opts: {}
  constructor: (@root_dir="#{__dirname}", @res) ->

  serve_stylesheet: (path) ->
    console.log "AssetServer::stylesheet #{path}"
    path = path.replace /css/g, "less"
    @res.writeHead "200", "Content-Type: text/css"
    contents = fs.readFileSync "#{@root_dir}#{path}", "UTF-8"
    less.render contents, @less_opts, (e, output) =>
      @res.end output.css

  serve_coffeescript: (path) ->
    console.log "AssetServer::coffeescript #{path}"
    path = path.replace /\.js/, ".coffee"
    @res.writeHead "200", "Content-Type: text/javascript"
    contents = fs.readFileSync "#{@root_dir}#{path}", "UTF-8"
    
    @res.end coffee.compile @process_replacements contents

  serve_javascript: (path) ->
    console.log "AssetServer::javascript #{path}"
    @res.writeHead "200", "Content-Type: text/javascript"
    contents = fs.readFileSync "#{@root_dir}#{path}", "UTF-8"
    @res.end contents

  serve_image: (path) ->
    console.log "AssetServer::image #{path}"
    @res.writeHead "200", "Content-Type: text/#{path.substr(path.lastIndexOf('.'))}"
    @res.end fs.readFileSync "#{@root_dir}#{path}"

  process_replacements: (contents) ->
    matches = contents.match /#(\s+|)\{\{(prepend|append|insert):([a-zA-Z0-9\-_\/]+)\}\}/g
    replacements = {}

    # nothing to do here
    return contents unless matches && matches.length

    # process all the matches
    for match in matches
      unless replacements.hasOwnProperty(match)
        action = match.match /(prepend|append|insert):/
        file = match.match /:([a-zA-Z0-9\-_\/]+)/
        filename = "#{__dirname}/assets/coffee/#{file[1]}.coffee"
        file_contents = @process_replacements fs.readFileSync filename, "UTF-8"
        replacements[match] = action: action[1], file: file[1], contents: file_contents

    for key, val of replacements
      # if append or prepend then remove the comment line
      if val.action.indexOf("pend") > -1
        contents = contents.replace new RegExp(key, "g"), "" 

      if val.action == "append"
        contents = contents + val.contents
      else if val.action == "prepend"
        contents = val.contents + contents
      # insert in place
      else
        contents = contents.replace new RegExp(key, "g"), val.contents

    contents

class View
  constructor: (name, @res, @data={}) ->
    @filename = "#{__dirname}/views/#{name}.pug"

  write_head: (status) ->
    @res.writeHead "#{status}", "Content-Type: text/plain"

  render: ->
    @data.config = config

    @write_head 200
    try
      html = pug.renderFile @filename, @data
    catch e
      console.log JSON.stringify("pug render error:", e)
    @res.end html


handleRequest = (req, res) ->
  console.log "url hit: #{req.url}"
  url = req.url
  html = null
  asset_server = new AssetServer("#{__dirname}/assets/", res)

  if url.match(/css\/[a-zA-Z\/]+\.css/)
    return asset_server.serve_stylesheet url, res
  else if url.match(/coffee\/[a-zA-Z\/\.\-_0-9]+\.js/)
    return asset_server.serve_coffeescript url, res
  else if url.match(/lib\/[a-zA-Z\/\.\-_0-9]+\.js/)
    return asset_server.serve_javascript url, res
  else if url.match(/images\/[a-zA-Z\/\.\-_0-9]+\.(jpg|png)/)
    return asset_server.serve_image url, res
  else
    dispatcher.dispatch req, res

  unless html?
    # todo: implement 
    # html = pug.renderFile "#{__dirname}/views/404.pug"
    html = "404, whoops"

  res.end html

dispatcher.setStatic "assets"

server = http.createServer handleRequest

routes_to_pages = [
  ["/", { view: "index", page: "home" }]
  ["/beats", "beats"]
]

setup_pages = ->
  for route, i in routes_to_pages
    path = route[0]
    pathdata = route[1]
    console.log "setup:", path, pathdata
    # dispatcher.onGet path, (req, res) ->
    #   view = if typeof pathdata == "object"
    #     new View pathdata.view, res, page: pathdata.name
    #   else
    #     new View pathdata, res, page: pathdata 

    #   view.render()

setup_pages()

dispatcher.onGet "/", (req, res) ->
  view = new View "index", res, page: "home"
  view.render()

dispatcher.onGet "/beats", (req, res) ->
  view = new View "beats", res, page: "beats"
  view.render()

server.listen port, ->
  console.log "Server started on port #{port}"
