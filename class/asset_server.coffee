fs = require("fs")
less = require("less")
coffee = require("coffee-script")

module.exports = class AssetServer
  less_opts: { compress: false, paths: ["./assets/less"] }
  coffee_opts: {}
  constructor: (@root_dir="#{__dirname.replace(/class/, 'assets')}", @res) ->

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
    try
      contents = fs.readFileSync "#{@root_dir}#{path}", "UTF-8"
    catch err
      path = path.replace /\.coffee/, ".js"
      try
        contents = fs.readFileSync "#{@root_dir}#{path}", "UTF-8"
      catch err
        console.log "tried to find #{path} (or coffee alternative) and neither existed"
        contents = "0"
    
    @res.end coffee.compile @process_replacements contents

  serve_javascript: (path) ->
    console.log "AssetServer::javascript #{path}"
    @res.writeHead "200", "Content-Type: text/javascript"
    contents = fs.readFileSync "#{@root_dir}#{path}", "UTF-8"
    @res.end contents

  serve_image: (path) ->
    console.log "AssetServer::image #{path}"
    @res.writeHead "200", "Content-Type: text/#{path.substr(path.lastIndexOf('.'))}"
    try
        contents = fs.readFileSync "#{@root_dir}#{path}"
    catch e
        # ...
        console.log "AssetServer::image #{path} !! file not found"
    
    @res.end contents || false

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

