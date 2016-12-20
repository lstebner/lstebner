Quiz = require("./quiz.js")
JapaneseNumber = require("./japanese_number.js")

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

dictionary_data =
  "characters.hiragana": [
    ["a", "あ"], ["e", "え"], ["u", "う"], ["i", "い"], ["o", "お"], 
    ["ka", "か"], ["ki", "き"], ["ku", "く"], ["ke", "け"], ["ko", "こ"],
    ["ga", "が"], ["gi", "ぎ"], ["gu", "ぐ"], ["ge", "げ"], ["go", "ご"],
    ["pa", "ぱ"], ["pi", "ぴ"], ["pu", "ぷ"], ["pe", "ぺ"], ["po", "ぽ"],
    ["sa", "さ"], ["shi", "し"], ["su", "す"], ["se", "せ"], ["so", "そ"],
    ["za", "ざ"], ["ji", "じ"], ["zu", "ず"], ["ze", "ぜ"], ["zo", "ぞ"],
    ["ta", "た"], ["chi", "ち"], ["tsu", "つ"], ["te", "て"], ["to", "と"],
    ["da", "だ"], ["ji", "ぢ"], ["zu", "づ"], ["de", "で"], ["do", "ど"],
    ["na", "な"], ["ni", "に"], ["nu", "ぬ"], ["ne", "ね"], ["no", "の"],
    ["ha", "は"], ["hi", "ひ"], ["fu", "ふ"], ["he", "へ"], ["ho", "ほ"],
    ["ba", "ば"], ["bi", "び"], ["bu", "ぶ"], ["be", "べ"], ["bo", "ぼ"],
    ["ma", "ま"], ["mi", "み"], ["mu", "む"], ["me", "め"], ["mo", "も"],
    ["ya" ,"や"], ["yu", "ゆ"], ["yo", "よ"], 
    ["ra", "ら"], ["ri", "り"], ["ru", "る"], ["re", "れ"], ["ro", "ろ"],
    ["wa", "わ"], ["o", "お"], ["n", "ん"]
  ]
  "characters.katakana": [
    ["a", "ア"], ["i", "エ"], ["u", "ウ"], ["e", "イ"], ["o", "オ"],
    ["ka", "カ"], ["ki", "キ"], ["ku", "ク"], ["ke", "ケ"], ["ko", "コ"],
    ["ga", "ガ"], ["gi", "ギ"], ["gu", "グ"], ["ge", "ゲ"], ["go", "ゴ"],
    ["sa", "サ"], ["shi", "シ"], ["su", "ス"], ["se", "セ"], ["so", "ソ"],
    ["za", "ザ"], ["ji", "ジ"], ["zu", "ズ"], ["ze", "ゼ"], ["zo", "ゾ"],
    ["ta", "タ"], ["chi", "チ"], ["tsu", "ツ"], ["te", "テ"], ["to", "ト"],
    ["da", "ダ"], ["ji", "ヂ"], ["zu", "ヅ"], ["de", "デ"], ["do", "ド"],
    ["na", "ナ"], ["ni", "ニ"], ["nu", "ヌ"], ["ne", "ネ"], ["no", "ノ"],
    ["ha", "ハ"], ["hi", "ヒ"], ["fu", "フ"], ["he", "ヘ"], ["ho", "ホ"],
    ["ba", "バ"], ["bi", "ビ"], ["bu", "ブ"], ["be", "ベ"], ["bo", "ボ"],
    ["pa", "パ"], ["pi", "ピ"], ["pu", "プ"], ["pe", "ペ"], ["po", "ポ"],
    ["ma", "マ"], ["mi", "ミ"], ["mu", "ム"], ["me", "メ"], ["mo", "モ"],
    ["ya", "ヤ"], ["yu", "ユ"], ["yo", "ヨ"],
    ["ra", "ラ"], ["ri", "リ"], ["ru", "ル"], ["re", "レ"], ["ro", "ロ"],
    ["wa", "ワ"], ["o", "オ"], ["n", "ン"]
  ]
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
  genki_1: [
    ["あの", "um..."]
    ["いま", "now"]
    ["えいご", "English (language)"]
    ["ええ", "yes (informal)"]
    ["がくせい", "student"]
    ["〜ご", "language suffix"]
    ["こうこう", "high school"]
    ["ごご", "P.M. (time)"]
    ["ごぜん", "A.M. (time)"]
    ["〜さい", "age suffix (~years old)"]
    ["〜さん", "name suffix (mr/mrs/ms)"]
    ["〜じ", "time suffix (o'clock)"]
    ["〜じん", "person suffix"]
    ["せんこう", "major"]
    ["せんせい", "teacher"]
    ["そうです", "that's right"]
    ["そうですか", "is that so?; I see"]
    ["だいがく", "college; university"]
    ["でんわ", "telephone"]
    ["ともだち", "friend"]
    ["なまえ", "name"]
    ["なん・なに", "what"]
    ["にほん", "Japan"]
    ["〜ねんせい", "years in school suffix"]
    ["はい", "yes"]
    ["はん", "half (i.e. half-past)"]
    ["ばんごう", "number"]
    ["りゅうがくせい", "international student"]
    ["わたし", "I"]
    ["アメリカ", "America"]
    ["イギリス", "Britain"]
    ["オーストラリア", "Australia"]
    ["かんこく", "Korea"]
    ["スウェーデン", "Sweeden"]
    ["ちょうごく", "China"]
    ["かがく", "science"]
    ["アジアけんきゅう", "Asian studies"]
    ["けいざい", "economics"]
    ["こくさいかんけい", "international relations"]
    ["コンピューター", "computer"]
    ["じんるいがく", "anthropology"]
    ["せいじ", "politics"]
    ["ビジネス", "business"]
    ["ぶんがく", "literature"]
    ["れきし", "history"]
    ["しごと", "occupation; job; work"]
    ["いしゃ", "doctor"]
    ["かいしゃいん", "office worker"]
    ["こうこうせい", "high school student"]
    ["しゅふ", "housewife"]
    ["だいがくいんせい", "graduate student"]
    ["だいがくせい", "college student"]
    ["べんごし", "lawyer"]
    ["おかあさん", "mother"]
    ["おとうさん", "father"]
    ["おねえさん", "older sister"]
    ["おにいさん", "older brother"]
    ["いもうと", "younger sister"]
    ["おとうと", "younger brother"]
  ]
  genki_2: [
    ["これ", "this one"]
    ["それ", "that one"]
    ["あれ", "that one over there"]
    ["どれ", "which one"]
    ["この", "this"]
    ["その", "that"]
    ["あの", "that over there"]
    ["どの", "which"]
    ["ここ", "here"]
    ["そこ", "there"]
    ["あそこ", "over there"]
    ["どこ", "where"]
    ["だれ", "who"]
    ["おいしい", "delicious"]
    ["さかな", "fish"]
    ["とんかつ", "pork cutlet"]
    ["にく", "meat"]
    ["メニュー", "menu"]
    ["やさい", "vegetables"]
    ["えんぴつ", "pencil"]
    ["かさ", "umbrella"]
    ["かばん", "bag"]
    ["くつ", "shoes"]
    ["さいふ", "wallet"]
    ["ジーンズ", "jeans"]
    ["じしょ", "dictionary"]
    ["じてんしょ", "bike"]
    ["しんぶん", "newspaper"]
    ["Tシャツ", "tshirt"]
    ["とけい", "clock"]
    ["ノート", "note"]
    ["ぺん", "pen"]
    ["ぼうし", "hat"]
    ["ほん", "book"]
    ["きっさてん", "cafe"]
    ["ぎんこう", "bank"]
    ["トイレ", "toilet"]
    ["としょかん", "library"]
    ["ようびんきょく", "post office"]
    ["アメリカ", "America"]
    ["イゲリス", "Britain"]
    ["かんこく", "Korea"]
    ["ちゅうがく", "China"]
    ["けいざい", "economics"]
    ["コンピューター", "computer"]
    ["ビジネス", "business"]
    ["れきし", "history"]
    ["おかあさん", "mother"]
    ["おとうさん", "father"]
    ["いくら", "how much"]
    ["〜えん", "yen"]
    ["たかい", "expensive; high"]
    ["いらっしゃいませ", "welcome (to our store)"]
    ["〜お　おねがいします", "...please"]
    ["〜お　ください", "please give me..."]
    ["じゃあ", "then..."]
    ["どうぞ", "please; here it is"]
    ["どうも", "thank you"]
  ]
  genki_3: [
    ["えいが", "movie"]
    ["おんがく", "music"]
    ["ざっし", "magazine"]
    ["スポーツ", "sports"]
    ["デート", "date"]
    ["テニス", "tennis"]
    ["テレビ", "television"]
    ["アイスクリーム", "icecream"]
    ["あさごはん", "breakfast"]
    ["おさけ", "sake"]
    ["おちゃ", "tea"]
    ["コーヒー", "coffee"]
    ["ばんごはん", "breakfast"]
    ["ハンバーガー", "hamburger"]
    ["ひるごはん", "dinner"]
    ["みず", "water"]
    ["いえ", "home"]
    ["うち", "my home"]
    ["がっこう", "school"]
    ["あさ", "morning"]
    ["あした", "tomorrow"]
    ["いつ", "when"]
    ["きょう", "today"]
    ["〜ごろ", "~at about (time)"]
    ["こんばん", "bag"]
    ["しゅうまつ", "weekend"]
    ["どようび", "saturday"]
    ["にちようび", "sunday"]
    ["まいにち", "every day"]
    ["まいばん", "every night"]
    ["いく", "to go"]
    ["かえる", "to return"]
    ["きく", "to listen"]
    ["のむ", "to drink"]
    ["はなす", "to speak"]
    ["よむ", "to read"]
    ["おきる", "to get up"]
    ["たべる", "to eat"]
    ["ねる", "to go to sleep"]
    ["みる", "to watch; to see"]
    ["くる", "to come (destination)"]
    ["する", "to do"]
    ["べんきょうします", "to study"]
    ["いい", "good"]
    ["はやい", "early"]
    ["あまり＋negative", "not much"]
    ["ぜんぜん＋negative", "not at all"]
    ["たいてい", "usually"]
    ["ちょっと", "a little"]
    ["ときどき", "sometimes"]
    ["よく", "often"]
    ["そうですね", "that's right; let me see"]
    ["でも", "but"]
    ["どうですか", "how about..? how is..?"]
  ]
  japanese_numbers: (min=0, max=10000, amount=100) ->
    data = []
    for i in [0...amount]
      num = new JapaneseNumber Math.floor(Math.random() * max + min)
      data.push [num.number, num.number_japanese]

    data
