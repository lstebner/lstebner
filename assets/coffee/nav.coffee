class Nav
  constructor: (container, @opts={}) ->
    @container = $ container
    @setup()

  setup: ->
    if window.location.hash?.length
      @this_page = window.location.hash.replace("#", "") || "home"
      @container.find("a[href=##{@this_page}]").closest("li").addClass("selected")
