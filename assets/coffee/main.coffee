# {{insert:nav}}
# {{insert:timeline}}
# {{insert:quiz}}
# {{insert:typing}}
# {{insert:beatswall}}
# {{insert:roasts2017}}
# {{insert:conversions}}
# {{insert:jukebox}}
# {{insert:popout_player}}
# {{insert:solitaire}}

class LazyBackgrounds
  @load: (container) ->
    $(container).find("[data-lazy_background]").each ->
      $(this).css {
        backgroundImage: "url(#{$(this).data('lazy_background')})"
        backgroundSize: "cover"
        backgroundRepeat: "no-repeat"
      }

render_component(component, props={}, root="root") ->
  ReactDOM.render(React.createElement(component, props), document.getElementById(root))

$ ->
  document.nav = new Nav("#sidebar")
  LazyBackgrounds.load document.body

