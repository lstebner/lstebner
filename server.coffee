http = require("http")
dispatcher = require("httpdispatcher")
pug = require("pug")
less = require("less")
coffee = require("coffee-script")
_ = require("underscore")
fs = require("fs")
port = 3020

projects_data = [
    {
        "title": "Omlet API",
        "order": 2,
        "slug": "omletapi",
        "year": "2014",
        "description": "Omlet's API Documentation was starting to look a bit outdated so I helped out to give it a facelift. The new docs were designed by Jon Victorino and I built them a package which included the working site and a way to easily update content so they could continue to use it going forward without needing me to make updates for them. The result was these beautiful, easy to use docs!",
        "display_url": "http://omlet.me/docs",
        "full_url": "http://www-new.omlet.me/docs/",
        "technologies": ["Coffeescript", "Jade templates", "LESS", "Shell script"],
        "images": [
            "/images/projects/omletapi.jpg"
        ]
    }
    ,
    {
        "title": "IMGVERSE",
        "order": 3,
        "slug": "imgverse",
        "year": "2011-2015",
        "description": "IMGVERSE is a useful and beautiful site for sharing and discovering images. It allows for both public and private uploads if you have something you want to share, or you can just use the timeline to browse.",
        "display_url": "http://imgverse.com",
        "full_url": "http://www.imgverse.com",
        "technologies": ["nodejs", "mongodb", "jQuery", "Coffeescript", "LESS/CSS"],
        "images": [
            "/images/projects/imgverse.jpg",
            "/images/projects/imgverse-detail.jpg",
            "/images/projects/imgverse-upload.jpg",
            "/images/projects/imgverse-upload-filled-out.jpg"
        ]
    }
    ,
    {
        "title": "Luke and Tiffany Wedding Site",
        "order": 7,
        "slug": "lukeandtiffany",
        "year": "2013-2015"
        "description": "This website was made to give our wedding guests a place to get all the information about the event. It included some information about us, hotels, directions for travelers and also listed our registries. I both designed and developed this site.",
        "display_url": "http://lukeandtiffany.com",
        "full_url": "http://www.lukeandtiffany.com",
        "technologies": ["nodejs", "underscore", "jade", "jQuery", "design!"],
        "images": [
            "/images/projects/lukeandtiffany.jpg",
            "/images/projects/lukeandtiffany-aboutus.jpg",
            "/images/projects/lukeandtiffany-hotels.jpg"
        ]
    }
    ,
    {
        "title": "My Brick Builds",
        "order": 5,
        "slug": "mbb",
        "year": "2011-2015",
        "description": "My Brick Builds is a social site created to let people share Lego builds. It was created by a friend and me out of interest of seeing what types of Lego things people are building. I was responsible for all backend development and much of the front end.",
        "display_url": "http://mybrickbuilds.com",
        "full_url": "http://mybrickbuilds.com",
        "technologies": ["nodejs", "mongodb", "backbone", "underscore", "jade", "jQuery"],
        "images": [
            "/images/projects/mbb.jpg",
            "/images/projects/mbb2.jpg",
            "/images/projects/mbb3.jpg"
        ]
    }
    ,
    {
        "title": "10 Dollar Gaming",
        "order": 6,
        "slug": "10g",
        "year": "2010-2015",
        "description": "10 Dollar Gaming is a blog site that was created because I love playing all these games that many other people seem to overlook. I wanted to be able to tell people about them so this started off as a Wordpress blog, but is now on a custom platform I made that reads from flat files instead of a database. On top of development I also play these games and write all content for the site.",
        "display_url": "http://10dollargaming.com",
        "full_url": "http://10dollargaming.com",
        "technologies": ["nodejs", "underscore", "jade", "jQuery"],
        "images": [
            "/images/projects/10g.jpg",
            "/images/projects/10g-review1.jpg",
            "/images/projects/10g-search-results.jpg",
            "/images/projects/10g-review2.jpg",
            "/images/projects/10g-article-footer.jpg"
        ]
    }
    ,
    {
        "title": "Scribd",
        "order": 1,
        "slug": "scribd",
        "year": "2014-current"
        "description": "Scribd is an online library of over 400,000 books available across all devices. I work there full time as an engineer working on various parts of their websites. My responsibilites include building new features such as the audiobook player for web and also fixing bugs to maintain the overall site. I work mainly in Coffeescript land along with Ruby on Rails, SCSS and ERB.",
        "display_url": "http://scribd.com",
        "full_url": "http://scribd.com",
        "technologies": ["Coffeescript", "Ruby on Rails", "SASS", "React", "Mobile Web", "RSpec", "Capybara"],
        "images": [
            "/images/projects/scribd-home.jpg",
            "/images/projects/scribd-home2.jpg",
            "/images/projects/scribd-login.jpg",
            "/images/projects/scribd-loggedin-home.jpg",
            "/images/projects/scribd-read.jpg",
            "/images/projects/scribd-read-options.jpg",
            "/images/projects/scribd-highlight.jpg",
            "/images/projects/scribd-leave-note.jpg",
            "/images/projects/scribd-audiobook.jpg",
            "/images/projects/scribd-audiobook-toc.jpg"
        ]
    }
    ,
    {
        "title": "BrightGauge.com",
        "order": 2,
        "slug": "brightgauge",
        "year": "2011-2013"
        "description": "I worked at BrightGauge as part of their first in house development team. They had outsourced the first version of their application and needed a full time team to support it. I was hired on as the sole frontend developer and was in charge of building dashboards, gauges, charts, reports and even an in browser tableau.",
        "display_url": "http://brightgauge.com",
        "full_url": "http://brightgauge.com",
        "technologies": ["HTML", "LESS", "JavaScript", "jQuery", "Highcharts", "PHP", "Code Igniter"],
        "images": [
            "/images/projects/brightgauge.jpg",
        ]
    }
    ,
    {
        "title": "MerchantCircle.com",
        "order": 2,
        "slug": "merchantcircle",
        "year": "2010-2011"
        "description": "I worked at MerchantCircle full time for a short period before they were acquired by Reply.com. I worked on their dev team as a full stack developer to implement new website features such as landing pages, routine updates/bugfixes and formstarts.",
        "display_url": "http://merchantcircle.com",
        "full_url": "http://merchantcircle.com",
        "technologies": ["Python", "HTML", "CSS", "JavaScript"],
        "images": [
            "/images/projects/merchantcircle.jpg",
        ]
    }
    ,
    {
        "title": "Insure.com",
        "order": 9,
        "slug": "insure",
        "year": "2009-2010"
        "description": "I worked on Insure.com during 2009-2010 when it was purchased by Quinstreet. I was the main dev in charge for turning it from a set of static files into a CMS powered dynamic site. This included building all of the backend and frontend along with several of the form starts and insurance calculator features.",
        "display_url": "http://insure.com",
        "full_url": "http://insure.com",
        "technologies": ["PHP", "MySQL", "HTML/CSS", "CodeIgniter"],
        "images": [
            "/images/projects/insure.jpg",
            "/images/projects/insure2.jpg",
            "/images/projects/insure3.jpg",
            "/images/projects/insure4.jpg"
        ]
    }
    ,
    {
        "title": "Beans and Hops",
        "order": 8,
        "slug": "beansandhops",
        "year": "2011-2016"
        "description": "Beans and Hops was a personal blog that I wrote to on and off. It was also a custom blogging platform I wrote which is unique because it runs off of flat markdown files intead of using a database. It's very lightweight and simple by design.",
        "display_url": "http://beansandhops.com",
        "full_url": "http://beansandhops.com",
        "technologies": ["nodejs", "jade", "LESS", "jQuery"],
        "images": [
            "/images/projects/beansandhops.jpg",
            "/images/projects/beansandhops-post.jpg"
        ]
    }
]

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
  sidebar_enabled: false
  topbar_enabled: true

