class Quiz
  constructor: (container, @opts={}) ->
    @container = $ container
    @used_types = []
    unless @opts.type?
      @opts.type = @container.find("[name=quiz_type]").val()
      @used_types.push @opts.type
    @data = {}
    @setup()
    @render()

  setup: ->
    @template = _.template $("#quiz-template").html()
    @complete_template = _.template $("#quiz-complete-template").html()
    @$cur_question = @container.find(".cur_question")
    @$progress = @container.find(".progress")
    @all_data = JSON.parse @container.find(".quiz_data").val()
    console.log @all_data
    @data.quiz_data = @all_data[@opts.type]
    @data.state = "setup"
    @setup_events()
    @setup_question(0)

  reset: ->
    @data.quiz_data = @all_data[@opts.type]
    @setup_question(0)

  setup_events: ->
    @container.on "click", ".choice", (e) =>
      e.preventDefault()
      return if $(e.current).data("disabled")
      $(e.currentTarget).data("disabled", true)
      @choice_selected e.currentTarget

    @container.on "click", ".reset_btn", (e) =>
      e.preventDefault()
      @reset()

    @container.on "quiz:choice_selected:correct", =>
      @correct_selection()

    @container.on "quiz:choice_selected:incorrect", =>
      @incorrect_selection()

    @container.on "change", "[name=quiz_type]", (e) =>
      new_type = $(e.currentTarget).val()
      return if new_type == @opts.type
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

  cur_question: ->
    @data.quiz_data.questions[@data.question_idx]

  choice_selected: (el) ->
    $el = $ el
    question = @cur_question()

    result = if question.answer.toString() == $el.data('value').toString()
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

    setTimeout =>
      @progress_quiz()
      # @container.find(".choice").show().removeClass("correct incorrect")
    , 400

  incorrect_selection: ->
    @data.quiz_data.questions[@data.question_idx].result = 0
    setTimeout =>
      @container.find(".incorrect").addClass("hide")
    , 600

    if @container.find(".choice").length == 1
      @reveal_answer()

  reveal_answer: ->
    # todo: something else here? 
    @setup_question @data.question_idx + 1

  progress_quiz: ->
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

$ ->
  if $(".quiz").length
    document.quiz = new Quiz ".quiz"
