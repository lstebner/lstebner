class Typing
  @States:
    intro: 1
    test: 2
    results: 3

  constructor: (container, @opts={}) ->
    @container = $ container
    @setup()
    @render()

  setup: ->
    @cur_state = Typing.States.intro
    @intro = @container.find(".intro")
    @test = @container.find(".test")
    @results = @container.find(".results")
    @setup_events()

  setup_events: ->
    $(document.body).on "keyup", (e) =>
      return unless @cur_state == Typing.States.intro
      if e.keyCode == 13
        @start_test()

    @container.on "click", ".start_btn", (e) =>
      e.preventDefault()
      @start_test()

    @test.find(".input").on "keydown", (e) => @keypress e.key, e.keyCode

  reset_test_data: ->
    paragraph = TypingParagraphs.gimme()
    paragraph_words = paragraph.split(/\s/)

    @test_data =
      paragraph: paragraph
      paragraph_words: paragraph_words
      num_words: paragraph_words.length
      num_letters: paragraph.length
      num_letters_missed: 0
      accuracy: 100
      cur_letter: 0
      cur_word: 0
      user_inputs: []
      keystrokes: 0
      missed_strokes: 0
      start_time: 0
      finish_time: 0
      time_elapsed: 0

  start_test: ->
    @cur_state = Typing.States.test
    @reset_test_data()
    @render()
    @test.find(".input").focus()
    @test.find(".paragraph span:first").addClass("highlight")

  get_char_at: (idx) ->
    return false if idx < 0 || idx > @test_data.paragraph.length - 1
    @test_data.paragraph[idx]

  get_cur_word: ->
    @test_data.paragraph_words[@test_data.cur_word]

  keypress: (key, keyCode) =>
    return unless @cur_state == Typing.States.test
    # general keyset of [a-z0-9,.'? ]
    return unless _.indexOf([8, 13, 32, 188, 190, 191, 222], keyCode) > -1 || (keyCode > 47 && keyCode < 91)
    if !@test_data.start_time
      @test_data.start_time = Date.now()
    console.log "keycode", keyCode, key
    cur_word = @get_cur_word()
    classes = ["highlight"]

    @test_data.keystrokes++
    @test.find(".score").text @test_data.keystrokes

    # todo: all this up/down management is probably too fragile in reality
    if keyCode == 8
      @test_data.cur_letter--
      if @test_data.cur_letter < 0 && @test_data.cur_word > 0
        @test.find(".paragraph .highlight").removeClass("highlight")
        @test_data.cur_word--
        @test.find(".paragraph span[data-word_idx=#{@test_data.cur_word.toString()}]").addClass(classes.join(" "))
        prev_word = @get_cur_word()
        @test.find(".input").val(@test_data.user_inputs[@test_data.cur_word])
        @test_data.cur_letter =  prev_word.length - 1
    # next word
    else if keyCode == 32 || keyCode == 13
      # score current input against current word
      user_input = @test.find(".input").val().trim()
      @test_data.user_inputs[@test_data.cur_word] = user_input
      is_correct = user_input == @get_cur_word()
      console.log 'is correct', is_correct, user_input, @get_cur_word()

      if is_correct
        classes.push "correct"
      else
        classes.push "incorrect"

      @test.find(".paragraph span[data-word_idx=#{@test_data.cur_word.toString()}]").addClass(classes.join(" "))
      @test.find(".paragraph span.highlight").removeClass("highlight")

      # advance to next word
      @test.find(".input").val("")
      @test_data.cur_letter = 0
      @test_data.cur_word++

      # test finished
      if @test_data.cur_word >= @test_data.num_words
        @test_data.finish_time = Date.now()
        @test_data.time_elapsed = (@test_data.finish_time - @test_data.start_time) / 1000
        @test_data.time_elapsed_formatted = if @test_data.time_elapsed < 60
          "#{@test_data.time_elapsed}s"
        else
          "#{Math.floor @test_data.time_elapsed / 60}m #{Math.round(@test_data.time_elapsed) % 60}s"
        @test_data.accuracy = (@test_data.num_letters - @test_data.missed_strokes) / @test_data.num_letters * 100
        @test_data.wpm = Math.round @test_data.num_words / (@test_data.time_elapsed / 60) * (@test_data.accuracy / 100)
        stats_text = [
          "WPM: #{@test_data.wpm}"
          "Keystrokes: #{@test_data.keystrokes}"
          "Words: #{@test_data.num_words}"
          "Accuracy: #{@test_data.accuracy.toFixed(2)}%"
          "Time: #{@test_data.time_elapsed_formatted}"
        ]
        @test.find(".score").html "Your results...  #{stats_text.join('<br>')}"
    else
      is_correct = key == cur_word[@test_data.cur_letter]
      unless is_correct
        @test_data.missed_strokes++
      @test.find(".paragraph").toggleClass "correct", is_correct
      @test.find(".paragraph").toggleClass "incorrect", !is_correct && keyCode != 8
      @test_data.cur_letter++
      @test.find(".paragraph span[data-word_idx=#{@test_data.cur_word.toString()}]").addClass("highlight")


  render: ->
    switch @cur_state
      when Typing.States.intro
        @intro.show()
        @test.hide()
        @results.hide()
        @container.focus()

      when Typing.States.test
        @intro.hide()
        @render_test_paragraph()
        @test.show()
        @results.hide()

      when Typing.States.results
        @intro.hide()
        @test.hide()
        @results.show()

  render_test_paragraph: ->
    words = @test_data.paragraph.split(/\s/)
    spans = []
    for word, i in words
      spans.push "<span data-word_idx='#{i}'>#{word}</span>"

    @test.find(".paragraph").html spans.join("")



