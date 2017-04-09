Cards = {Deck:null, Card:null, Faces:null, FaceValues:null, FaceNames:null, Suits:null}

Cards.Suits = { hearts: 1, spades: 2, diamonds: 3, clubs: 4 }
Cards.Faces = ["2", "3", "4", "5", "6", "7", "8", "9", "10", "J", "Q", "K", "A"]
Cards.FaceValues = { 2: 2, 3: 3, 4: 4, 5: 5, 6: 6, 7: 7, 8: 8, 9: 9, 10: 10, J: 10, Q: 10, K: 10, A: 11}
Cards.FaceNames = { 2: "two", 3: "three", 4: "four", 5: "five", 6: "six", 7: "seven", 8: "eight", 9: "nine", 10: "ten", J: "jack", Q: "queen", K: "king", A: "ace"}

class IDGen
  @id: ->
    @_next_id ||= 0
    @_next_id++

class IDParser
  @parse: (id) -> 
    return false unless typeof id == "string" && id.indexOf(".") > -1
    spl = id.split(".")
    [spl[0], spl[1]]

  @gen: (word, num) -> "#{word}.#{num}"

class Cards.Card
  @random: ->
    new Card
      suit: _.sample _.keys Cards.Suits
      face: _.sample Cards.Faces

  # how far apart the face values of two cards are from each other
  @card_distance: (card1, card2, abs=false) ->
    dist = Cards.Faces.indexOf(card1.face) - Cards.Faces.indexOf(card2.face)
    if abs
      Math.abs dist
    else
      dist

  constructor: (@opts={}) ->
    {@suit, @face} = @opts
    @id = IDGen.id()

  suit_color: ->
    return "red" if @suit == "hearts" || @suit == "diamonds"
    "black"

class Cards.Deck
  constructor: (@opts={shuffle: true}) ->
    @setup()
    @shuffle() if @opts.shuffle

  setup: ->
    @_deal_idx = 0
    @_cards_delt = 0
    @setup_52_card_deck()

  setup_52_card_deck: ->
    @cards = []
    for suit, id of Cards.Suits
      for face in Cards.Faces
        @add_card { suit: suit, face: face }

  # card props as hash or instance of Cards.Card
  add_card: (card) ->
    if card instanceof Cards.Card
      @cards.push card
    else
      @cards.push new Cards.Card card

  shuffle: ->
    console.log "shuffle"
    for i in [0..3]
      for c, i in @cards
        idx = Math.floor Math.random() * @cards.length
        c2 = @cards[idx]
        c1 = @cards[i]
        @cards[i] = c2
        @cards[idx] = c1

  sort: ->
    face_to_order = {}
    cards_by_suit = {}
    for f, id in Cards.Faces
      face_to_order[f] = id
    for c in @cards
      cards_by_suit[c.suit] ||= []
      cards_by_suit[c.suit].push c

    @cards = []

    for suit, cards of cards_by_suit
      cards.sort (a, b) ->
        if face_to_order[a.face] > face_to_order[b.face]
          1
        else
          -1

      for c in cards
        @cards.push c

    @cards

  set_discard: (cards) ->
    @discarded_cards = (card for card in cards)

  deal_cards: (amount=1, auto_reshuffle=true) ->
    if @all_cards_dealt
      if auto_reshuffle
        @cards = @discarded_cards
        # @shuffle()
        @all_cards_dealt = false
        @_deal_idx = 0
      else
        console.log "all cards dealt"
        return []

    # cards = @cards.slice(@_deal_idx, @_deal_idx + amount)
    cards = @cards.splice(0, amount)

    @_cards_delt += amount
    # @_deal_idx += amount
    # if @_deal_idx >= @cards.length
      # @all_cards_dealt = true
    @all_cards_dealt = !@cards.length

    cards

  get_card: (id) ->
    for c in @cards
      return c if c.id == id

    false

