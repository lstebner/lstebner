class Conversions
  constructor: (container, @opts={}) ->
    @container = $ container
    @conversion_type = @container.find("[name=conversion]").val()
    @setup_events()

  setup_events: ->
    @container.on "click", ".convert_btn", (e) =>
      e.preventDefault()
      @convert()

    @container.on "click", ".clear_btn", (e) =>
      e.preventDefault()
      @clear()

    @container.on "change", "[name=conversion]", (e) =>
      e.preventDefault()
      $el = $(e.currentTarget)
      val = $el.val()
      return if val == @conversion_type
      @conversion_type = val
      @convert() 

    @container.on "click", "[name=output]", (e) =>
      $(e.currentTarget).select()

    @container.on "keydown", "[name=input]", (e) =>
      if e.keyCode == 13 && e.metaKey
        e.preventDefault()
        @convert()

  clear: ->
    @container.find("textarea").val("")

  convert: ->
    data =
      input: @container.find("[name=input]").val()
      type: @conversion_type

    $.ajax
      type: "post"
      url: "/ok/convert"
      data: data
      dataType: "json"
      success: (msg) =>
        @container.find("[name=output]").val msg.output

      error: (msg) =>


document.Conversions = Conversions
