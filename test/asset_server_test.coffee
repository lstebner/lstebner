assert = require("assert")
sinon = require("sinon")
AssertServer = require("./../class/asset_server.js")
fs = require("fs")

res = 
  writeHead: sinon.spy()
  end: sinon.spy()

server = null

beforeEach ->
  server = new AssertServer "#{__dirname}/assets/", res

afterEach ->
  res.writeHead.reset()
  res.end.reset()

describe "AssetServer", ->
  it "serves a stylesheet", ->
    server.serve_stylesheet "style.less"
    assert res.writeHead.calledWith "200", "Content-Type: text/css"

  it "serves a coffeescript", ->
    server.serve_coffeescript "main.coffee"
    assert res.writeHead.calledWith "200", "Content-Type: text/javascript"

  it "serves a javascript", ->
    server.serve_javascript "test.js"
    assert res.writeHead.calledWith "200", "Content-Type: text/javascript"

  it "serves an image", ->
    server.serve_image "test.png"
    assert res.writeHead.calledWith "200", "Content-Type: text/png"

  it "404's when an asset is not found", ->
    server.serve_javascript "whackfilename.js"
    assert res.writeHead.calledWith "404"

  it "serves coffeescript with replacements", ->
    contents = fs.readFileSync "#{__dirname}/assets/replacements.coffee", "utf8"
    contents = server.process_replacements contents
    assert contents.match /PREPEND/
    assert contents.match /INSERT/
    assert contents.match /APPEND/


