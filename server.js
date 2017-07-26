// Generated by CoffeeScript 1.10.0
var AssetServer, Conversion, Dictionary, JapaneseNumber, JsonView, MathGenerator, QuizBuilder, View, _, all_quiz_data, colors, config, dispatcher, e, error, fs, handleRequest, http, port, react, server, sitedata, yaml;

http = require("http");

dispatcher = require("httpdispatcher");

_ = require("underscore");

AssetServer = require("./class/asset_server.js");

View = require("./class/view.js");

JapaneseNumber = require("./class/japanese_number.js");

QuizBuilder = require("./class/quiz_builder.js");

Dictionary = require("./class/dictionary.js");

MathGenerator = require("./class/math_generator.js");

Conversion = require("./class/conversion.js");

yaml = require("js-yaml");

colors = require("colors");

fs = require("fs");

react = require("react");

port = 3020;

JsonView = (function() {
  function JsonView(jsondata, res1, render) {
    this.jsondata = jsondata != null ? jsondata : {};
    this.res = res1;
    if (render == null) {
      render = true;
    }
    if (render) {
      this.render();
    }
  }

  JsonView.prototype.render = function() {
    console.log("render out", this.jsondata);
    this.res.writeHead(200, {
      "Content-Type": "application/json"
    });
    return this.res.end(JSON.stringify(this.jsondata));
  };

  return JsonView;

})();

try {
  sitedata = yaml.safeLoad(fs.readFileSync(__dirname + "/sitedata.yml", "utf8"));
  console.log("sitedata loaded");
} catch (error) {
  e = error;
  console.log("YAML error loading sitedata.yml".red, e);
}

config = sitedata.config;

handleRequest = function(req, res) {
  var asset_server, html, result, url;
  console.log("url hit: " + req.url + " as " + req.method);
  url = req.url;
  html = null;
  asset_server = new AssetServer(__dirname + "/assets/", res);
  if (url.match(/css\/[a-zA-Z\/]+\.css/)) {
    return asset_server.serve_stylesheet(url);
  } else if (url.match(/coffee\/[a-zA-Z\/\.\-_0-9]+\.js/)) {
    return asset_server.serve_coffeescript(url);
  } else if (url.match(/lib\/[a-zA-Z\/\.\-_0-9]+\.js/)) {
    return asset_server.serve_javascript(url);
  } else if (url.match(/images\/[a-zA-Z\/\.\-_0-9]+\.(jpg|png|svg)/)) {
    return asset_server.serve_image(url);
  } else if (url.match(/audio\/[a-zA-Z\/\.\-_0-9]+\.(aiff|mp3|wav)/) && config.audio_assets_enabled) {
    return asset_server.serve_audio(url);
  } else {
    result = dispatcher.dispatch(req, res);
    return console.log('dispatch result', result);
  }
};

dispatcher.setStaticDirname("assets");

server = http.createServer(handleRequest);

dispatcher.onGet("/", function(req, res) {
  var view;
  view = new View("index", res, {
    page: "home",
    config: config
  });
  return view.render();
});

dispatcher.onGet("/beats2017", function(req, res) {
  var view;
  view = new View("beats2017", res, {
    page: "beats2017",
    config: config,
    beats: sitedata["52beatsdata"]
  });
  return view.render();
});

dispatcher.onGet("/roasts2017", function(req, res) {
  var view;
  view = new View("roasts2017", res, {
    page: "roasts2017",
    config: config,
    roasts: sitedata["52roastsdata"]
  });
  return view.render();
});

dispatcher.onGet("/weekly_beats_2016", function(req, res) {
  var view;
  view = new View("weeklybeats2016", res, {
    page: "weeklybeats2016",
    config: config,
    beats: sitedata.weeklybeats2016data.reverse()
  });
  return view.render();
});

dispatcher.onGet("/posts", function(req, res) {
  var view;
  view = new View("posts", res, {
    page: "posts",
    config: config
  });
  return view.render();
});

dispatcher.onGet("/recipes", function(req, res) {
  var view;
  view = new View("recipes", res, {
    page: "recipes",
    config: config
  });
  return view.render();
});

dispatcher.onGet("/photostream", function(req, res) {
  var view;
  view = new View("photostream", res, {
    page: "photostream",
    config: config,
    photos: sitedata.photostreamdata
  });
  return view.render();
});

dispatcher.onGet("/memoree", function(req, res) {
  var data, view;
  view = new View("memoree", res, {
    page: "memoree",
    config: config
  });
  data = {
    memoree_data: JSON.stringify({
      "characters.katakana": Dictionary.l("characters.katakana"),
      "characters.hiragana": Dictionary.l("characters.hiragana"),
      "genki.1": Dictionary.l("genki_1"),
      "genki.2": Dictionary.l("genki_2"),
      "genki.3": Dictionary.l("genki_3"),
      "time": Dictionary.l("time"),
      "addition_basic": Dictionary.l("addition_basic"),
      "subtraction_basic": Dictionary.l("subtraction_basic"),
      "multiplication": Dictionary.l("multiplication"),
      "japanese_numbers": Dictionary.l("japanese_numbers")
    })
  };
  return view.render(data);
});

