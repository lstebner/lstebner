assert = require("assert")
sinon = require("sinon")
Quiz = require("./../class/quiz.js")

describe "Quiz", ->
  afterEach ->
    # this is ugly with the uncertainty that either needs done... reconsider
    Quiz.prototype.setup.restore?()
    Quiz.prototype.setup_questions.restore?()

  it "should take opts", ->
    quiz = new Quiz name: "test_quiz", type: "whatever", num_questions: 99
    assert(quiz.opts.name == "test_quiz")
    assert(quiz.opts.type == "whatever")
    assert(quiz.opts.num_questions == 99)

  it "should should always call setup", ->
    sinon.stub Quiz.prototype, "setup", ->
    quiz = new Quiz()
    assert(quiz.setup.called)

  it "should not call setup questions without question_data", ->
    sinon.stub Quiz.prototype, "setup_questions", ->
    quiz = new Quiz()
    assert(quiz.setup_questions.called == false)

  describe "setup_questions", ->
    quiz_opts = 
      question_data: [[1, "one"], [2, "two"], [3, "three"], [4, "four"], [5, "five"]]
      num_questions: 2
      num_choices: 2

    it "should should call setup_questions", ->
      sinon.stub Quiz.prototype, "setup_questions", ->
      quiz = new Quiz quiz_opts
      assert(quiz.setup_questions.called)

    it "should create #{quiz_opts.num_questions} questions", ->
      quiz = new Quiz quiz_opts
      assert quiz.questions.length == quiz_opts.num_questions

    it "each question should have a question, answer and choices", ->
      quiz = new Quiz quiz_opts
      for q in quiz.questions
        assert q.hasOwnProperty "question"
        assert q.hasOwnProperty "answer"
        assert q.hasOwnProperty "choices"

    it "each question should have #{quiz_opts.num_choices} choices", ->
      quiz = new Quiz quiz_opts
      for q in quiz.questions
        assert q.choices.length == quiz_opts.num_choices


