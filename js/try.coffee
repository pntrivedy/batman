$('<script src="lib/dist/batman.jquery.js"></script>').appendTo('head')
$('<script src="lib/extras/batman.rails.js"></script>').appendTo('head')
$('<script src="js/codemirror.js"></script>').appendTo('head')
$('<script src="js/modes/coffeescript.js"></script>').appendTo('head')
$('<script src="js/modes/ruby.js"></script>').appendTo('head')
$('<link rel="stylesheet" href="css/codemirror.css" />').appendTo('head')
$('<link rel="stylesheet" href="css/solarized.css" />').appendTo('head')

class window.Try extends Batman.App
	@dispatcher: false
	@navigator: false
	@layout: 'layout'

class Try.LayoutView extends Batman.View
	constructor: (options) ->
		options.node = $('.intro')[0]
		super

	showFile: (file) ->
		if file.get('isDirectory')
			file.set('isExpanded', !file.get('isExpanded'))
		else
			@set 'currentFile', file
			file.show()

class Try.File extends Batman.Model
	@storageKey: 'app_files'
	@resourceName: 'app_files'

	@persist Batman.RailsStorage

	@findByName: (name) ->
		@get('loaded.indexedBy.name').get(name).get('first')

	@encode 'name', 'content', 'isDirectory'
	@encode 'children',
		decode: (kids) ->
			set = new Batman.Set
			for kid in kids
				set.add (new Try.File).fromJSON(kid)
			set

	isExpanded: false

	show: ->
		new Batman.Request
			url: "/app_files/1.json?path=#{@get('id')}"
			success: (data) =>
				@fromJSON(data)

				if !@cm
					mode = if @get('name').indexOf('.coffee') != -1 then 'coffeescript' else 'ruby'
					keys = {'Cmd-S': => @save() }

					@node = $('<div></div>')
					@cm = CodeMirror(@node[0], theme: 'solarized', mode: mode, lineNumbers: true, extraKeys: keys)

				@cm.setValue(@get('content') || '')
				$('#code-editor').html('').append(@node)

	save: ->
		@set('value', @cm.getValue())

class Try.FileView extends Batman.View
	html: """
		<a data-bind="file.name" data-event-click="showFile | withArguments file" class="file" data-addclass-directory="file.isDirectory" data-addclass-active="currentFile | equals file" data-addclass-expanded="file.isExpanded"></a>
		<ul data-showif="file.isDirectory | and file.isExpanded" data-renderif="file.isDirectory">
			<li data-foreach-file="file.children">
				<div data-view="FileView"></div>
			</li>
		</ul>
	"""

class Try.Step extends Batman.Object
	activate: ->
		Try.set('currentStep', this)
		@start()

	start: ->

	next: ->
		array = steps.toArray()
		index = array.indexOf(this)
		step = array[index + 1]
		step.activate?()


class Try.ConsoleStep extends Try.Step
	isConsole: true

	start: ->
		$('#terminal-field').focus()

	@expect: (regex) ->
		this::regex = regex

	check: (value) ->
		if @regex.test(value)
			@next()

class Try.CodeStep extends Try.Step
	isCode: true

	start: ->
		if filename = @focusFile
			file = Try.File.findByName(filename)
			file.show()

		if filename = @options?.in
			file = Try.File.findByName(filename)
			file.observe 'value', (value) =>
				if @regex.test(value)
					@next()

	@expect: (regex, options) ->
		this::regex = regex
		this::options = options

	@focus: (name) ->
		this::focusFile = name

class Try.GemfileStep extends Try.CodeStep
	heading: "Welcome to Batman!"
	body: "Let's build an app. We've created a brand new Rails app for you."
	task: "Start off by adding `batman-rails` to your gemfile, and press Cmd+S when you're done."

	@expect /gem\s*[\"|\']batman\-rails[\"|\']/, in: 'Gemfile'
	@focus 'Gemfile'

class Try.GenerateAppStep extends Try.ConsoleStep
	heading: "Great! We've run `bundle install` for you."
	body: "Now, let's create a new batman application inside your rails app."
	task: "Run `rails generate batman:app` from the console, and press enter to submit the command."

	@expect /rails\s*[g|generate]\s*batman:app/

class Try.ExploreStep extends Try.CodeStep


steps = new Batman.Set(
	new Try.GemfileStep
	new Try.GenerateAppStep
)

Try.set('steps', steps)
Try.File.load ->
	Try.run()
	steps.get('first').activate()

	$('#terminal-field').on 'keydown', (e) ->
		if e.keyCode == 13
			Try.get('currentStep')?.check(@value)
