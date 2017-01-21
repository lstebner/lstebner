class BeatsPage
  constructor: (container, @opts={}) ->
    @container = $ container
    @autoplay = @opts.autoplay ? true
    @setup()

  setup: ->
    @beats = @container.find ".beat"
    @player = @container.find ".audioplayer"
    @soundcloud_template ||= $("#soundcloud_player_template").html()
    @setup_embeds()
    @setup_events()

  setup_events: ->
    @container.on "click", (e) =>
      $el = $(e.target)

      if $el.is(".title") || $el.closest(".title").length
        e.preventDefault()
        $beat = $el.closest(".beat")
        @play_track($beat.data("file"), $beat.data("title"))

  play_track: (src, title) ->
    @player.find("audio").prop("src", src)[0]
    @player.find("audio")[0].play() if @autoplay
    @player.find(".title").text(title)

  setup_embeds: ->
    return unless @beats
    for beat in @beats
      @setup_embed $ beat

    @container.on "click", ".beat", (e) =>
      $el = $ e.currentTarget
      @setup_embed $el

  setup_embed: ($beat) ->
    return if $beat.find("iframe").length

    id = $beat.data("soundcloud_id")
    return unless id
    $beat.append "<div class='soundcloud_placeholder'><img src=\"../images/beats/placeholder_#{id}.jpg\" /></div>"

    $beat.one "click", (e) =>
      $beat = $ e.currentTarget
      id = $beat.data("soundcloud_id")
      player = @soundcloud_template.replace("{{track_id}}", id)
      $beat.find(".soundcloud_placeholder").replaceWith player