class AssetServer
  less_opts: { compress: false, paths: ["./assets/less"] }
  coffee_opts: {}
  constructor: (@root_dir="#{__dirname}", @res) ->

  serve_stylesheet: (path) ->
    console.log "AssetServer::stylesheet #{path}"
    path = path.replace /css/g, "less"
    @res.writeHead "200", "Content-Type: text/css"
    contents = fs.readFileSync "#{@root_dir}#{path}", "UTF-8"
    less.render contents, @less_opts, (e, output) =>
      @res.end output.css

  serve_coffeescript: (path) ->
    console.log "AssetServer::coffeescript #{path}"
    path = path.replace /\.js/, ".coffee"
    @res.writeHead "200", "Content-Type: text/javascript"
    contents = fs.readFileSync "#{@root_dir}#{path}", "UTF-8"
    
    @res.end coffee.compile @process_replacements contents

  serve_javascript: (path) ->
    console.log "AssetServer::javascript #{path}"
    @res.writeHead "200", "Content-Type: text/javascript"
    contents = fs.readFileSync "#{@root_dir}#{path}", "UTF-8"
    @res.end contents

  serve_image: (path) ->
    console.log "AssetServer::image #{path}"
    @res.writeHead "200", "Content-Type: text/#{path.substr(path.lastIndexOf('.'))}"
    try
        contents = fs.readFileSync "#{@root_dir}#{path}"
    catch e
        # ...
        console.log "AssetServer::image #{path} !! file not found"
    
    @res.end contents || false

  process_replacements: (contents) ->
    matches = contents.match /#(\s+|)\{\{(prepend|append|insert):([a-zA-Z0-9\-_\/]+)\}\}/g
    replacements = {}

    # nothing to do here
    return contents unless matches && matches.length

    # process all the matches
    for match in matches
      unless replacements.hasOwnProperty(match)
        action = match.match /(prepend|append|insert):/
        file = match.match /:([a-zA-Z0-9\-_\/]+)/
        filename = "#{__dirname}/assets/coffee/#{file[1]}.coffee"
        file_contents = @process_replacements fs.readFileSync filename, "UTF-8"
        replacements[match] = action: action[1], file: file[1], contents: file_contents

    for key, val of replacements
      # if append or prepend then remove the comment line
      if val.action.indexOf("pend") > -1
        contents = contents.replace new RegExp(key, "g"), "" 

      if val.action == "append"
        contents = contents + val.contents
      else if val.action == "prepend"
        contents = val.contents + contents
      # insert in place
      else
        contents = contents.replace new RegExp(key, "g"), val.contents

    contents

class View
  constructor: (name, @res, @data={}) ->
    @filename = "#{__dirname}/views/#{name}.pug"

  write_head: (status) ->
    @res.writeHead "#{status}", "Content-Type: text/plain"

  render: ->
    @data.config = config
    @data.projects = projects_data.sort (obj, obj2) -> obj.order > obj2.order
    @data.beats = beats_data

    @write_head 200
    try
      html = pug.renderFile @filename, @data
    catch e
      console.log JSON.stringify("pug render error:", e)
    @res.end html


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
  view = new View "index", res, page: "home"
  view.render()

dispatcher.onGet "/beats", (req, res) ->
  view = new View "beats", res, page: "beats"
  view.render()

dispatcher.onGet "/work", (req, res) ->
  view = new View "projects", res, page: "work"
  view.render()

dispatcher.onGet "/posts", (req, res) ->
  view = new View "posts", res, page: "posts"
  view.render()

server.listen port, ->
  console.log "Server started on port #{port}"
