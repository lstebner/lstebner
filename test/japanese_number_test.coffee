assert = require("assert")
JapaneseNumber = require("./../class/japanese_number.js")

describe "JapaneseNumber", ->
  it "converts a number", ->
    jn = new JapaneseNumber()
    assert.equal jn.convert(1), "いち"

  it "converts a number from the constructor", ->
    jn = new JapaneseNumber 2
    assert.equal jn.japanese(), "に"

  it "stores the original number", ->
    jn = new JapaneseNumber 55
    assert.equal jn.int(), 55

  it "can be set after created", ->
    jn = new JapaneseNumber 1
    assert.equal jn.japanese(), "いち"
    jn.set 2
    assert.equal jn.japanese(), "に"

  it "can generate a batch of numbers", ->
    batch = JapaneseNumber.batch(0, 1000, 100)
    assert.equal batch.length, 100
