class Timeline
  constructor: (container) ->
    @container = $ container
    @setup_events()
    @setup_players()

  setup_events: ->
    @container.on "click", ".main_cover", (e) =>
      $el = $ e.currentTarget
      @zoom_image $el.find("img").attr("src")

    @container.on "click", "img.zoomable", (e) =>
      $el = $ e.currentTarget
      @zoom_image $el.attr("src")

    @container.on "click", ".show_all_translations", (e) =>
      e.preventDefault()
      $el = $ e.currentTarget
      @toggle_translations_visibility $el

    $(document.body).on "keydown", (e) =>
      if e.keyCode == 27 && @overlay.is(":visible")
        @overlay.fadeOut(100)

  setup_overlay: ->
    unless @overlay?
      @overlay = $("<div class='overlay'><div class='overlay_container'><img/></div></div>")
      $(document.body).prepend @overlay

    @overlay.one "click", => @overlay.fadeOut(100)

  setup_players: ->
    for player in @container.find ".player"
      $p = $ player
      src = $p.data("song")
      player_html = "<audio preload='auto' autobuffer controls><source src='#{src}'></source></audio>"
      $p.html player_html

  zoom_image: (img_src) ->
    console.log "zoom", img_src
    @setup_overlay()
    @overlay.find("img").attr("src", img_src)
    @overlay.fadeIn(100)

  toggle_translations_visibility: ($btn) =>
    $btn.parent().find(".vocab_list").toggleClass("show_all_translations")
    label = $btn.text()
    if label.indexOf("Show") > -1
      $btn.text label.replace "Show", "Hide"
    else
      $btn.text label.replace "Hide", "Show"

$ ->
  if $(".posts").length
    document.timeline = new Timeline ".posts"
