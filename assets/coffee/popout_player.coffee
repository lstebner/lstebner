class Toast
  @register_toast: (toast) ->
    @_toasts ||= []
    for t in @_toasts
      t.hide()

    @_toasts.push toast

  constructor: (@msg, @color="#66a1ee", show=true, hide_after=3000) ->
    @setup()
    if show
      @render(hide_after)

  setup: ->
    @$html = $ "<div class='toast' style='background-color: #{@color};'>#{@msg}</div>"

    @$html.on "click", (e) =>
      @hide()

  hide: (remove=true) ->
    clearTimeout(@_timeout) if @_timeout?
    @$html.fadeOut =>
      @$html.remove() if remove

  render: (hide_after=0) ->
    $(document.body).append @$html.fadeIn()
    Toast.register_toast @

    if hide_after > 0
      @_timeout = setTimeout =>
        @hide()
      , hide_after

class PopoutPlayer extends Jukebox
  constructor: (container, @opts={}) ->
    super

    @song_data = if @opts.song_data? then @opts.song_data else []
    @$now_playing = @container.find(".now_playing_bar")

  setup_events: ->
    super

    # song was loaded
    @container.on "audio:ready", =>

    # song began playing, at beginning and also after resume
    @container.on "audio:play", (e, id) =>
      @$now_playing.addClass("playing")
      @update_now_playing id: id
      new Toast "Now playing #{@now_playing_song.name}"

    @container.on "audio:pause", (e, id) =>
      @$now_playing.removeClass("playing")

    # song is being playing, updates regularly
    @container.on "audio:progress", _.throttle (e, progress) =>
      @update_now_playing_progress progress
    , 500

    @container.on "audio:ended", =>

    @container.on "click", ".icon-play", (e) =>
      @resume()

    @container.on "click", ".icon-pause", (e) =>
      @pause()

    @container.on "click", ".toggle_control", (e) =>
      e.preventDefault()
      @$now_playing.toggleClass "shrunk"
      if @$now_playing.hasClass "shrunk"
        $(e.currentTarget).text "show"
      else
        $(e.currentTarget).text "hide"

      @container.trigger "playlist:reshape"

    @container.on "playlist:reshape", =>
      if @$now_playing.is(":visible")
        @container.find(".playlist").height $(window).height() - @$now_playing.outerHeight()
      else
        @container.find(".playlist").height "100%"

    @container.on "songs:filtered", (e, keys) =>
      keys_str = "Filtering list to show "
      if keys.length == 0
        keys_str = "Back to showing all songs"
      else
        for key, i in keys
          if i > 0 && (i == keys.length - 1 || keys.length == 2)
            keys_str += ", and "
          else if i > 0
            keys_str += ", "
          keys_str += key.replace(/_/g, " ")

      new Toast keys_str

    $(window).on "orientationchange", => setTimeout (=>@container.trigger "playlist:reshape"), 100

  get_song: (id) ->
    _.where(@song_data, id: parseInt(id))[0] || false

  # pass updates as key/val pairs
  # i.e. { id: 3, duration: "3:47", progress: "1:01" }
  update_now_playing: (updates={}) ->
    $tmpl = _.template $("#now_playing_metadata_template").html()
    if updates.id?
      @now_playing_song = @get_song updates.id
    return unless @now_playing_song?

    audio = @container.find(".player audio")[0]

    data =
      title: @now_playing_song.name
      progress: @format_time audio.currentTime
      duration: @format_time audio.duration
      tags: @now_playing_song.tags.join(" ")

    @$now_playing.find(".metadata").html $tmpl data

    unless @$now_playing.is(":visible")
      @$now_playing.fadeIn().trigger "playlist:reshape"

  format_time: (time) ->
    if time < 10
      "0:0#{Math.floor time}"
    else if time < 60
      "0:#{Math.floor time}"
    else
      "#{Math.floor(time / 60)}:#{Math.floor time % 60}"

  update_now_playing_progress: (progress) ->
    audio = @container.find(".player audio")[0]
    progress_label = @format_time audio.currentTime

    @$now_playing.find(".progress_bar .fill").css width: "#{progress * 100}%"
    @$now_playing.find(".progress_bar .handle").css left: "#{progress * 100}%"
    @$now_playing.find(".cur_progress").text progress_label

document.PopoutPlayer = PopoutPlayer
