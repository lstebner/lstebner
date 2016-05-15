class BeatsPage
  constructor: (container, @opts={}) ->
    @container = $ container
    @setup()

  setup: ->
    @beats = @container.find ".beat"
    @soundcloud_template ||= $("#soundcloud_player_template").html()
    @setup_embeds()

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
    $beat.append "<div class='soundcloud_placeholder'><img src=\"../images/beats/placeholder_#{id}.jpg\" /></div>"

    $beat.one "click", (e) =>
      $beat = $ e.currentTarget
      id = $beat.data("soundcloud_id")
      player = @soundcloud_template.replace("{{track_id}}", id)
      $beat.find(".soundcloud_placeholder").replaceWith player