dispatcher.onGet("/vocab", function(req, res) {
  var view;
  view = new View("vocab", res, {
    page: "vocab",
    config: config
  });
  return view.render();
});

all_quiz_data = function() {
  return {
    math: QuizBuilder.build({
      type: "math"
    }),
    "characters.katakana": QuizBuilder.build("characters.katakana"),
    "characters.hiragana": QuizBuilder.build("characters.hiragana"),
    "genki.1": QuizBuilder.build("genki_1"),
    "genki.2": QuizBuilder.build("genki_2"),
    "genki.3": QuizBuilder.build("genki_3"),
    "genki.4": QuizBuilder.build("genki_4"),
    "genki.5": QuizBuilder.build("genki_5"),
    "katakana_misc": QuizBuilder.build("katakana_misc"),
    "addition_basic": QuizBuilder.build("addition_basic"),
    "subtraction_basic": QuizBuilder.build("subtraction_basic"),
    "multiplication": QuizBuilder.build("multiplication"),
    "japanese_numbers": QuizBuilder.build("japanese_numbers", {
      min: 0,
      max: 1000
    })
  };
};

dispatcher.onGet("/quiz", function(req, res) {
  var data, view;
  view = new View("quiz", res, {
    page: "quiz",
    config: config
  });
  data = {
    quiz_data: JSON.stringify(all_quiz_data())
  };
  return view.render(data);
});

dispatcher.onGet("/a/quizdata", function(req, res) {
  var quiz_data;
  quiz_data = all_quiz_data();
  return new JsonView(quiz_data, res);
});

dispatcher.onGet("/resume", function(req, res) {
  var view;
  view = new View("resume", res, {
    page: "resume",
    config: config
  });
  return view.render();
});

dispatcher.onGet("/bsides", function(req, res) {
  var view;
  view = new View("bsides", res, {
    page: "bsides",
    config: config,
    beats: sitedata.bsides_beats
  });
  return view.render();
});

dispatcher.onGet("/solitaire", function(req, res) {
  var view;
  view = new View("solitaire", res, {
    page: "solitaire",
    config: config
  });
  return view.render();
});

dispatcher.onGet("/alternate_history", function(req, res) {
  var view;
  view = new View("alternate_history", res, {
    page: "alternate_history",
    config: config,
    beats: sitedata.alternatehistory_beats
  });
  return view.render();
});

dispatcher.onGet("/jukebox", function(req, res) {
  var add_playlist, add_song, error1, i, idx, j, jukeboxdata, jukeboxdata_raw, k, key, len, len1, playlist_keys, ref, ref1, shuffle, song, songs, songs_clone, swp, view;
  shuffle = req.params.shuffle;
  jukeboxdata = {
    songs: [],
    playlists: []
  };
  playlist_keys = [];
  try {
    jukeboxdata_raw = yaml.safeLoad(fs.readFileSync(__dirname + "/jukeboxdata.yml", "utf8"));
    add_playlist = function(key) {
      if (!(playlist_keys.indexOf(key) > -1)) {
        playlist_keys.push(key);
        return jukeboxdata.playlists.push({
          key: key,
          name: key.replace(/_/g, ' ')
        });
      }
    };
    add_song = function(key, songdata) {
      var song;
      add_playlist(key);
      song = {
        name: songdata.name || songdata.filepath,
        filename: key + "/" + songdata.filepath,
        tags: [key].concat(songdata.tags || []),
        notes: ""
      };
      return jukeboxdata.songs.push(song);
    };
    ref = jukeboxdata_raw.songs;
    for (key in ref) {
      songs = ref[key];
      for (j = 0, len = songs.length; j < len; j++) {
        song = songs[j];
        add_song(key, song);
      }
    }
    if (shuffle != null) {
      songs_clone = [];
      ref1 = jukeboxdata.songs;
      for (i = k = 0, len1 = ref1.length; k < len1; i = ++k) {
        song = ref1[i];
        idx = Math.floor(Math.random() * jukeboxdata.songs.length);
        swp = jukeboxdata.songs[idx];
        jukeboxdata.songs[idx] = song;
        jukeboxdata.songs[i] = swp;
      }
    }
  } catch (error1) {
    e = error1;
    console.log("error loading jukebox data".red);
  }
  view = new View("jukebox", res, {
    page: "jukebox",
    config: config,
    jukebox: jukeboxdata,
    shuffled: shuffle != null
  });
  return view.render();
});

