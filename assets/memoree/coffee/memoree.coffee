window.dictionary_data = {
  colors: [
    ["red", "あか"]
    ["yellow", "きいろ"]
    ["black", "くろ"]
    ["white", "しろ"]
    ["blue", "あお"]
    ["purple", "むらさき"]
    ["green", "みどり"]
  ]
  foods: [
    ["apple", "りんご"]
    ["strawberry", "いちご"]
    ["peach", "もも"]
    ["banana", "バナナ"]
    ["pear", "なし"]
    ["watermelon", "スイカ"]
    ["lemon", "レモン"]
    ["persimmon", "カキ"]
    ["pineapple", "パイナップル"]
    ["onigiri", "おにぎり"]
    ["bento", "おべんと"]
    ["sushi", "ずし"]
    ["ramen", "ラーメン"]
    ["soba", "そば"]
    ["udon", "うどん"]
    ["cold soba", "ざるそば"]
    ["tofu udon", "きつねうどん"]
    ["edamame", "えだまめ"]
    ["oyaki", "おやき"]
    ["okonomiyaki", "おこのみやき"]
  ]
}

Memoree =
  init: ->
    memoree_data = JSON.parse $("#memoree_data").val()
    window.dictionary_data = _.extend window.dictionary_data, memoree_data

    @toolbar = new Memoree.Toolbar "#toolbar"
    @memoree = new Memoree.Main "#memoree"

    $(document.body).on "memoree:request", (e, evnt) =>
      @request evnt

  # expose allowed memoree events
  request: (evnt) ->
    unless _.indexOf(["reset"], evnt) > -1
      return console.log("requested action is not available") 

    switch evnt
      when "reset" then @memoree.reset()

class Memoree.Main
  constructor: (container, @opts={}) ->
    @opts = _.extend(
      shuffle: true
      dictionary: "characters.hiragana"
      mode: "define", # modes: define, match
      theme: "alt"
      num_tiles: 42
      @opts
    )

    @container = $ container
    @container.addClass @opts.theme
    @setup()
    @render()

  setup: ->
    @uncovered_cards = 0
    @matched_cards = 0
    @stats =
      clicks: 0
      matched: 0
      remaining: 0
    @card_zone = @container.find ".card_zone"
    @load_deck()
    @setup_events()

  setup_events: ->
    @container.on "click", (e) =>
      prevent = true
      propagate = true
      $target = $(e.target)
      $currentTarget = $(e.currentTarget)

      if $target.is ".card"
        @click_card $target, e

      e.preventDefault() if prevent
      e.stopPropagation() unless propagate

    @container.on "memoree:change_dictionary", (e, data) =>
      @set_dictionary data
      @reset()

  set_dictionary: (name) ->
    # same dictionary that's already loaded
    return unless name != @opts.dictionary
    valid_dicts = ["characters.hiragana", "characters.katakana", "foods", "colors", "time", "japanese_numbers", "addition_basic", "subtraction_basic", "multiplication"]
    # unavailable dictionary
    return unless _.indexOf(valid_dicts, name) > -1
    @opts.dictionary = name

  load_dictionary: (keys) ->
    if !_.isArray(keys) && _.isString(keys)
      if _.isString(keys)
        keys = [keys]
      else
        return console.log "keys must be a string or array, not a '#{typeof keys}'"

    dict = window.dictionary_data
    dict_data = []

    for key in keys
      # new_data = switch key
        # when "characters.hiragana"
        #   for c in dict["characters.hiragana"]
        #     if typeof c == "string"
        #       [c, c]
        #     else
        #       [c[0], c[1]]

        # when "characters.katakana"
        #   for c in dict["characters.katakana"]
        #     if typeof c == "string"
        #       [c, c]
        #     else
        #       [c[0], c[1]]

        # else
      if dict[key]?
        new_data = dict[key]
        dict_data = _.union dict_data, new_data

    dict_data

  load_deck: ->
    @words = @load_dictionary @opts.dictionary

    if @words.length > @opts.num_tiles / 2
      @words = _.first _.shuffle(@words), @opts.num_tiles / 2 

    @stats.remaining = @words.length
    @stats_updated()

  stats_updated: ->
    @container.trigger "memoree:stats:update", @stats

  render: ->
    @cards = []
    for w, idx in @words
      word = w[0]
      # in match mode, the same word is shown on two cards to be matched
      match = if @opts.mode == "match"
        word
      # otherwise, we use a second index for the match card
      else
        w[1]

      card = "<div class='card' data-id='#{idx}' data-match_val='#{match}'><span>#{word}</span></div>"
      @cards.push card

      match = "<div class='card' data-id='#{idx}m' data-match_val='#{match}'><span>#{match}</span></div>"
      @cards.push match

    cards = if @opts.shuffle then _.shuffle(@cards) else @cards
    @card_zone.append(card) for card in cards


  click_card: ($el, e) ->
    # currently waiting to check uncovered cards
    return if @check_cards_to || !_.isEmpty(_.intersection($el[0].classList, ["match", "miss", "uncover"])) 

    if @uncovered_cards < 2
      @uncover $el

    if @uncovered_cards == 2
      @check_cards_to = setTimeout =>
        @check_cards_to = null
        @check_uncovered_cards()

        if @matched_cards == @words.length
          @finished()
      , 500

  uncover: ($card) ->
    $card.addClass "uncover"
    @stats.clicks++
    @stats_updated()
    @uncovered_cards++

  check_uncovered_cards: ->
    $uncovered = @container.find(".card.uncover")
    return console.log('not enough uncovered cards') unless $uncovered.length == 2
    ids = []
    match_vals = []
    for c in $uncovered
      ids.push $(c).data("id") 
      match_vals.push $(c).data("match_val")

    matched = @is_match ids[0], ids[1], match_vals[0], match_vals[1]
    new_classes = if matched
      @matched_cards++
      @stats.matched++
      @stats.remaining--
      @stats_updated()
      "match"
    else
      setTimeout =>
        @container.find(".miss").removeClass("miss")
      , 1200
      "miss"

    $uncovered.addClass(new_classes).removeClass("uncover")

    @uncovered_cards = 0
    matched

  is_match: (id1, id2, match_val1, match_val2) ->
    ismatch = id2 == "#{id1}m" || id1 == "#{id2}m"
    return true if ismatch
    return false if @opts.dont_allow_match_val
    match_val1 == match_val2

  finished: ->
    console.log "all cards matched!"
    @container.addClass("complete")

  reset: ->
    @uncovered_cards = 0
    @matched_cards = 0
    @card_zone.html ""
    @container.removeClass("complete")
    @stats =
      clicks: 0
      matched: 0
      remaining: @words.length
    @stats_updated()
    @load_deck()
    @render()