Solitaire = {}
class Solitaire.Klondike
  constructor: (container, @opts={}) ->
    # mustache style templates
    _.templateSettings = 
      interpolate: /\{\{(.+?)\}\}/g
      
    @container = $ container
    @setup()
    @render()

  setup_events: ->
    @container.on "click", ".draw_pile", (e) =>
      $el = $ e.currentTarget
      e.preventDefault()

      @draw_card()

    # events
    # - move card from discard_pile in to play
    # - move card from column to another column
    #     - move a whole set of cards from a column to another column
    # - move card from column to foundation

    @container.on "click", ".discard_pile .card", (e) =>
      e.preventDefault()
      $el = $ e.currentTarget

      return unless $el.is(".top")
      e.stopPropagation()
      @pickup_card "discard_pile"

    @container.on "mousemove", (e) =>
      return unless @state == @states.place_card
      @$selected_card.css top: e.clientY + 10, left: e.clientX - @container.offset().left + 10

    # checks if cards can be placed on hover of columns
    # @container.on "mouseenter", ".column .card", (e) =>
    #   return unless @state == @states.place_card
    #   $el = $ e.currentTarget
    #   return if $el.is ".hidden"
    #   can_place = @can_move_card @selected_card, $el.closest(".column").data("id")

    @container.on "click", ".column .card", (e) =>
      $el = $ e.currentTarget
      e.stopPropagation()
      col_id = $el.closest(".column").data("id")

      if @state == @states.select_card
        return @pickup_card col_id

      else if @state == @states.place_card
        unless @place_card col_id
          # @place_card "discard_pile"
          0

    @container.on "click", ".foundation", (e) =>
      return unless @state == @states.place_card
      e.stopPropagation()
      $el = $ e.currentTarget
      f_id = $el.closest(".foundation").data("id")
      @place_card f_id

    @container.on "click", (e) =>
      if @state == @states.place_card && @selected_card
        @place_card @$selected_card.data("from"), true
        @change_state @states.select_card
        @selected_card = null
        @$selected_card.remove()
        return


  states:
    setup: 1
    render: 2
    select_card: 3
    place_card: 4

  change_state: (new_state) ->
    @prev_state = @state
    @state = new_state

  setup: ->
    @change_state @states.setup
    @setup_deck()
    @setup_board()

    @$draw_pile = @container.find(".draw_pile")
    @$discard_pile = @container.find(".discard_pile")

    @setup_events()

  setup_deck: ->
    @deck = new Cards.Deck()

  setup_board: ->
    #todo: consider sub-class for each of these items
    @foundations = []
    @columns = []
    @draw_pile = []
    @discard_pile = []

    @setup_foundations()
    @setup_columns()

  setup_foundations: ->
    for suit, id of Cards.Suits
      @foundations.push
        id: id + ""
        suit: suit
        cards: []

  setup_columns: ->
    for i in [0...7]
      col_id = (i + 1) + ""
      cards = @deck.deal_cards(i + 1)
      for c, k in cards
        c.col_id = col_id
        c.hidden = i > 0 && k < cards.length - 1

      @columns.push
        id: col_id
        cards: cards

  generate_card_el: (card) ->
    tmpl = _.template $("#card_template").html(), card
    $ tmpl(card)

  $column: (id) -> @container.find ".column[data-id='column.#{id}']"
  $foundation: (id) -> @container.find ".foundation[data-id='foundation.#{id}']"
  $empty_card: -> "<div class='card empty'></div>"

  render: (id=null) ->
    @change_state @states.render

    render_columns = =>
      for col in @columns
        $col = @$column(col.id)
        $col.empty()

        if col.cards.length
          for card, i in col.cards
            $card = @generate_card_el card
            $card.toggleClass "hidden", card.hidden || false

            $card.css "top", "#{i * 20}px"

            $col.append $card
        else
          $col.append @$empty_card()

    render_foundations = =>
      $tmpl = _.template $("#foundation_template").html()
      for foundation in @foundations
        $foundation = @$foundation(foundation.id)
        $foundation.html $tmpl(foundation)

        for card in foundation.cards
          $card = @generate_card_el card
          $foundation.append $card

    should_render_columns = true
    should_render_foundations = true

    unless id == null
      should_render_columns = id.match(/column/)
      should_render_foundations = id.match(/foundation/)

    render_columns() if should_render_columns
    render_foundations() if should_render_foundations

    @change_state @states.select_card

  draw_card: ->
    next_card = @deck.deal_cards(1, @$draw_pile.hasClass("reset"))
    console.log "draw", next_card
    if !next_card.length
      @deck.set_discard @discard_pile
      @discard_pile = []
      @$draw_pile.addClass "reset"
      return

    @$draw_pile.removeClass "reset"

    @add_card_to_discard_pile next_card[0]

  add_card_to_discard_pile: (card) ->
    $card = @generate_card_el card
    @$discard_pile.find(".top").removeClass("top")
    $card.addClass "top"
    @$discard_pile.append $card
    @discard_pile.push card

  update_from_column: (card) ->
    if card.col_id?
      from_column = @get_column card.col_id
      if from_column.cards.length
        from_column.cards[from_column.cards.length - 1].hidden = false

  add_card_to_column: (card, col_id, skip_check=false) ->
    return false unless @can_move_card(card, col_id) || skip_check
    @update_from_column(card)
    card.col_id = col_id
    to_column = @get_column(col_id)
    to_column.cards.push card
    @render col_id

  add_card_to_foundation: (card, f_id, skip_check=false) ->
    console.log 'add to foundation', card, f_id
    return false unless @can_move_card(card, f_id) || skip_check
    @update_from_column(card)
    card.col_id = null
    foundation = @get_foundation(f_id)
    foundation.cards.push card
    @render()

  get: (uid) ->
    [get_what, get_id] = IDParser.parse(uid)
    switch get_what
      when "column" then @get_column get_id
      when "foundation" then @get_foundation get_id
      else
        false

  get_column: (id) ->
    if typeof id == "string" && id.indexOf(".") > -1
      [c, id] = IDParser.parse(id)

    column = _.where @columns, id: id
    return false unless column.length
    column[0]

  get_column_el: (id) ->
    unless typeof id == "string"
      id = "column.#{id}"

    @container.find(".column[data-id='#{id}']")

  get_foundation: (id) ->
    if typeof id == "string" && id.indexOf(".") > -1
      [f, id] = IDParser.parse(id)

    foundation = _.where @foundations, id: id
    return false unless foundation.length
    foundation[0]

  get_last_card_in_column: (col_id) ->
    column = @get_column col_id
    return unless column
    return false unless column.cards.length
    column.cards[column.cards.length - 1]

  can_move_card: (card, to_id) ->
    [to_what, to_id] = IDParser.parse(to_id)

    if to_what == "column"
      col = @get_column(to_id)
      return false unless col
      # check against the last card in the column
      if col.cards.length
        last_card = col.cards[col.cards.length - 1]
        # can't stack the same colored suits 
        return false if card.suit_color() == last_card.suit_color()
        console.log 'dist', Cards.Card.card_distance(card, last_card)
        return Cards.Card.card_distance(card, last_card) == -1
      # only kings can move in to empty columns
      else
        return card.face == "K"
    else if to_what ==  "foundation"
      foundation = @get_foundation to_id
      return false unless foundation

      # must match suit
      return false unless card.suit == foundation.suit

      # check against last card in foundation
      if foundation.cards.length
        last_card = foundation.cards[foundation.cards.length - 1] 
        return Cards.Card.card_distance(card, last_card) == 1
      # only ace's can get put on empty foundations
      else
        return card.face == "A"

  pickup_card: (from) ->
    [from_what, from_id] = IDParser.parse(from)
    from_what = from unless from_what

    switch from_what
      when "discard_pile"
        return false unless @state == @states.select_card
        return false unless @discard_pile.length
        @selected_card = @discard_pile.pop()
        $top = @$discard_pile.find(".card.top")
        @$discard_pile.find(".card:last").addClass("top")
        @$selected_card = $top.clone().addClass("moving")
        @$selected_card.css top: @$discard_pile.offset().top, left: @$discard_pile.position().left
        @$selected_card.appendTo @container
        $top.remove()

      when "column"
        column = @get_column from
        return false unless column.cards.length
        @selected_card = column.cards.pop()
        $column = @get_column_el(from)
        $last_card = $column.find(".card:last")
        @$selected_card = $last_card.clone().addClass("moving")
        @$selected_card.css top: $last_card.offset().top, left: $last_card.position().left
        @$selected_card.appendTo @container
        $last_card.remove()

    if @selected_card?
      @$selected_card.data("from", from)
      @change_state @states.place_card
      @selected_card

  place_card: (where, skip_check=false, card=@selected_card) ->
    [place_where, place_id] = IDParser.parse(where)
    place_where = where unless place_where

    can_place = @can_move_card card, where
    console.log "place card", where, card, can_place
    return unless can_place || skip_check

    switch place_where
      when "column" then @add_card_to_column card, where, skip_check
      when "foundation" then @add_card_to_foundation card, where, skip_check
      when "discard_pile" then @add_card_to_discard_pile card
      else
        return false

    @$discard_pile.find(".card:last").addClass("top")

    # card was moved successfully
    @selected_card = null
    @$selected_card.remove()
    @change_state @states.select_card


# document.IDGen = IDGen
# document.IDParser = IDParser
document.Cards = Cards
document.Solitaire = Solitaire.Klondike
