(function(){var t,e,n;n=function(){function t(t,e){this.opts=null!=e?e:{},this.container=$(t),this.setup()}return t.prototype.setup=function(){var t;return(null!=(t=window.location.hash)?t.length:void 0)?(this.this_page=window.location.hash.replace("#","")||"home",this.container.find("a[href=#"+this.this_page+"]").closest("li").addClass("selected")):void 0},t}(),t=function(){function t(t,e){this.opts=null!=e?e:{},this.container=$(t),this.setup()}return t.prototype.setup=function(){return this.beats=this.container.find(".beat"),this.soundcloud_template||(this.soundcloud_template=$("#soundcloud_player_template").html()),this.setup_embeds()},t.prototype.setup_embeds=function(){var t,e,n,o;if(this.beats){for(o=this.beats,e=0,n=o.length;n>e;e++)t=o[e],this.setup_embed($(t));return this.container.on("click",".beat",function(t){return function(e){var n;return n=$(e.currentTarget),t.setup_embed(n)}}(this))}},t.prototype.setup_embed=function(t){var e;if(!t.find("iframe").length)return e=t.data("soundcloud_id"),t.append("<div class='soundcloud_placeholder'><img src=\"../images/beats/placeholder_"+e+'.jpg" /></div>'),t.one("click",function(n){return function(o){var i;return t=$(o.currentTarget),e=t.data("soundcloud_id"),i=n.soundcloud_template.replace("{{track_id}}",e),t.find(".soundcloud_placeholder").replaceWith(i)}}(this))},t}(),e=function(){function t(){}return t.load=function(t){return $(t).find("[data-lazy_background]").each(function(){return $(this).css({backgroundImage:"url("+$(this).data("lazy_background")+")",backgroundSize:"cover",backgroundRepeat:"no-repeat"})})},t}(),$(function(){return document.nav=new n("#sidebar"),document.beats=new t("#beats_page"),e.load(document.body)})}).call(this);