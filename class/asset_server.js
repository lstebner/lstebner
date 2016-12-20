var AssetServer,coffee,fs,less;fs=require("fs"),less=require("less"),coffee=require("coffee-script"),module.exports=AssetServer=function(){function e(e,t){this.root_dir=null!=e?e:""+__dirname.replace(/class/,"assets"),this.res=t}return e.prototype.less_opts={compress:!1,paths:["./assets/less"]},e.prototype.coffee_opts={},e.prototype.serve_stylesheet=function(e){var t;return console.log("AssetServer::stylesheet "+e),e=e.replace(/css/g,"less"),this.res.writeHead("200","Content-Type: text/css"),t=fs.readFileSync(""+this.root_dir+e,"UTF-8"),less.render(t,this.less_opts,function(e){return function(t,s){return e.res.end(s.css)}}(this))},e.prototype.serve_coffeescript=function(e){var t,s,r,o;console.log("AssetServer::coffeescript "+e),e=e.replace(/\.js/,".coffee"),this.res.writeHead("200","Content-Type: text/javascript");try{t=fs.readFileSync(""+this.root_dir+e,"UTF-8")}catch(r){s=r,e=e.replace(/\.coffee/,".js");try{t=fs.readFileSync(""+this.root_dir+e,"UTF-8")}catch(o){s=o,console.log("tried to find "+e+" (or coffee alternative) and neither existed"),t="0"}}return this.res.end(coffee.compile(this.process_replacements(t)))},e.prototype.serve_javascript=function(e){var t;return console.log("AssetServer::javascript "+e),this.res.writeHead("200","Content-Type: text/javascript"),t=fs.readFileSync(""+this.root_dir+e,"UTF-8"),this.res.end(t)},e.prototype.serve_image=function(e){var t,s,r;console.log("AssetServer::image "+e),this.res.writeHead("200","Content-Type: text/"+e.substr(e.lastIndexOf(".")));try{t=fs.readFileSync(""+this.root_dir+e)}catch(r){s=r,console.log("AssetServer::image "+e+" !! file not found")}return this.res.end(t||!1)},e.prototype.process_replacements=function(e){var t,s,r,o,n,c,i,a,p,f,l;if(p=e.match(/#(\s+|)\{\{(prepend|append|insert):([a-zA-Z0-9\-_\/]+)\}\}/g),f={},!p||!p.length)return e;for(n=0,i=p.length;i>n;n++)a=p[n],f.hasOwnProperty(a)||(t=a.match(/(prepend|append|insert):/),s=a.match(/:([a-zA-Z0-9\-_\/]+)/),o=__dirname+"/assets/coffee/"+s[1]+".coffee",r=this.process_replacements(fs.readFileSync(o,"UTF-8")),f[a]={action:t[1],file:s[1],contents:r});for(c in f)l=f[c],l.action.indexOf("pend")>-1&&(e=e.replace(new RegExp(c,"g"),"")),"append"===l.action?e+=l.contents:e="prepend"===l.action?l.contents+e:e.replace(new RegExp(c,"g"),l.contents);return e},e}();