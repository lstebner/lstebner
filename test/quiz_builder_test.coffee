assert = require("assert")
sinon = require("sinon")
QuizBuilder = require("./../class/quiz_builder.js")
Quiz = require("./../class/quiz.js")

describe "QuizBuilder", ->
  it "should build a quiz", ->
    quiz = QuizBuilder.build()
    assert(quiz instanceof Quiz)

  it "should pass settings to quiz", ->
    quiz = QuizBuilder.build({ name: "test_quiz" })
    assert(quiz.opts.name == "test_quiz")

  it "should also pass settings as the second parameter", ->
    quiz = QuizBuilder.build("japanese_vocab", { name: "test_quiz" })
    assert(quiz.opts.name == "test_quiz")

  it "should look up question data when possible", ->
    quiz = QuizBuilder.build("japanese_numbers")
    assert(quiz.opts.question_data.length > 0)
