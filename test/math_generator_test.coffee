assert = require("assert")
sinon = require("sinon")
MathGenerator = require("./../class/math_generator.js")

describe "MathGenerator", ->
  afterEach ->
    MathGenerator.prototype.generate.reset?()

  it "calls generate on construction", ->
    MathGenerator.prototype.generate = sinon.spy()
    gen = new MathGenerator()
    assert gen.generate.called

  it "creates a generator through the static generate method", ->
    MathGenerator.prototype.generate = sinon.spy()
    gen = MathGenerator.generate "whatevz", {}, true
    assert gen.generate.called

describe "MathGenerator's", ->
  it "generates addition_basic", ->
    questions = MathGenerator.generate "addition_basic"
    assert questions.length > 0
    assert questions[0].question.indexOf("+") > -1

  it "generates addition_intermediate", ->
    questions = MathGenerator.generate "addition_intermediate"
    assert questions.length > 0
    assert questions[0].question.indexOf("+") > -1

  it "generates subtraction_basic", ->
    questions = MathGenerator.generate "subtraction_basic"
    assert questions.length > 0
    assert questions[0].question.indexOf("-") > -1

  it "generates multiplication", ->
    questions = MathGenerator.generate "multiplication"
    assert questions.length > 0
    assert questions[0].question.indexOf("x") > -1

  it "generates addition_long", ->
    questions = MathGenerator.generate "addition_long"
    assert questions.length > 0
    assert questions[0].question.match(/\+/g).length > 1

  it "generates addition_variable", ->
    questions = MathGenerator.generate "addition_variable"
    assert questions.length > 0
    assert questions[0].question.indexOf("+") > -1
    assert questions[0].question.match questions[0].question.variable

  it "generates multiplication_variable", ->
    questions = MathGenerator.generate "multiplication_variable"
    assert questions.length > 0
    assert questions[0].question.match questions[0].question.variable

  it "generates multiplication_doubles", ->
    questions = MathGenerator.generate "multiplication_doubles"
    assert questions.length > 0
    assert questions[0].question.indexOf("x") > -1
