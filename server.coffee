http = require("http")
dispatcher = require("httpdispatcher")
_ = require("underscore")
AssetServer = require("./class/asset_server.js")
View = require("./class/view.js")
JapaneseNumber = require("./class/japanese_number.js")
QuizBuilder = require("./class/quiz_builder.js")
Dictionary = require("./class/dictionary.js")
MathGenerator = require("./class/math_generator.js")
Conversion = require("./class/conversion.js")
yaml = require("js-yaml")
colors = require("colors")
fs = require("fs")
port = 3020

class JsonView 
  constructor: (@jsondata={}, @res, render=true) ->
    @render() if render

  render: ->
    console.log "render out", @jsondata
    @res.writeHead 200, { "Content-Type": "application/json" }
    @res.end JSON.stringify @jsondata

try
  sitedata = yaml.safeLoad fs.readFileSync "#{__dirname}/sitedata.yml", "utf8"
  console.log "sitedata loaded"#, sitedata
catch e
  console.log "YAML error loading sitedata.yml".red, e

config = sitedata.config

handleRequest = (req, res) ->
  console.log "url hit: #{req.url} as #{req.method}"
  url = req.url
  html = null
  asset_server = new AssetServer("#{__dirname}/assets/", res)

  if url.match(/css\/[a-zA-Z\/]+\.css/)
    return asset_server.serve_stylesheet url
  else if url.match(/coffee\/[a-zA-Z\/\.\-_0-9]+\.js/)
    return asset_server.serve_coffeescript url
  else if url.match(/lib\/[a-zA-Z\/\.\-_0-9]+\.js/)
    return asset_server.serve_javascript url
  else if url.match(/images\/[a-zA-Z\/\.\-_0-9]+\.(jpg|png|svg)/)
    return asset_server.serve_image url
  else if url.match(/audio\/[a-zA-Z\/\.\-_0-9]+\.(aiff|mp3|wav)/) && config.audio_assets_enabled
    return asset_server.serve_audio url
  else
    result = dispatcher.dispatch req, res
    console.log 'dispatch result', result

  # unless html?
    # todo: implement 
    # html = pug.renderFile "#{__dirname}/views/404.pug"
    # html = "404, whoops"

  # res.end html

dispatcher.setStaticDirname "assets"

server = http.createServer handleRequest

dispatcher.onGet "/", (req, res) ->
  view = new View "index", res, page: "home", config: config
  view.render()

dispatcher.onGet "/beats2017", (req, res) ->
  view = new View "beats2017", res, page: "beats2017", config: config, beats: sitedata["52beatsdata"]
  view.render()

dispatcher.onGet "/roasts2017", (req, res) ->
  view = new View "roasts2017", res, page: "roasts2017", config: config, roasts: sitedata["52roastsdata"]
  view.render()

dispatcher.onGet "/weekly_beats_2016", (req, res) ->
  view = new View "weeklybeats2016", res, page: "weeklybeats2016", config: config, beats: sitedata.weeklybeats2016data.reverse()
  view.render()

dispatcher.onGet "/posts", (req, res) ->
  view = new View "posts", res, page: "posts", config: config
  view.render()

dispatcher.onGet "/recipes", (req, res) ->
  view = new View "recipes", res, page: "recipes", config: config
  view.render()

# dispatcher.onGet "/waves", (req, res) ->
#   view = new View "waves", res, page: "waves", config: config
#   view.render()

dispatcher.onGet "/photostream", (req, res) ->
  view = new View "photostream", res, page: "photostream", config: config, photos: sitedata.photostreamdata
  view.render()

