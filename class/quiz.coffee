_ = require("underscore")
MathGenerator = require("./math_generator.js")

module.exports = class Quiz
  constructor: (@opts={}) ->
    @opts = _.extend
      name: ""
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
    }

  setup: ->
    if @opts.type == "math"
      @setup_math_questions @opts.math_opts

    return console.info("no question data, type '#{@opts.type}' (ok if expected)") unless @opts.question_data
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
        question: "#{choice[0]}=?"
        answer: "#{choice[1]}"
        choices: random_choices

  random_choice: (unique=true) ->
    selected_idx = Math.floor(Math.random() * @opts.question_data.length)
    if unique
      while(_.indexOf(@selected_choices, selected_idx) > -1)
        selected_idx = Math.floor(Math.random() * @opts.question_data.length)
      @selected_choices.push selected_idx
    @opts.question_data[selected_idx]

  setup_math_questions: (math_opts={}) ->
    generator = new MathGenerator(math_opts)
    @questions = generator.generate()
