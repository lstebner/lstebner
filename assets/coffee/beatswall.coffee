class BeatsWall
  constructor: (container, @opts={}) ->
    @container = $ container
    @player = @container.find(".player")
    @player_data = @player.data()
    @player_data.autoadvance ?= true
    @setup_events()

    if @opts.adjust_beats_list_height
      @adjust_beats_list_height()

  adjust_beats_list_height: ->
    $list = @container.find(".beats_list")
    avail = $(window).height() - $list.offset().top
    $list.height avail

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
      if @_playing_el?.length && @_playing_el.data("beat_url") != $el.data("beat_url")
        @_playing_el.removeClass "selected playing"
      @_playing_el = $el

      if $el.is ".playing"
        $el.removeClass "playing"
        @stop()
      else
        $el.addClass "selected playing"
        @play $el.data("beat_url"), $el.find(".track_name").text()

    @container.on "audio:ended", =>
      if @player_data.autoadvance
        @play_next_beat()

  play_next_beat: ->
    $beat = @_playing_el.addClass("finished").removeClass("selected playing").next(".beat[data-beat_url]")
    unless $beat.length
      $beat = @container.find(".beat[data-beat_url]:first")

    if $beat.length
      $beat.click()
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
      audio.pause() if @state == "playing"
      source.prop("src", url)
      audio.onplay = =>
        play_id = @container.find(".beat[data-beat_url='#{url}']").addClass("playing").data("id")
        @state = "playing"
        @container.trigger "audio:play", play_id
      audio.onpause = =>
        pause_id = @container.find(".beat[data-beat_url='#{url}']").removeClass("playing").data("id")
        @state = "paused"
        @container.trigger "audio:pause", pause_id
      audio.onended = => @container.trigger("audio:ended")
      audio.ontimeupdate = (e) =>
        progress = audio.currentTime / audio.duration
        @container.trigger("audio:progress", progress)
      audio.oncanplay = (e) =>
        audio.play()
        audio.oncanplay = null
        @container.trigger "audio:ready"
      audio.load()

  stop: ->
    @player.find("audio")[0].pause()

  # alias
  pause: -> @stop()

  resume: ->
    @player.find("audio")[0].play()

document.BeatsWall = BeatsWall
