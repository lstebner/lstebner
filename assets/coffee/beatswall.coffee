class BeatsWall
  constructor: (container, @opts={}) ->
    @container = $ container
    @player = @container.find(".player")
    @player_data = @player.data()
    @setup_events()

  setup_events: ->
    $(document.body).on "keydown", (e) =>
      # keep space from scrolling, we use it for play/pause
      $el = $(e.currentTarget)
      if e.keyCode == 32 && !$el.closest("form").length
        e.preventDefault()

    $(document.body).on "keyup", (e) =>
      switch e.keyCode
        when 32
          if @state == "playing"
            @pause()
          else
            @resume()
          false

    @container.on "click", ".week.on, .beat[data-beat_url]", (e) =>
      e.preventDefault()
      $el = $ e.currentTarget

      if $el.is ".playing"
        $el.removeClass "playing"
        @stop()
      else
        $el.addClass "playing"
        @play $el.data("beat_url"), $el.find(".track_name").text()

    @container.on "audio:ended", =>
      console.log @player_data
      if @player_data.autoadvance
        $beat = @container.find(".beat.playing").removeClass("playing")
        if $beat.next(".beat").length
          $beat.next(".beat").click()
        else
          @container.trigger "playlist:ended"

  play: (url, track_title="") ->
    @state = "loading"
    audio = @player.find("audio")[0]
    source = @player.find("source")
    @container.find(".week.playing, .beat.playing").removeClass("playing")
    @player.find(".now_playing_title").text track_title

    # this track is already loaded and not finished
    if url == source.attr("src") && audio.currentTime < audio.duration
      audio.play()
    # load the track
    else
      source.prop("src", url)
      audio.onplay = =>
        @container.find(".week[data-beat_url='#{url}']").addClass("playing")
        @state = "playing"
      audio.onpause = =>
        @container.find(".week[data-beat_url='#{url}']").removeClass("playing")
        @state = "paused"
      audio.onended = => @container.trigger("audio:ended")
      audio.oncanplay = (e) =>
        audio.play()
        audio.oncanplay = null
      audio.load()

  stop: ->
    @player.find("audio")[0].pause()

  # alias
  pause: -> @stop()

  resume: ->
    @player.find("audio")[0].play()

document.BeatsWall = BeatsWall
