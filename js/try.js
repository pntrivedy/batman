// Generated by CoffeeScript 1.3.3
(function() {
  var steps,
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  $('<script src="lib/dist/batman.jquery.js"></script>').appendTo('head');

  $('<script src="lib/extras/batman.rails.js"></script>').appendTo('head');

  $('<script src="js/codemirror.js"></script>').appendTo('head');

  $('<script src="js/modes/coffeescript.js"></script>').appendTo('head');

  $('<script src="js/modes/ruby.js"></script>').appendTo('head');

  $('<link rel="stylesheet" href="css/codemirror.css" />').appendTo('head');

  $('<link rel="stylesheet" href="css/solarized.css" />').appendTo('head');

  window.Try = (function(_super) {

    __extends(Try, _super);

    function Try() {
      return Try.__super__.constructor.apply(this, arguments);
    }

    Try.dispatcher = false;

    Try.navigator = false;

    Try.layout = 'layout';

    return Try;

  })(Batman.App);

  Try.LayoutView = (function(_super) {

    __extends(LayoutView, _super);

    function LayoutView(options) {
      options.node = $('.intro')[0];
      LayoutView.__super__.constructor.apply(this, arguments);
    }

    LayoutView.prototype.showFile = function(file) {
      if (file.get('isDirectory')) {
        return file.set('isExpanded', !file.get('isExpanded'));
      } else {
        this.set('currentFile', file);
        return file.show();
      }
    };

    return LayoutView;

  })(Batman.View);

  Try.File = (function(_super) {

    __extends(File, _super);

    function File() {
      return File.__super__.constructor.apply(this, arguments);
    }

    File.storageKey = 'app_files';

    File.resourceName = 'app_files';

    File.persist(Batman.RailsStorage);

    File.findByName = function(name) {
      return this.get('loaded.indexedBy.name').get(name).get('first');
    };

    File.encode('name', 'content', 'isDirectory');

    File.encode('children', {
      decode: function(kids) {
        var kid, set, _i, _len;
        set = new Batman.Set;
        for (_i = 0, _len = kids.length; _i < _len; _i++) {
          kid = kids[_i];
          set.add((new Try.File).fromJSON(kid));
        }
        return set;
      }
    });

    File.prototype.isExpanded = false;

    File.prototype.show = function() {
      var _this = this;
      return new Batman.Request({
        url: "/app_files/1.json?path=" + (this.get('id')),
        success: function(data) {
          var keys, mode;
          _this.fromJSON(data);
          if (!_this.cm) {
            mode = _this.get('name').indexOf('.coffee') !== -1 ? 'coffeescript' : 'ruby';
            keys = {
              'Cmd-S': function() {
                return _this.save();
              }
            };
            _this.node = $('<div></div>');
            _this.cm = CodeMirror(_this.node[0], {
              theme: 'solarized',
              mode: mode,
              lineNumbers: true,
              extraKeys: keys
            });
          }
          _this.cm.setValue(_this.get('content') || '');
          return $('#code-editor').html('').append(_this.node);
        }
      });
    };

    File.prototype.save = function() {
      return this.set('value', this.cm.getValue());
    };

    return File;

  })(Batman.Model);

  Try.FileView = (function(_super) {

    __extends(FileView, _super);

    function FileView() {
      return FileView.__super__.constructor.apply(this, arguments);
    }

    FileView.prototype.html = "<a data-bind=\"file.name\" data-event-click=\"showFile | withArguments file\" class=\"file\" data-addclass-directory=\"file.isDirectory\" data-addclass-active=\"currentFile | equals file\" data-addclass-expanded=\"file.isExpanded\"></a>\n<ul data-showif=\"file.isDirectory | and file.isExpanded\" data-renderif=\"file.isDirectory\">\n	<li data-foreach-file=\"file.children\">\n		<div data-view=\"FileView\"></div>\n	</li>\n</ul>";

    return FileView;

  })(Batman.View);

  Try.Step = (function(_super) {

    __extends(Step, _super);

    function Step() {
      return Step.__super__.constructor.apply(this, arguments);
    }

    Step.prototype.activate = function() {
      Try.set('currentStep', this);
      return this.start();
    };

    Step.prototype.start = function() {};

    Step.prototype.next = function() {
      var array, index, step;
      array = steps.toArray();
      index = array.indexOf(this);
      step = array[index + 1];
      return typeof step.activate === "function" ? step.activate() : void 0;
    };

    return Step;

  })(Batman.Object);

  Try.ConsoleStep = (function(_super) {

    __extends(ConsoleStep, _super);

    function ConsoleStep() {
      return ConsoleStep.__super__.constructor.apply(this, arguments);
    }

    ConsoleStep.prototype.isConsole = true;

    ConsoleStep.prototype.start = function() {
      return $('#terminal-field').focus();
    };

    ConsoleStep.expect = function(regex) {
      return this.prototype.regex = regex;
    };

    ConsoleStep.prototype.check = function(value) {
      if (this.regex.test(value)) {
        return this.next();
      }
    };

    return ConsoleStep;

  })(Try.Step);

  Try.CodeStep = (function(_super) {

    __extends(CodeStep, _super);

    function CodeStep() {
      return CodeStep.__super__.constructor.apply(this, arguments);
    }

    CodeStep.prototype.isCode = true;

    CodeStep.prototype.start = function() {
      var file, filename, _ref,
        _this = this;
      if (filename = this.focusFile) {
        file = Try.File.findByName(filename);
        file.show();
      }
      if (filename = (_ref = this.options) != null ? _ref["in"] : void 0) {
        file = Try.File.findByName(filename);
        return file.observe('value', function(value) {
          if (_this.regex.test(value)) {
            return _this.next();
          }
        });
      }
    };

    CodeStep.expect = function(regex, options) {
      this.prototype.regex = regex;
      return this.prototype.options = options;
    };

    CodeStep.focus = function(name) {
      return this.prototype.focusFile = name;
    };

    return CodeStep;

  })(Try.Step);

  Try.GemfileStep = (function(_super) {

    __extends(GemfileStep, _super);

    function GemfileStep() {
      return GemfileStep.__super__.constructor.apply(this, arguments);
    }

    GemfileStep.prototype.heading = "Welcome to Batman!";

    GemfileStep.prototype.body = "Let's build an app. We've created a brand new Rails app for you.";

    GemfileStep.prototype.task = "Start off by adding `batman-rails` to your gemfile, and press Cmd+S when you're done.";

    GemfileStep.expect(/gem\s*[\"|\']batman\-rails[\"|\']/, {
      "in": 'Gemfile'
    });

    GemfileStep.focus('Gemfile');

    return GemfileStep;

  })(Try.CodeStep);

  Try.GenerateAppStep = (function(_super) {

    __extends(GenerateAppStep, _super);

    function GenerateAppStep() {
      return GenerateAppStep.__super__.constructor.apply(this, arguments);
    }

    GenerateAppStep.prototype.heading = "Great! We've run `bundle install` for you.";

    GenerateAppStep.prototype.body = "Now, let's create a new batman application inside your rails app.";

    GenerateAppStep.prototype.task = "Run `rails generate batman:app` from the console, and press enter to submit the command.";

    GenerateAppStep.expect(/rails\s*[g|generate]\s*batman:app/);

    return GenerateAppStep;

  })(Try.ConsoleStep);

  Try.ExploreStep = (function(_super) {

    __extends(ExploreStep, _super);

    function ExploreStep() {
      return ExploreStep.__super__.constructor.apply(this, arguments);
    }

    return ExploreStep;

  })(Try.CodeStep);

  steps = new Batman.Set(new Try.GemfileStep, new Try.GenerateAppStep);

  Try.set('steps', steps);

  Try.File.load(function() {
    Try.run();
    steps.get('first').activate();
    return $('#terminal-field').on('keydown', function(e) {
      var _ref;
      if (e.keyCode === 13) {
        return (_ref = Try.get('currentStep')) != null ? _ref.check(this.value) : void 0;
      }
    });
  });

}).call(this);
