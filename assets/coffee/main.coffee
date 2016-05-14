# @codekit-prepend "nav"
# @codekit-prepend "beats"


$ ->
  document.nav = new Nav("#sidebar")
  document.beats = new BeatsPage("#beats_page")
