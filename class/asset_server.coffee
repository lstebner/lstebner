fs = require("fs")
less = require("less")
coffee = require("coffee-script")

module.exports = class AssetServer
  less_opts: { compress: false, paths: ["./assets/less"] }
  coffee_opts: {}
  constructor: (@root_dir="#{__dirname.replace(/class/, 'assets')}", @res) ->

  serve_stylesheet: (path, path_is_raw_less=false) ->
    console.log "AssetServer::stylesheet #{path}" unless process.env.NODE_ENV == "test"
    path = path.replace /css/g, "less"
    @res.writeHead "200", "Content-Type: text/css"
    
    if path_is_raw_less
      return @res.end path
    else
      try
        contents = fs.readFileSync "#{@root_dir}#{path}", "UTF-8"
      catch e
        return @do404()

    less.render contents, @less_opts, (e, output) =>
      @res.end output.css

  serve_coffeescript: (path) ->
    console.log "AssetServer::coffeescript #{path}" unless process.env.NODE_ENV == "test"
    path = path.replace /\.js/, ".coffee"
    @res.writeHead "200", "Content-Type: text/javascript"
    try
      contents = fs.readFileSync "#{@root_dir}#{path}", "UTF-8"
    catch err
      path = path.replace /\.coffee/, ".js"
      try
        contents = fs.readFileSync "#{@root_dir}#{path}", "UTF-8"
      catch err
        console.log "tried to find #{path} (or coffee alternative) and neither existed" unless process.env.NODE_ENV == "test"
        return @do404()

    contents = coffee.compile @process_replacements contents
    @res.end contents

  serve_javascript: (path) ->
    console.log "AssetServer::javascript #{path}" unless process.env.NODE_ENV == "test"
    @res.writeHead "200", "Content-Type: text/javascript"
    try
      contents = fs.readFileSync "#{@root_dir}#{path}", "UTF-8"
    catch e
      return @do404()
    @res.end contents

  serve_image: (path) ->
    console.log "AssetServer::image #{path}" unless process.env.NODE_ENV == "test"
    @res.writeHead "200", "Content-Type: text/#{path.substr(path.lastIndexOf('.') + 1)}"
    try
      contents = fs.readFileSync "#{@root_dir}#{path}"
    catch e
      # ...
      console.log "AssetServer::image #{path} !! file not found" unless process.env.NODE_ENV == "test"
      return @do404()
    
    @res.end contents || false

  serve_audio: (path) ->
    console.log "AssetServer::audio #{path}" unless process.env.NODE_ENV == "test"
    @res.writeHead "200", "Content-Type: audio/mpeg"
    try
      contents = fs.readFileSync "#{@root_dir}#{path}"
    catch e
      return @do404()
    @res.end contents

  do404: ->
    @res.writeHead "404", "Content-Type: text/plain"
    @res.end "your classic 404, not found"

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
        # filename = "#{__dirname.replace(/class/, 'assets')}/coffee/#{file[1]}.coffee"
        filename = "#{@root_dir}/coffee/#{file[1]}.coffee"
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