dispatcher.onGet "/memoree", (req, res) ->
  view = new View "memoree", res, page: "memoree", config: config
  data = 
    memoree_data: JSON.stringify 
      "characters.katakana": Dictionary.l("characters.katakana")
      "characters.hiragana": Dictionary.l("characters.hiragana")
      "genki.1": Dictionary.l("genki_1")
      "genki.2": Dictionary.l("genki_2")
      "genki.3": Dictionary.l("genki_3")
      "time": Dictionary.l("time")
      "addition_basic": Dictionary.l("addition_basic")
      "subtraction_basic": Dictionary.l("subtraction_basic")
      "multiplication": Dictionary.l("multiplication")
      "japanese_numbers": Dictionary.l("japanese_numbers")
  view.render(data)

dispatcher.onGet "/vocab", (req, res) ->
  view = new View "vocab", res, page: "vocab", config: config
  view.render()

all_quiz_data = ->
  math: QuizBuilder.build type: "math"
  "characters.katakana": QuizBuilder.build "characters.katakana"
  "characters.hiragana": QuizBuilder.build "characters.hiragana"
  "genki.1": QuizBuilder.build "genki_1"
  "genki.2": QuizBuilder.build "genki_2"
  "genki.3": QuizBuilder.build "genki_3"
  "genki.4": QuizBuilder.build "genki_4"
  "genki.5": QuizBuilder.build "genki_5"
  "addition_basic": QuizBuilder.build("addition_basic")
  "subtraction_basic": QuizBuilder.build("subtraction_basic")
  "multiplication": QuizBuilder.build("multiplication")
  "japanese_numbers": QuizBuilder.build "japanese_numbers", { min: 0, max: 1000 }

dispatcher.onGet "/quiz", (req, res) ->
  view = new View "quiz", res, page: "quiz", config: config

  data = 
    quiz_data: JSON.stringify all_quiz_data()

  view.render(data)

dispatcher.onGet "/a/quizdata", (req, res) ->
  quiz_data = all_quiz_data()
  new JsonView quiz_data, res

dispatcher.onGet "/resume", (req, res) ->
  view = new View "resume", res, page: "resume", config: config
  view.render()

dispatcher.onGet "/bsides", (req, res) ->
  view = new View "bsides", res, page: "bsides", config: config, beats: sitedata.bsides_beats
  view.render()

dispatcher.onGet "/solitaire", (req, res) ->
  view = new View "solitaire", res, page: "solitaire", config: config
  view.render()

dispatcher.onGet "/alternate_history", (req, res) ->
  view = new View "alternate_history", res, page: "alternate_history", config: config, beats: sitedata.alternatehistory_beats
  view.render()

dispatcher.onGet "/jukebox", (req, res) ->
  {shuffle} = req.params
  jukeboxdata = {
    songs: []
    playlists: []
  }
  playlist_keys = []

  try
    jukeboxdata_raw = yaml.safeLoad fs.readFileSync "#{__dirname}/jukeboxdata.yml", "utf8"

    add_playlist = (key) ->
      unless playlist_keys.indexOf(key) > -1
        playlist_keys.push key
        jukeboxdata.playlists.push
          key: key
          name: key.replace(/_/g, ' ')

    add_song = (key, songdata) ->
      add_playlist key
      song =
        name: songdata.name || songdata.filepath
        filename: "#{key}/#{songdata.filepath}"
        tags: [key].concat(songdata.tags || [])
        notes: ""

      jukeboxdata.songs.push song

    for key, songs of jukeboxdata_raw.songs
      for song in songs
        add_song(key, song)

    if shuffle?
      songs_clone = []
      for song, i in jukeboxdata.songs
        idx = Math.floor Math.random() * jukeboxdata.songs.length
        swp = jukeboxdata.songs[idx]
        jukeboxdata.songs[idx] = song
        jukeboxdata.songs[i] = swp

  catch e
    console.log "error loading jukebox data".red

  view = new View "jukebox", res, page: "jukebox", config: config, jukebox: jukeboxdata, shuffled: shuffle?
  view.render()

