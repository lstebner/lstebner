assert = require("assert")
sinon = require("sinon")
View = require("./../class/view.js")

res = {}

beforeEach ->
  res =
    writeHead: sinon.spy()
    end: sinon.spy()

describe "View", ->
  it "should write headers", ->
    view = new View "test_view", res
    view.write_head()
    assert(res.writeHead.calledWith("200", "Content-Type: text/plain"))

  it "should write custom headers", ->
    view = new View "test_view", res, status: 111, content_type: "test/headers"
    view.write_head()
    assert(res.writeHead.calledWith("111", "Content-Type: test/headers"))

  it "should render", ->
    view = new View "test_view", res
    view.render()
    assert(res.writeHead.called)
    assert(res.end.called)
