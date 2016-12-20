# {{insert:nav}}
# {{insert:timeline}}
# {{insert:quiz}}

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
  LazyBackgrounds.load document.body