dispatcher.onGet "/lukebox", (req, res) ->
  {shuffle} = req.params
  jukeboxdata = {
    songs: []
    playlists: []
  }
  playlist_keys = []

  try
    jukeboxdata_raw = yaml.safeLoad fs.readFileSync "#{__dirname}/jukeboxdata.yml", "utf8"

    next_id = ->
      @_next_id ||= 0
      @_next_id++

    add_playlist = (key) ->
      unless playlist_keys.indexOf(key) > -1
        playlist_keys.push key
        jukeboxdata.playlists.push
          key: key
          name: key.replace(/_/g, ' ')

    add_song = (key, songdata) ->
      add_playlist key
      song =
        id: next_id()
        name: songdata.name || songdata.filepath
        filename: "#{key}/#{songdata.filepath}"
        tags: [key].concat(songdata.tags || [])
        notes: ""

      jukeboxdata.songs.push song

    for key, songs of jukeboxdata_raw.songs
      for song in songs
        add_song(key, song)

    if shuffle?
      songs_clone = []
      for song, i in jukeboxdata.songs
        idx = Math.floor Math.random() * jukeboxdata.songs.length
        swp = jukeboxdata.songs[idx]
        jukeboxdata.songs[idx] = song
        jukeboxdata.songs[i] = swp

  catch e
    console.log "error loading jukebox data".red

  viewdata =
    page: "jukebox_popout"
    config: config
    jukebox: jukeboxdata
    shuffled: shuffle?
    body_classes: ["popout_player"]

  view = new View "popout_player", res, viewdata
  view.render()

# dispatcher.onGet "/beatmaker", (req, res) ->
#   view = new View "beatmaker", res, page: "beatmaker", config: config
#   view.render()

dispatcher.onGet "/typing", (req, res) ->
  view = new View "typing", res, page: "typing", config: config
  view.render()

dispatcher.onGet "/conversions", (req, res) ->
  view = new View "conversions", res, page: "conversions", config: config
  view.render()

dispatcher.onGet "/about", (req, res) ->
  view = new View "about", res, page: "about", config: config
  view.render()

dispatcher.onGet "/vinyl", (req, res) ->
  view = new View "vinyl", res, page: "vinyl", config: config
  viewdata = vinyldata: []
  try
    vinyldata = yaml.safeLoad fs.readFileSync "#{__dirname}/vinyldata.yml", "utf8"
    vinyldata = vinyldata.collection
    rippedvinyls = []
    unrippedvinyls = []
    for vinyl in vinyldata
      if vinyl.ripped == 'y'
        rippedvinyls.push vinyl
      else
        unrippedvinyls.push vinyl

    isrippedsort = (a, b) ->
      if a.ripped == 'y' && b.ripped != 'y' then 1 else -1

    # viewdata.vinyldata = unrippedvinyls.concat rippedvinyls
    viewdata.vinyldata = vinyldata.sort isrippedsort
  catch e
    console.log "error loading vinyldata.yml".red

  view.render(viewdata)

dispatcher.onPost "/ok/convert", (req, res) ->
  {input, type} = req.params
  conversion = new Conversion input: input, type: type
  new JsonView({ success:true, output: conversion.output }, res)

dispatcher.onGet "/math", (req, res) ->
  view = new View "math", res, page: "math", config: config
  viewdata =
    math_questions: [
      MathGenerator.generate("addition_basic")
      MathGenerator.generate("addition_basic")
      MathGenerator.generate("addition_intermediate")
      MathGenerator.generate("addition_intermediate")
      MathGenerator.generate("subtraction_basic")
      MathGenerator.generate("subtraction_basic")
      MathGenerator.generate("multiplication")
      MathGenerator.generate("multiplication")
      MathGenerator.generate("addition_long")
      MathGenerator.generate("addition_long")
      MathGenerator.generate("addition_variable")
      MathGenerator.generate("addition_variable")
      MathGenerator.generate("multiplication_doubles")
      MathGenerator.generate("multiplication_doubles")
      MathGenerator.generate("multiplication_variable")
      MathGenerator.generate("multiplication_variable")
    ]

  view.render(viewdata)

server.listen port, ->
  console.log "Server started on port #{port}"






