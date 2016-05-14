class Nav
  constructor: (container, @opts={}) ->
    @container = $ container
    @setup()

  setup: ->
    @this_page = (window.location.hash || "").replace("#", "") || "home"
    @container.find("a[href=##{@this_page}]").closest("li").addClass("selected")
