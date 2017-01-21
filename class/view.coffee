_ = require("underscore")
pug = require("pug")

module.exports = class View
  constructor: (name, @res, @data={}) ->
    @data.status ?= 200
    @data.content_type ?= "text/plain"
    @filename = "#{__dirname.replace(/class/, 'views')}/#{name}.pug"

  write_head: (status=@data.status, content_type=@data.content_type) ->
    @res.writeHead "#{status}", "Content-Type: #{content_type}"

  render: (moredata={}) ->
    @data = _.extend @data, moredata
    console.log "render", @filename if process.env.NODE_ENV != "test"

    @write_head()
    try
      html = pug.renderFile @filename, @data
    catch e
      unless process.env.NODE_ENV == "test"
        console.log "pug render error:", JSON.stringify(e)
    @res.end html
