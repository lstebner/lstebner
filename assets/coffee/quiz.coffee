class Quiz
  constructor: (container, @opts={}) ->
    @container = $ container
    @used_types = []
    @setup()
    @render()

  setup: ->
    # formats: multiple_choice, recall
    @data = state: "setup"
    @opts.format ?= @container.find("[name=quiz_format]").val()
    @template = _.template $("#quiz-#{@opts.format}-template").html()
    @complete_template = _.template $("#quiz-complete-template").html()
    @$cur_question = @container.find(".cur_question")
    @$progress = @container.find(".progress")
    @all_data = JSON.parse @container.find(".quiz_data").val()
    @data.quiz_data = @all_data[@opts.type]

    unless @opts.type?
      @opts.type = @container.find("[name=quiz_type]").val()
      @set_quiz_type @opts.type

    @setup_events()
    @setup_question(0)

  reset: ->
    @data.quiz_data = @all_data[@opts.type]
    @setup_question(0)

  setup_events: ->
    @container.unbind()
    
    # shared events
    @container.on "click", ".reset_btn", (e) =>
      e.preventDefault()
      @set_quiz_type @opts.type
      @reset()

    @container.on "change", "[name=quiz_format]", (e) =>
      new_format = $(e.currentTarget).val()
      return if new_format == @opts.format
      @opts.format = new_format
      @reset()
      @setup()
      @render()

    @container.on "change", "[name=quiz_type]", (e) =>
      new_type = $(e.currentTarget).val()
      return if new_type == @opts.type
      @set_quiz_type new_type

    switch @opts.format
      when "recall"
        @setup_recall_events()

      when "multiple_choice"
        @setup_multiple_choice_events()

  set_quiz_type: (new_type) ->
    @opts.type = new_type

    if _.indexOf(@used_types, @opts.type) > -1
      @used_types = []
      $.ajax
        type: "get"
        url: "/a/quizdata"
        dataType: "json"
        success: (res) =>
          @used_types.push @opts.type
          @all_data = res
          @reset()
    else
      @used_types.push @opts.type
      @reset()

  setup_multiple_choice_events: ->
    @container.on "click", ".choice", (e) =>
      e.preventDefault()
      return if $(e.current).data("disabled")
      $(e.currentTarget).data("disabled", true)
      @choice_selected e.currentTarget

    @container.on "quiz:choice_selected:correct", =>
      @correct_selection()

    @container.on "quiz:choice_selected:incorrect", =>
      @incorrect_selection()

  setup_recall_events: ->
    @container.on "submit", "form", (e) =>
      e.preventDefault()
      user_answer = @container.find(".input").val()
      is_correct = @check_answer user_answer
      if is_correct
        @correct_selection()
      else
        @incorrect_selection()

    @container.on "click", ".skip_btn", (e) =>
      e.preventDefault()
      @skip_question()
      false

  check_answer: (ans) ->
    ans.toString() == @cur_question().answer.toString()

  cur_question: ->
    @data.quiz_data.questions[@data.question_idx]

  choice_selected: (el) ->
    $el = $ el

    result = if @check_answer $el.data('value').toString()
      "correct"
    else
      "incorrect"

    $el.addClass result
    @container.trigger "quiz:choice_selected:#{result}"

  setup_question: (idx=0, do_render=true) ->
    return unless @data.quiz_data
    return console.log("index out of range") if idx < 0 || idx > @data.quiz_data.questions.length
    @data.state = "in_quiz"
    @data.question_idx = idx
    question = @cur_question()
    @data.question = question.question
    @data.choices = question.choices
    @render() if do_render

  render: ->
    if @data.state == "complete"
      @render_complete()
    else
      @render_question()
    @render_progress()
    @container.find(".input").focus() if @opts.format == "recall"

  render_question: ->
    @$cur_question.html @template @data

  render_complete: ->
    data =
      num_correct: 0
      num_total: @data.quiz_data.questions.length
      correct_percent: 0
      missed_questions: []

    for q in @data.quiz_data.questions
      if q.result
        data.num_correct += 1 
      else
        data.missed_questions.push q

    data.correct_percent = Math.round(data.num_correct/data.num_total*100)

    @$cur_question.html @complete_template data

  render_progress: ->
    @$progress.html("")
    newhtml = ""
    for i in [0...@data.quiz_data.questions.length]
      cls = if i < @data.question_idx
        "past " + (["incorrect", "correct"])[@data.quiz_data.questions[i].result]
      else if i == @data.question_idx
        "current"
      else
        "ahead"

      newhtml += "<span class='circle #{cls}'></span>"

    @$progress.html newhtml

  correct_selection: ->
    unless @data.quiz_data.questions[@data.question_idx].result?
      @data.quiz_data.questions[@data.question_idx].result = 1
    @container.removeClass("incorrect_answer").addClass("correct_answer")

    setTimeout =>
      @progress_quiz()
    , 400

  incorrect_selection: ->
    @container.removeClass("correct_answer").addClass("incorrect_answer")
    @data.quiz_data.questions[@data.question_idx].result = 0

    if @opts.format == "multiple_choice"
      setTimeout =>
        @container.find(".incorrect").addClass("hide")
      , 600

      if @container.find(".choice").length == 1
        @reveal_answer()

  reveal_answer: ->
    # todo: something else here? 
    @setup_question @data.question_idx + 1

  progress_quiz: ->
    @container.removeClass "correct_answer incorrect_answer"
    if @data.question_idx == @data.quiz_data.questions.length - 1
      @test_complete()
    else
      @setup_question @data.question_idx + 1
      @render()

  test_complete: ->
    # todo: the end
    @data.question_idx += 1
    @data.state = "complete"
    @render()

  skip_question: ->
    question = @cur_question()
    @container.find(".input").val(question.answer)
    @incorrect_selection()
    setTimeout =>
      @progress_quiz()
    , 900

$ ->
  if $(".quiz").length
    document.quiz = new Quiz ".quiz"
