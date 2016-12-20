http = require("http")
dispatcher = require("httpdispatcher")
_ = require("underscore")
AssetServer = require("./class/asset_server.js")
View = require("./class/view.js")
JapaneseNumber = require("./class/japanese_number.js")
QuizBuilder = require("./class/quiz_builder.js")
port = 3020

beats_data = [
    {
        path: "https://s3-us-west-1.amazonaws.com/beatlabio/drop/fatsbeat101416_2.mp3"
        title: "What you say Fats?"
        tags: ["sampled", "chopped", "mpc1000", "vinyl", "jazz", "showtunes"]
        description: "This beat was chopped from the Fats Waller record Ain't Misbehavin', recorded in 1929. The very beginning of the beat has a spoken intro and I instantly felt his personality and that he had to be represented on the beat. The main reason I bought this record to begin with was the assumption of jazzy piano's, so grabbing those was a given. Quite pleased with the result!"
        duration: 0
        soundcloud_url: false
        order: 0
        date: "10/14/2016"
    }
    {
        path: "https://s3-us-west-1.amazonaws.com/beatlabio/drop/malobeat100116b_4.mp3"
        title: "Mallows"
        tags: ["sampled", "chopped", "mpc1000", "vinyl", "latin"]
        description: "I inherited this Malo record when I met my wife many years ago, but just recently actually checked it out. Turns out, it was full of gold. Though I had to write three different songs before making one that was decent, here's that one. The others you will never get to hear..."
        duration: 0
        soundcloud_url: false
        order: 0
        date: "10/01/2016"
    }
    {
        path: "https://s3-us-west-1.amazonaws.com/beatlabio/drop/qroshbeat102016_2.mp3"
        title: "QRosh on lead"
        tags: ["weekly beats", "sampled", "moody", "chill"]
        description: "The heart of this beat was sampled from a fellow weekly beats participant, Q-Rosh. He has a ton of great sounding guitars on his beats and I chose this one to work with http://weeklybeats.com/#/q-rosh/music/active-gift."
        duration: 0
        soundcloud_url: false
        order: 0
        date: "10/20/2016"
    }
]

beats_data.sort (one, two) -> one.order > two.order

config =
  sidebar_enabled: true 
  topbar_enabled: false 


handleRequest = (req, res) ->
  console.log "url hit: #{req.url}"
  url = req.url
  html = null
  asset_server = new AssetServer("#{__dirname}/assets/", res)

  if url.match(/css\/[a-zA-Z\/]+\.css/)
    return asset_server.serve_stylesheet url, res
  else if url.match(/coffee\/[a-zA-Z\/\.\-_0-9]+\.js/)
    return asset_server.serve_coffeescript url, res
  else if url.match(/lib\/[a-zA-Z\/\.\-_0-9]+\.js/)
    return asset_server.serve_javascript url, res
  else if url.match(/images\/[a-zA-Z\/\.\-_0-9]+\.(jpg|png)/)
    return asset_server.serve_image url, res
  else
    dispatcher.dispatch req, res

  unless html?
    # todo: implement 
    # html = pug.renderFile "#{__dirname}/views/404.pug"
    html = "404, whoops"

  res.end html

dispatcher.setStatic "assets"

server = http.createServer handleRequest

dispatcher.onGet "/", (req, res) ->
  config.sidebar_enabled = true 
  view = new View "index", res, page: "home", config: config
  view.render()

dispatcher.onGet "/beats", (req, res) ->
  config.sidebar_enabled = true 
  view = new View "beats", res, page: "beats", config: config
  view.render()

dispatcher.onGet "/posts", (req, res) ->
  config.sidebar_enabled = true 
  view = new View "posts", res, page: "posts", config: config
  view.render()

dispatcher.onGet "/recipes", (req, res) ->
  config.sidebar_enabled = true 
  view = new View "recipes", res, page: "recipes", config: config
  view.render()

dispatcher.onGet "/memoree", (req, res) ->
  config.sidebar_enabled = true 
  view = new View "memoree", res, page: "memoree", config: config
  data = 
    memoree_data: JSON.stringify 
      "characters.katakana": dictionary_data.characters.katakana
      "characters.hiragana": dictionary_data.characters.hiragana
      "genki.1": dictionary_data.genki_1
      "genki.2": dictionary_data.genki_2
      "genki.3": dictionary_data.genki_3
      "time": dictionary_data.time
      "japanese_numbers": dictionary_data.japanese_numbers(0, 100)
  view.render(data)

dispatcher.onGet "/vocab", (req, res) ->
  config.sidebar_enabled = true 
  view = new View "vocab", res, page: "vocab", config: config
  view.render()

dispatcher.onGet "/quiz", (req, res) ->
  config.sidebar_enabled = true 
  view = new View "quiz", res, page: "quiz", config: config

  data = 
    quiz_data: JSON.stringify 
      math: QuizBuilder.build type: "math"
      "characters.katakana": QuizBuilder.build "characters.katakana"
      "characters.hiragana": QuizBuilder.build "characters.hiragana"
      "genki.1": QuizBuilder.build "genki_1"
      "genki.2": QuizBuilder.build "genki_2"
      "genki.3": QuizBuilder.build "genki_3"
      # "time": QuizBuilder.build "time", num_questions: 10
      "japanese_numbers": QuizBuilder.build "japanese_numbers", { min: 0, max: 1000 }

  view.render(data)

dispatcher.onGet "/a/quizdata", (req, res) ->
  quiz_data =
    math: QuizBuilder.build type: "math"
    "characters.katakana": QuizBuilder.build "characters.katakana"
    "characters.hiragana": QuizBuilder.build "characters.hiragana"
    "genki.1": QuizBuilder.build "genki_1"
    "genki.2": QuizBuilder.build "genki_2"
    "genki.3": QuizBuilder.build "genki_3"
    "time": QuizBuilder.build "time", num_questions: 10
    "japanese_numbers": QuizBuilder.build "japanese_numbers", { min: 0, max: 1000 }

  res.writeHead 200, { "Content-Type": "application/json" }
  res.end JSON.stringify quiz_data


dispatcher.onGet "/resume", (req, res) ->
  config.sidebar_enabled = true 
  view = new View "resume", res, page: "resume", config: config
  view.render()

server.listen port, ->
  console.log "Server started on port #{port}"






