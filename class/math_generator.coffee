_ = require("underscore")

module.exports = class MathGenerator
  constructor: (@opts={}) ->
    @generate()

  generate: (force=false) ->
    return @questions if @questions? && !force

    questions = []
    choices_pool = []
    lowest_num = @opts.lowest_num || 0
    highest_num = @opts.highest_num || 30
    num_questions = @opts.num_questions || 20
    num_choices = @opts.num_choices || 4

    for i in [0...num_questions]
      num1 = Math.floor (Math.random() * (highest_num - lowest_num)) + lowest_num
      num2 = Math.floor (Math.random() * (highest_num - lowest_num)) + lowest_num
      op = if Math.random() * 6 > 2 then "+" else "-"
      exp = "#{num1}#{op}#{num2}"
      ans = eval(exp)
      question = "#{exp}=?"
      choices_pool.push ans
      questions.push
        question: question
        answer: ans
        choices: [ans]

    for i in [-highest_num...highest_num*2]
      choices_pool.push i

    for q in questions
      for i in [0...num_choices - 1]
        new_choice = choices_pool[Math.floor(Math.random() * choices_pool.length)]
        while _.indexOf(q.choices, new_choice) > -1
          new_choice = choices_pool[Math.floor(Math.random() * choices_pool.length)]

        q.choices.push new_choice

      q.choices.sort (a) -> if Math.random() * 6 > 3 then 1 else -1
      q.choices.sort (a) -> if Math.random() * 9 > 3 then 1 else -1

    @questions = questions