class Memoree.Toolbar
  constructor: (container, @opts={}) ->
    @container = $ container
    @setup()

  setup: ->
    @setup_events()

  setup_events: ->
    @container.on "click", (e) =>
      prevent = true
      propagate = true
      $target = $(e.target)
      $currentTarget = $(e.currentTarget)

      if $target.is ".reset_btn"
        if confirm "Are you sure?"
          @container.trigger "memoree:request", "reset"

      e.preventDefault() if prevent
      e.stopPropagation() unless propagate

    @container.on "change", "select[name=dictionary]", (e) =>
      @container.trigger "memoree:change_dictionary", $(e.currentTarget).val()

    $(document.body).on "memoree:stats:update", (e, @stats) =>
      @render_stats()

  render_stats: ->
    $stats = @container.find(".stats").html("")
    content = "clicks: #{@stats.clicks}  matched: #{@stats.matched}  remaining: #{@stats.remaining}"
    $stats.text content

class Menu
  constructor: (container, @opts={}) ->
    @content = $(container).html()
    @construct()
    @setup_events()

  construct: ->
    @setup_overlay()
    @container = $("<div class='menu'></div>")
    $(document.body).append @container
    @container.html @content

  setup_overlay: ->
    return @overlay if @overlay
    @overlay = $("<div class='overlay'></div>")
    $(document.body).append(@overlay)

  setup_events: ->
    @container.on "click", (e) =>
      e.stopPropagation()
      false

    @overlay.on "click", (e) =>
      e.stopPropagation()
      @close()

  close: ->
    @overlay.hide()
    @container.hide()

  open: ->
    @overlay.show()
    @container.show()

class DictionaryMenu extends Menu
  constructor: (@opts={}) ->
    super "#dictionary_menu_template", @opts

  setup_events: ->
    super

    @container.on "click", "li", (e) =>
      e.preventDefault()
      $(e.currentTarget).toggleClass("selected")

    @container.on "click", ".submit_btn", (e) =>
      e.preventDefault()
      @apply_dictionary_selections()

  apply_dictionary_selections: ->
    @close()


document.DictionaryMenu = DictionaryMenu
document.Memoree = Memoree

$ ->
  document.Memoree.init()



