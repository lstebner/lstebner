class Roasts2017
  constructor: (container, @opts={}) ->
    @container = $ container
    @setup_events()

  setup_events: ->
    @container.on "click", ".week.on", (e) =>
      e.preventDefault()
      $el = $ e.currentTarget

      roast_name = $el.data "roast_name"
      @show_lightbox roast_name

    @container.on "click", ".close_btn", (e) =>
      e.preventDefault()
      @close()

    $(document.body).on "keyup", (e) =>
      if e.keyCode == 27
        @close()

    $(document.body).on "click", ".overlay", (e) =>
      @close()

  close: ->
    return unless @lightbox_is_open
    $(".overlay").hide()
    $(".lightbox:visible").remove()
    @lightbox_is_open = false

  show_lightbox: (roast_name, lb_opts={}) ->
    lb_template = _.template $("#roast_lightbox_template").html()
    template = _.template $("##{roast_name}_template").html()
    @overlay = $(".overlay")
    unless @overlay.length
      $("body").append("<div class='overlay'></div>")
      @overlay = $(".overlay")
    @overlay.show()
    lb = $ lb_template()
    lb.find(".content").html template lb_opts
    lb.show()
    $("body").append lb
    @lightbox_is_open = true

document.Roasts2017 = Roasts2017
