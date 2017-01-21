assert = require("assert")
Conversion = require("./../class/conversion.js")

describe "Conversion", ->
  it "coffee_to_js should convert coffeescript to js", ->
    coffee = "alert \"Hello Test\""
    expected_js = "alert(\"Hello Test\");"
    conversion = new Conversion input: coffee, type: "coffee_to_js"
    assert.equal conversion.output.trim(), expected_js

  it "less_to_css should convert less to css", ->
    less = "@colour: #333; .colored_input { color: @colour; }"
    expected_css = ".colored_input {\n  color: #333;\n}"
    conversion = new Conversion input: less, type: "less_to_css"
    assert.equal conversion.output.trim(), expected_css

  it "yaml_to_json should convert yaml to json", ->
    yaml = "---\nfirst:\n  - one\n  - \n    - two"
    expected_json = '{"first":["one",["two"]]}'
    conversion = new Conversion input: yaml, type: "yaml_to_json"
    assert.equal conversion.output.trim(), expected_json

  it "pug_to_html should convert pug to html", ->
    pug = "p.u#g"
    expected_html = '<p class="u" id="g"></p>'
    conversion = new Conversion input: pug, type: "pug_to_html"
    assert.equal conversion.output.trim(), expected_html

  it "md_to_html should convert markdown to html", ->
    md = "# heading one\n- list item\n- list item"
    expected_html = '<h1 id="heading-one">heading one</h1>\n<ul>\n<li>list item</li>\n<li>list item</li>\n</ul>'
    conversion = new Conversion input: md, type: "md_to_html"
    assert.equal conversion.output.trim(), expected_html

  it "invalid_type should throw an error", ->
    try
      conversion = new Conversion input: "", type: "illegal_type"
    catch e
      assert.equal e.toString(), "Error: conversion type 'illegal_type' not found"         
