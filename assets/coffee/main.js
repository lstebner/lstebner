(function(){var t,e;e=function(){function t(t,e){this.opts=null!=e?e:{},this.container=$(t),this.setup()}return t.prototype.setup=function(){return this.this_page=(window.location.hash||"").replace("#","")||"home",this.container.find("a[href=#"+this.this_page+"]").closest("li").addClass("selected")},t}(),t=function(){function t(t,e){this.opts=null!=e?e:{},this.container=$(t),this.setup()}return t.prototype.setup=function(){return this.beats=this.container.find(".beat"),this.soundcloud_template||(this.soundcloud_template=$("#soundcloud_player_template").html()),this.setup_embeds()},t.prototype.setup_embeds=function(){var t,e,n,s;if(this.beats){for(s=this.beats,e=0,n=s.length;n>e;e++)t=s[e],this.setup_embed($(t));return this.container.on("click",".beat",function(t){return function(e){var n;return n=$(e.currentTarget),t.setup_embed(n)}}(this))}},t.prototype.setup_embed=function(t){var e;if(!t.find("iframe").length)return e=t.data("soundcloud_id"),t.append("<div class='soundcloud_placeholder'><img src=\"../assets/images/beats/placeholder_"+e+'.jpg" /></div>'),t.one("click",function(n){return function(s){var i;return t=$(s.currentTarget),e=t.data("soundcloud_id"),i=n.soundcloud_template.replace("{{track_id}}",e),t.find(".soundcloud_placeholder").replaceWith(i)}}(this))},t}(),$(function(){return document.nav=new e("#sidebar"),document.beats=new t("#beats_page")})}).call(this);