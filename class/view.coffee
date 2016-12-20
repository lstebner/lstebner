_ = require("underscore")
pug = require("pug")

module.exports = class View
  constructor: (name, @res, @data={}) ->
    @filename = "#{__dirname.replace(/class/, 'views')}/#{name}.pug"

  write_head: (status) ->
    @res.writeHead "#{status}", "Content-Type: text/plain"

  render: (moredata={}) ->
    @data = _.extend @data, moredata
    console.log "render", @filename

    @write_head 200
    try
      html = pug.renderFile @filename, @data
    catch e
      console.log "pug render error:", JSON.stringify(e)
    @res.end html
