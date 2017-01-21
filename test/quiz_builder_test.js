(function(){var e,s,t,i;t=require("assert"),i=require("sinon"),s=require("./../class/quiz_builder.js"),e=require("./../class/quiz.js"),describe("QuizBuilder",function(){return it("should build a quiz",function(){var i;return i=s.build(),t(i instanceof e)}),it("should pass settings to quiz",function(){var e;return e=s.build({name:"test_quiz"}),t("test_quiz"===e.opts.name)}),it("should also pass settings as the second parameter",function(){var e;return e=s.build("japanese_vocab",{name:"test_quiz"}),t("test_quiz"===e.opts.name)}),it("should look up question data when possible",function(){var e;return e=s.build("japanese_numbers"),t(e.opts.question_data.length>0)})})}).call(this);