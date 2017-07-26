(function(){var a,n,e,i,r,t,o,c,s,u,l,_,k;n=require("./japanese_number.js"),e=require("./math_generator.js"),_=require("js-yaml"),t=require("fs"),c=function(a,n){var i,r,t,o,c;for(null==n&&(n={}),o=e.generate(a,n),c=[],r=0,t=o.length;t>r;r++)i=o[r],c.push([i.question,i.answer]);return c};try{k=function(a){return _.safeLoad(t.readFileSync(__dirname.replace("class","dictionary")+"/"+a+".yml"))},u=k("japanese_characters"),o=k("genki_vocab"),l=k("katakana_misc"),s={"characters.hiragana":u.hiragana,"characters.katakana":u.katakana,time:[["1:00","いち時"],["1:30","いち時本"],["2:00","に時"],["2:30","に時本"],["3:00","さん時"],["4:00","よん時"],["4:30","よん時本"],["5:00","ご時"],["6:00","ろく時"],["6:30","ろく時本"],["7:00","なな時"],["8:00","はち時"],["8:30","はち時本"],["9:00","きゅう時"],["10:00","じゅう時"],["11:00","じゅういち時"],["12:00","じゅうに時"]],genki_1:o.genki_1,genki_2:o.genki_2,genki_3:o.genki_3,genki_4:o.genki_4,genki_5:o.genki_5,katakana_misc:l,japanese_numbers:n.batch(100),addition_basic:c("addition_basic"),subtraction_basic:c("subtraction_basic"),multiplication:c("multiplication")}}catch(r){i=r,"test"!==process.env.NODE_ENV&&console.log("Error! Creating dictionary; probably with yaml",i)}module.exports=a=function(){function a(){}return a.raw_data=function(){return s},a.lookup=function(a){return null!=s[a]?s[a]:("test"!==process.env.NODE_ENV&&console.log("Dictionary lookup not found for '"+a+"'"),null)},a.l=function(n){return a.lookup(n)},a}()}).call(this);