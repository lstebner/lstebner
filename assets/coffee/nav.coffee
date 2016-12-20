class Nav
  constructor: (container, @opts={}) ->
    @container = $ container
    @setup()

  setup: ->
    @read_hash()
    @setup_events()
    @setup_players()

  setup_events: ->
    @container.on "click", ".nav_link", (e) =>
      $link = $ e.currentTarget
      # continue with normal link
      return true unless $link.attr("href")[0] == "#"
      
      target_page = $link.attr("href").replace("#", "")
      e.preventDefault()

      for page in $(document.body).find(".page")
        $page = $ page
        if $page.data("name") == target_page
          $page.show()
        else
          $page.hide()

  read_hash: ->
    return #not right now
        
    if window.location.hash?.length
      @this_page = window.location.hash.replace("#", "") || "home"
      @container.find("a[href=##{@this_page}]").closest("li").addClass("selected")


  setup_players: ->
    for player in @container.find(".audioplayer")
      $player = $ player
      $player.prepend("<audio></audio><div class='title'>select track to play</div>")

      $player.on "click", ".beat", (e) =>
        @play_track $(e.currentTarget).data("beat"), $(e.currentTarget).find(".label").text()

  play_track: (src, title) ->
    @container.find("audio").prop("src", src)[0]
    @container.find("audio")[0].play() 
    @container.find(".title").text(title)


