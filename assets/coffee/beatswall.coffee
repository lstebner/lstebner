class BeatsWall
  constructor: (container, @opts={}) ->
    @container = $ container
    @player = @container.find(".player")
    @setup_events()

  setup_events: ->
    @container.on "click", ".week.on, .beat[data-beat_url]", (e) =>
      e.preventDefault()
      $el = $ e.currentTarget

      if $el.is ".playing"
        $el.removeClass "playing"
        @stop()
      else
        $el.addClass "playing"
        @play $el.data("beat_url")

  play: (url) ->
    audio = @player.find("audio")[0]
    source = @player.find("source")
    @container.find(".week.playing").removeClass("playing")

    # this track is already loaded and not finished
    if url == source.attr("src") && audio.currentTime < audio.duration
      audio.play()
    # load the track
    else
      source.prop("src", url)
      audio.onplay = => @container.find(".week[data-beat_url='#{url}']").addClass("playing")
      audio.onpause = => @container.find(".week[data-beat_url='#{url}']").removeClass("playing")
      audio.oncanplay = (e) =>
        audio.play()
        audio.oncanplay = null
      audio.load()

  stop: ->
    @player.find("audio")[0].pause()

document.BeatsWall = BeatsWall
