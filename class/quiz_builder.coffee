Quiz = require("./quiz.js")
JapaneseNumber = require("./japanese_number.js")
Dictionary = require("./dictionary.js")

module.exports = class QuizBuilder
  # confusing parameters explanation:
  # if building a quiz which you just want to pass opts to, pass them as the first object.
  # optionally, you could pass a "key" (string) in the first slot, in which case use the 
  # second `opts` parameter to pass in the quiz opts hash. When using this variation, the
  # `question_data` is searched for in the Dictionary, otherwise it should be in the hash.
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

