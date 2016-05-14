class BeatsPage
  constructor: (container, @opts={}) ->
    @container = $ container
    @setup()

  setup: ->
    @beats = @container.find ".beat"
    @setup_embeds()

  setup_embeds: ->
    return unless @beats
    template = $("#soundcloud_player_template").html()

    for beat in @beats
      $beat = $ beat
      id = $beat.data("soundcloud_id")
      player = template.replace("{{track_id}}", id)
      $beat.append player
