Quiz = require("./quiz.js")
JapaneseNumber = require("./japanese_number.js")
dictionary_data = require("./dictionary.js")

module.exports = class QuizBuilder
  @build: (@opts={}, opts={}) ->
    if typeof @opts == "string"
      key = @opts
      @opts = opts
      # special case
      if key == "japanese_numbers"
        {min, max, amount} = @opts
        @opts.question_data = dictionary_data.japanese_numbers min, max, amount
      else if dictionary_data[key]?
        @opts = question_data: dictionary_data[key]

    new Quiz @opts

