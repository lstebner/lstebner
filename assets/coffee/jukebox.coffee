class Jukebox extends document.BeatsWall
  setup_events: ->
    super

    @container.on "click", ".playlists .playlist, .playlist_pill", (e) =>
      e.preventDefault()
      $(e.currentTarget).toggleClass "selected"
      selected_keys = []
      for el in @container.find(".playlists .selected")
        key = $(el).data("key")
        selected_keys.push key

      @show_tagged selected_keys
      @container.trigger "songs:filtered", [selected_keys]

    @container.on "audio:play", (e) =>
      $list = @container.find(".beats_list")
      $playing = $list.find(".playing")
      midy = $list.height() / 2
      scroll_to = $list.scrollTop() + $playing.offset().top - midy

      # not now
      # $list.scrollTop scroll_to

  show_tagged: (tags=[]) ->
    for song in @container.find(".beat")
      songtags = $(song).data("tags")
      if songtags
        show = tags.length == 0
        for tag in tags
          if songtags.indexOf(tag) > -1
            show = true
            break

        $(song).toggleClass("hide", !show)


document.Jukebox = Jukebox
