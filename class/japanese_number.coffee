module.exports = class JapaneseNumber
  @lookup:
    0: "ゼロ"
    1: "いち"
    2: "に"
    3: "さん"
    4: "よん"
    5: "ご"
    6: "ろく"
    7: "なな"
    8: "はち"
    9: "きゅう"
    10: "じゅう"
    100: "ひゃく"
    300: "さんびゃく"
    600: "ろっぴゃく"
    800: "はっぴゃく"
    1000: "せん"
    3000: "さんぜん"
    8000: "はっせん"
    10000: "まん"

  @batch: (min=0, max=10000, amount=100) ->
    data = []
    for i in [0...amount]
      num = new JapaneseNumber Math.floor(Math.random() * max + min)
      data.push [num.number, num.number_japanese]
    data

  constructor: (@number=0) ->
    @number_japanese = @convert @number

  convert: (num=@number) ->
    str = ""
    if JapaneseNumber.lookup[num]
      str += JapaneseNumber.lookup[num]
    else
      divisions = [10000, 1000, 100, 10]
      for division in divisions 
        if num > division
          times = Math.floor num / division
          if JapaneseNumber.lookup[division * times]?
            str += JapaneseNumber.lookup[division * times]
          else
            str += @convert(times) + JapaneseNumber.lookup[division]

          remain = num % (division * times)
          if remain > 0
            str += @convert remain
          break

    str

  int: -> @number
  japanese: -> @number_japanese

  set: (@number) ->
    @number_japanese = @convert()

