Quiz = require("./quiz.js")
JapaneseNumber = require("./japanese_number.js")
Dictionary = require("./dictionary.js")

module.exports = class QuizBuilder
  @build: (@opts={}, opts={}) ->
    if typeof @opts == "string"
      key = @opts
      @opts = opts
      # special case
      if key == "japanese_numbers"
        {min, max, amount} = @opts
        @opts.question_data = JapaneseNumber.batch min, max, amount
      else if val = Dictionary.lookup(key)
        @opts = question_data: val

    new Quiz @opts