dispatcher.onGet("/lukebox", function(req, res) {
  var add_playlist, add_song, error1, i, idx, j, jukeboxdata, jukeboxdata_raw, k, key, len, len1, next_id, playlist_keys, ref, ref1, shuffle, song, songs, songs_clone, swp, view, viewdata;
  shuffle = req.params.shuffle;
  jukeboxdata = {
    songs: [],
    playlists: []
  };
  playlist_keys = [];
  try {
    jukeboxdata_raw = yaml.safeLoad(fs.readFileSync(__dirname + "/jukeboxdata.yml", "utf8"));
    next_id = function() {
      this._next_id || (this._next_id = 0);
      return this._next_id++;
    };
    add_playlist = function(key) {
      if (!(playlist_keys.indexOf(key) > -1)) {
        playlist_keys.push(key);
        return jukeboxdata.playlists.push({
          key: key,
          name: key.replace(/_/g, ' ')
        });
      }
    };
    add_song = function(key, songdata) {
      var song;
      add_playlist(key);
      song = {
        id: next_id(),
        name: songdata.name || songdata.filepath,
        filename: key + "/" + songdata.filepath,
        tags: [key].concat(songdata.tags || []),
        notes: ""
      };
      return jukeboxdata.songs.push(song);
    };
    ref = jukeboxdata_raw.songs;
    for (key in ref) {
      songs = ref[key];
      for (j = 0, len = songs.length; j < len; j++) {
        song = songs[j];
        add_song(key, song);
      }
    }
    if (shuffle != null) {
      songs_clone = [];
      ref1 = jukeboxdata.songs;
      for (i = k = 0, len1 = ref1.length; k < len1; i = ++k) {
        song = ref1[i];
        idx = Math.floor(Math.random() * jukeboxdata.songs.length);
        swp = jukeboxdata.songs[idx];
        jukeboxdata.songs[idx] = song;
        jukeboxdata.songs[i] = swp;
      }
    }
  } catch (error1) {
    e = error1;
    console.log("error loading jukebox data".red);
  }
  viewdata = {
    page: "jukebox_popout",
    config: config,
    jukebox: jukeboxdata,
    shuffled: shuffle != null,
    body_classes: ["popout_player"]
  };
  view = new View("popout_player", res, viewdata);
  return view.render();
});

dispatcher.onGet("/typing", function(req, res) {
  var view;
  view = new View("typing", res, {
    page: "typing",
    config: config
  });
  return view.render();
});

dispatcher.onGet("/conversions", function(req, res) {
  var view;
  view = new View("conversions", res, {
    page: "conversions",
    config: config
  });
  return view.render();
});

dispatcher.onGet("/about", function(req, res) {
  var view;
  view = new View("about", res, {
    page: "about",
    config: config
  });
  return view.render();
});

dispatcher.onGet("/vinyl", function(req, res) {
  var error1, isrippedsort, j, len, rippedvinyls, unrippedvinyls, view, viewdata, vinyl, vinyldata;
  view = new View("vinyl", res, {
    page: "vinyl",
    config: config
  });
  viewdata = {
    vinyldata: []
  };
  try {
    vinyldata = yaml.safeLoad(fs.readFileSync(__dirname + "/vinyldata.yml", "utf8"));
    vinyldata = vinyldata.collection;
    rippedvinyls = [];
    unrippedvinyls = [];
    for (j = 0, len = vinyldata.length; j < len; j++) {
      vinyl = vinyldata[j];
      if (vinyl.ripped === 'y') {
        rippedvinyls.push(vinyl);
      } else {
        unrippedvinyls.push(vinyl);
      }
    }
    isrippedsort = function(a, b) {
      if (a.ripped === 'y' && b.ripped !== 'y') {
        return 1;
      } else {
        return -1;
      }
    };
    viewdata.vinyldata = vinyldata.sort(isrippedsort);
  } catch (error1) {
    e = error1;
    console.log("error loading vinyldata.yml".red);
  }
  return view.render(viewdata);
});

dispatcher.onPost("/ok/convert", function(req, res) {
  var conversion, input, ref, type;
  ref = req.params, input = ref.input, type = ref.type;
  conversion = new Conversion({
    input: input,
    type: type
  });
  return new JsonView({
    success: true,
    output: conversion.output
  }, res);
});

dispatcher.onGet("/math", function(req, res) {
  var view, viewdata;
  view = new View("math", res, {
    page: "math",
    config: config
  });
  viewdata = {
    math_questions: [MathGenerator.generate("addition_basic"), MathGenerator.generate("addition_basic"), MathGenerator.generate("addition_intermediate"), MathGenerator.generate("addition_intermediate"), MathGenerator.generate("subtraction_basic"), MathGenerator.generate("subtraction_basic"), MathGenerator.generate("multiplication"), MathGenerator.generate("multiplication"), MathGenerator.generate("addition_long"), MathGenerator.generate("addition_long"), MathGenerator.generate("addition_variable"), MathGenerator.generate("addition_variable"), MathGenerator.generate("multiplication_doubles"), MathGenerator.generate("multiplication_doubles"), MathGenerator.generate("multiplication_variable"), MathGenerator.generate("multiplication_variable")]
  };
  return view.render(viewdata);
});

server.listen(port, function() {
  return console.log("Server started on port " + port);
});
