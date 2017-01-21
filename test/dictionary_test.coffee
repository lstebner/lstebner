assert = require("assert")
sinon = require("sinon")
Dictionary = require("./../class/dictionary.js")
_ = require("underscore")

describe "Dictionary", ->
  it "should expose the raw data", ->
    assert(_.keys(Dictionary.raw_data()).length > 0)

  it "should look up data", ->
    data = Dictionary.lookup "genki_1"
    assert(data.length == Dictionary.raw_data().genki_1.length)

  it "should allow shorthand lookup", ->
    data = Dictionary.lookup "genki_1"
    data2 = Dictionary.l "genki_1"
    assert(data == data2)

  it "should return null when no data is found", ->
    assert(Dictionary.l('badkey') == null)
