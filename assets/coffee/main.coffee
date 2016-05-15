# {{insert:nav}}
# {{insert:beats}}

class LazyBackgrounds
  @load: (container) ->
    $(container).find("[data-lazy_background]").each ->
      $(this).css {
        backgroundImage: "url(#{$(this).data('lazy_background')})"
        backgroundSize: "cover"
        backgroundRepeat: "no-repeat"
      }

$ ->
  document.nav = new Nav("#sidebar")
  document.beats = new BeatsPage("#beats_page")
  LazyBackgrounds.load document.body

