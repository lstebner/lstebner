_ = require("underscore")


class MathGenerator
  @generate: (type, opts={}, return_generator=false) ->
    generator_cls = switch type
      when "addition_basic"
        opts.upper_limit = 20
        Generators.AdditionBasic
      when "addition_intermediate"
        Generators.AdditionBasic
      when "subtraction_basic"
        opts.upper_limit = 25
        Generators.SubtractionBasic
      when "multiplication"
        Generators.Multiplication
      when "addition_long"
        Generators.AdditionLong
      when "addition_variable"
        opts.insert_var = true
        Generators.AdditionBasic
      when "multiplication_variable"
        opts.insert_var = true
        Generators.Multiplication
      when "multiplication_doubles"
        opts.doubles = true
        opts.upper_limit = 20
        opts.num_questions = 12
        Generators.Multiplication
      when "addition_chain"
        null
      else
        MathGenerator

    generator = new generator_cls opts
    if return_generator
      generator
    else
      generator.questions

  constructor: (@opts={}) ->
    @generate(true)

  generate: (force=false) ->
    return @questions if @questions? && !force

    questions = []
    choices_pool = []
    lowest_num = @opts.lowest_num || 0
    highest_num = @opts.highest_num || 26
    num_questions = @opts.num_questions || 26
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


Generators = {}
class Generators.AdditionBasic extends MathGenerator
  generate: (force=false) ->
    questions = []
    num_questions = @opts.num_questions || 26

    for i in [0...num_questions]
      if @opts.insert_var
        upper_limit = lower_limit = @opts.lower_limit || 25
      else
        lower_limit = @opts.lower_limit || 10
        upper_limit = @opts.upper_limit || 50
        
      num1 = Math.floor Math.random() * lower_limit
      num2 = Math.floor Math.random() * upper_limit
      exp = "#{num1} + #{num2}"
      ans = eval(exp)

      if @opts.insert_var
        char = "xyzna".charAt Math.floor Math.random() * 5
        exp = exp.replace "+ #{num2}", "+ #{char}"
        question = "#{exp} = #{ans}; #{char} ="
      else
        question = "#{exp.replace('*', 'x')} =" 

      questions.push
        question: question 
        answer: ans
        variable: if @opts.insert_var then char else false

    @questions = questions

class Generators.SubtractionBasic extends MathGenerator
  generate: (force=false) ->
    questions = []
    num_questions = @opts.num_questions || 26

    for i in [0...num_questions]
      num1 = Math.floor Math.random() * (@opts.upper_limit || 50)
      num2 = Math.floor Math.random() * (@opts.lower_limit || 10)
      # keep it positive
      if num2 > num1
        oldnum1 = num1
        num1 = num2
        num2 = oldnum1
      exp = "#{num1} - #{num2}"
      ans = eval(exp)

      questions.push
        question: "#{exp} ="
        answer: ans

    @questions = questions

class Generators.Multiplication extends MathGenerator
  generate: (force=false) ->
    questions = []
    num_questions = @opts.num_questions || 26

    for i in [0...num_questions]
      if @opts.doubles
        num2 = num1 = Math.floor Math.random() * (@opts.upper_limit || 17) + 1
      else
        num1 = Math.floor Math.random() * (@opts.upper_limit || 10)
        num2 = Math.floor Math.random() * (@opts.upper_limit || 10) + 1

      exp = "#{num1} * #{num2}"
      ans = eval(exp)

      if @opts.insert_var
        char = "xyzna".charAt Math.floor Math.random() * 5
        exp = exp.replace " * #{num2}", char
        question = "#{exp} = #{ans}; #{char} ="
      else
        question = "#{exp.replace('*', 'x')} =" 

      questions.push
        question: question
        answer: ans
        variable: if @opts.insert_var then char else false

    @questions = questions

class Generators.AdditionLong extends MathGenerator
  generate: (force=false) ->
    questions = []
    num_questions = @opts.num_questions || 26

    for i in [0...num_questions]
      num_numbers = Math.ceil Math.random() * 3 + 2
      numbers = for k in [0...num_numbers]
        Math.floor Math.random() * 15
      exp = numbers.join " + "
      ans = eval(exp)

      questions.push
        question: "#{exp} ="
        answer: ans

    @questions = questions


module.exports = MathGenerator