class TypingParagraphs
  @data: [
    "this is a simple paragraph that is meant to be nice and easy to type which is why there will be mommas no periods or any capital letters so i guess this means that it cannot really be considered a paragraph but just a series of run on sentences this should help you get faster at typing as im trying not to use too many difficult words in it although i think that i might start making it hard by including some more difficult letters I'm typing pretty quickly so forgive me for any mistakes i think that i will not just tell you a story about the time i went to the zoo and found a monkey and a fox playing together they were so cute and i think that"
    "It is of my opinion that practice texts should have the function of comments at the end. This would provide interaction between fellow 10FF-arians and the creator of the text. It would also serve as a bigger incentive to do practice texts. Furthermore, commenting is a very popular thing that several typists do and it will be an excellent way to practice typing. Several times when I am in the progress of completing a practice text I really want to say something to the creator of the text. For an example, a text about a parrot and a merchant, what was the three pieces of advice that the parrot was going to give the merchant? I am dying to know...please don't leave stories with cliffhangers..."
    "Advertise block bundle charge check compensate reward access acknowledge activate adjust add allocate allow apologize apply arrange assist bargain check clarify claim collect  gather complete confirm contact customize deactivate deduct dispatch doubt deliver enhance escalate generate guarantee identify inquire look for look up make sure misplace modify overlook provide pull up purchase read rollover remove reassure receive rely reset resolve reach reimburse refund replace retail retrieve schmooze ship stand by suggest struggle summarize take troubleshoot understand upgrade validate verify."
    "According to all known laws of aviation, there is no way a bee should be able to fly. Its wings are too small to get its fat little body off the ground. The bee, of course, flies anyway because bees don't care what humans think is impossible. "
    "In this boring world, many of us try our hardest to make it fun. Many tried to be rich, many tried to have more life experiences. Others travel around the world to see the beautiful sights of the famous tourist spots. There are also people that are content with just having to see their friends everyday and hang out and have a drink with them. Just filling up those irreplaceable memories. Gamers spend most of their time conquering quests, while avid video watchers tend to create videos themselves."
    "We the People of the United States, in Order to form a more perfect Union, establish Justice, insure domestic Tranquility, provide for the common defence, promote the general Welfare, and secure the Blessings of Liberty to ourselves and our Posterity, do ordain and establish this Constitution for the United States of America "
    "Psychology is the study of behavior and mind, embracing all aspects of conscious and unconscious experience as well as thought. It is an academic discipline and a social science which seeks to understand individuals and groups by establishing general principles and researching specific cases. In this field, a professional practitioner or researcher is called a psychologist and can be classified as a social, behavioral, or cognitive scientist. Psychologists attempt to understand the role of mental functions in individual and social behavior, while also exploring the physiological and biological processes that underlie"
    "There was not an inch of room for Lottie and Kezia in the buggy. When Pat swung them on top of the luggage they wobbled; the grandmother's lap was full and Linda Burnell could not possibly have held a lump of a child on hers for any distance. Isabel, very superior, was perched beside the new handyman on the driver's seat. Hold-alls, bags and boxes were piled upon the floor. 'These are absolute necessities that I will not let out of my sight for one instant,' said Linda Burnell, her voice trembling with fatigue and excitement."
    ""

  ]

  @gimme: ->
    TypingParagraphs.data[Math.floor(Math.random() * (TypingParagraphs.data.length - 1))]

document.Typing = Typing
document.TypingParagraphs = TypingParagraphs
