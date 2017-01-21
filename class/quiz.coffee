_ = require("underscore")
MathGenerator = require("./math_generator.js")

module.exports = class Quiz
  constructor: (@opts={}) ->
    @opts = _.extend
      name: ""
      # formats: multiple_choice, recall
      format: "recall"
      type: ""
      num_questions: 20
      num_choices: 4
      question_data: null
      ,@opts
    # array of objects, each is { question: "", answer: "", choices: [] }
    @questions = []
    @selected_choices = []
    @setup()
    @data()

  data: ->
    {
      questions: @questions
      format: @opts.format
    }

  setup: ->
    unless @opts.question_data
      console.info("no question data, type '#{@opts.type}' (ok if expected)") unless process.env.NODE_ENV == "test"
      return

    @setup_questions()

    # switch @opts.format
    #   when "multiple_choice"
    #   when "recall"

  setup_questions: ->
    all_choices = []
    for v in @opts.question_data
      all_choices.push v[0]

    for i in [0...@opts.num_questions]
      choice = @random_choice()
      random_choices = [choice[1]]
      for k in [0...@opts.num_choices - 1]
        c = @random_choice(false)
        random_choices.push c[1]

      random_choices.sort (a) -> if Math.random() * 9 > 3 then 1 else -1
      random_choices.sort (a) -> if Math.random() * 6 > 3 then 1 else -1

      @questions.push
        question: "#{choice[0]}=?".replace("==", "=")
        answer: "#{choice[1]}"
        choices: random_choices

  random_choice: (unique=true) ->
    selected_idx = Math.floor(Math.random() * @opts.question_data.length)
    if unique
      while(_.indexOf(@selected_choices, selected_idx) > -1) && @selected_choices.length < @opts.question_data.length - 1
        selected_idx = Math.floor(Math.random() * @opts.question_data.length)
      @selected_choices.push selected_idx
    @opts.question_data[selected_idx]


