JapaneseNumber = require("./japanese_number.js")
MathGenerator = require("./math_generator.js")
yaml = require("js-yaml")
fs = require("fs")

get_math_problems = (type, opts={}) ->
  mathdata = MathGenerator.generate(type, opts)
  questiondata = []

  for d in mathdata
    questiondata.push [d.question, d.answer]

  questiondata

try 
  yml_load = (filename) ->
    yaml.safeLoad fs.readFileSync "#{__dirname.replace('class', 'dictionary')}/#{filename}.yml"

  japanese_characters = yml_load("japanese_characters")
  genki = yml_load("genki_vocab")
  katakana_misc = yml_load("katakana_misc")

  internal_dictionary =
    "characters.hiragana": japanese_characters.hiragana
    "characters.katakana": japanese_characters.katakana
    time: [
      ["1:00", "いち時"]
      ["1:30", "いち時本"]
      ["2:00", "に時"]
      ["2:30", "に時本"]
      ["3:00", "さん時"]
      ["4:00", "よん時"]
      ["4:30", "よん時本"]
      ["5:00", "ご時"]
      ["6:00", "ろく時"]
      ["6:30", "ろく時本"]
      ["7:00", "なな時"]
      ["8:00", "はち時"]
      ["8:30", "はち時本"]
      ["9:00", "きゅう時"]
      ["10:00", "じゅう時"]
      ["11:00", "じゅういち時"]
      ["12:00", "じゅうに時"]
    ]
    genki_1: genki.genki_1
    genki_2: genki.genki_2
    genki_3: genki.genki_3
    genki_4: genki.genki_4
    genki_5: genki.genki_5
    katakana_misc: katakana_misc
    japanese_numbers: JapaneseNumber.batch(100)
    addition_basic: get_math_problems("addition_basic")
    subtraction_basic: get_math_problems("subtraction_basic")
    multiplication: get_math_problems("multiplication")
catch e
  console.log "Error! Creating dictionary; probably with yaml", e unless process.env.NODE_ENV == "test"

module.exports =
  class Dictionary
    @raw_data: -> internal_dictionary
    @lookup: (what) ->
      if internal_dictionary[what]?
        internal_dictionary[what]
      else
        console.log "Dictionary lookup not found for '#{what}'" unless process.env.NODE_ENV == "test"
        null
    @l: (what) -> Dictionary.lookup(what)

