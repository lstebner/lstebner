coffee = require("coffee-script")
less = require("less")
yaml = require("js-yaml")
marked = require("marked")
pug = require("pug")

class Conversion
  constructor: (@opts={}) ->
    {@input, @type} = @opts
    @output = false
    @convert()

  convert: ->
    switch @type
      when "coffee_to_js"
        @output = coffee.compile @input, bare: true
      when "less_to_css"
        less.render @input, {}, (e, output) =>
          @output = output.css
      when "yaml_to_json"
        @output = JSON.stringify yaml.safeLoad @input
      when "pug_to_html"
        @output = pug.render @input, pretty: true
      when "md_to_html"
        @output = marked @input
      else
        throw new Error "conversion type '#{@type}' not found"

    @output


module.exports = Conversion
