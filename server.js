// Generated by CoffeeScript 1.10.0
var AssetServer, View, _, coffee, dispatcher, fs, handleRequest, http, less, port, pug, server;

http = require("http");

dispatcher = require("httpdispatcher");

pug = require("pug");

less = require("less");

coffee = require("coffee-script");

_ = require("underscore");

fs = require("fs");

port = 3020;

AssetServer = (function() {
  AssetServer.prototype.less_opts = {
    compress: false,
    paths: ["./assets/less"]
  };

  AssetServer.prototype.coffee_opts = {};

  function AssetServer(root_dir, res1) {
    this.root_dir = root_dir != null ? root_dir : "" + __dirname;
    this.res = res1;
  }

  AssetServer.prototype.serve_stylesheet = function(path) {
    var contents;
    console.log("AssetServer::stylesheet " + path);
    path = path.replace(/css/g, "less");
    this.res.writeHead("200", "Content-Type: text/css");
    contents = fs.readFileSync("" + this.root_dir + path, "UTF-8");
    return less.render(contents, this.less_opts, (function(_this) {
      return function(e, output) {
        return _this.res.end(output.css);
      };
    })(this));
  };

  AssetServer.prototype.serve_coffeescript = function(path) {
    var contents;
    console.log("AssetServer::coffeescript " + path);
    path = path.replace(/\.js/, ".coffee");
    this.res.writeHead("200", "Content-Type: text/javascript");
    contents = fs.readFileSync("" + this.root_dir + path, "UTF-8");
    return this.res.end(coffee.compile(this.process_replacements(contents)));
  };

  AssetServer.prototype.serve_javascript = function(path) {
    var contents;
    console.log("AssetServer::javascript " + path);
    this.res.writeHead("200", "Content-Type: text/javascript");
    contents = fs.readFileSync("" + this.root_dir + path, "UTF-8");
    return this.res.end(contents);
  };

  AssetServer.prototype.serve_image = function(path) {
    console.log("AssetServer::image " + path);
    this.res.writeHead("200", "Content-Type: text/" + (path.substr(path.lastIndexOf('.'))));
    return this.res.end(fs.readFileSync("" + this.root_dir + path));
  };

  AssetServer.prototype.process_replacements = function(contents) {
    var action, file, file_contents, filename, i, key, len, match, matches, replacements, val;
    matches = contents.match(/#(\s+|)\{\{(prepend|append|insert):([a-zA-Z0-9\-_\/]+)\}\}/g);
    replacements = {};
    if (!(matches && matches.length)) {
      return contents;
    }
    for (i = 0, len = matches.length; i < len; i++) {
      match = matches[i];
      if (!replacements.hasOwnProperty(match)) {
        action = match.match(/(prepend|append|insert):/);
        file = match.match(/:([a-zA-Z0-9\-_\/]+)/);
        filename = __dirname + "/assets/coffee/" + file[1] + ".coffee";
        file_contents = this.process_replacements(fs.readFileSync(filename, "UTF-8"));
        replacements[match] = {
          action: action[1],
          file: file[1],
          contents: file_contents
        };
      }
    }
    for (key in replacements) {
      val = replacements[key];
      if (val.action.indexOf("pend") > -1) {
        contents = contents.replace(new RegExp(key, "g"), "");
      }
      if (val.action === "append") {
        contents = contents + val.contents;
      } else if (val.action === "prepend") {
        contents = val.contents + contents;
      } else {
        contents = contents.replace(new RegExp(key, "g"), val.contents);
      }
    }
    return contents;
  };

  return AssetServer;

})();

View = (function() {
  function View(name, res1, data) {
    this.res = res1;
    this.data = data != null ? data : {};
    this.filename = __dirname + "/views/" + name + ".pug";
  }

  View.prototype.write_head = function(status) {
    return this.res.writeHead("" + status, "Content-Type: text/plain");
  };

  View.prototype.render = function() {
    var html;
    this.write_head(200);
    html = pug.renderFile(this.filename, this.data);
    return this.res.end(html);
  };

  return View;

})();

handleRequest = function(req, res) {
  var asset_server, html, url;
  console.log("url hit: " + req.url);
  url = req.url;
  html = null;
  asset_server = new AssetServer(__dirname + "/assets/", res);
  if (url.match(/css\/[a-zA-Z\/]+\.css/)) {
    return asset_server.serve_stylesheet(url, res);
  } else if (url.match(/coffee\/[a-zA-Z\/\.\-_0-9]+\.js/)) {
    return asset_server.serve_coffeescript(url, res);
  } else if (url.match(/lib\/[a-zA-Z\/\.\-_0-9]+\.js/)) {
    return asset_server.serve_javascript(url, res);
  } else if (url.match(/images\/[a-zA-Z\/\.\-_0-9]+\.(jpg|png)/)) {
    return asset_server.serve_image(url, res);
  } else {
    dispatcher.dispatch(req, res);
  }
  if (html == null) {
    html = "404, whoops";
  }
  return res.end(html);
};

dispatcher.setStatic("assets");

server = http.createServer(handleRequest);

dispatcher.onGet("/", function(req, res) {
  var view;
  view = new View("index", res, {
    page: "home"
  });
  return view.render();
});

dispatcher.onGet("/beats", function(req, res) {
  var view;
  view = new View("beats", res, {
    page: "beats"
  });
  return view.render();
});

server.listen(port, function() {
  return console.log("Server started on port " + port);
});
