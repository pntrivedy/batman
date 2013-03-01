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

	@accessor 'currentStep', ->
		Try.get('steps.first')

class Try.File extends Batman.Model
	@storageKey: 'app_files'
	@resourceName: 'app_files'

	@persist Batman.RailsStorage

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
					@node = $('<div></div>')
					mode = if @get('name').indexOf('.coffee') != -1 then 'coffeescript' else 'ruby'
					console.log mode
					@cm = CodeMirror(@node[0], theme: 'solarized', mode: mode, lineNumbers: true)

				@cm.setValue(@get('content') || '')
				$('#code-editor').html('').append(@node)

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

class Try.ConsoleStep extends Try.Step
	isConsole: true

class Try.CodeStep extends Try.Step
	isCode: true

	@expect: (regex, options) ->


class Try.InitializeAppStep extends Try.CodeStep
	heading: "Welcome to Batman!"
	body: "Let's build an app. We've created a brand new Rails app for you."
	task: "Start off by adding `batman-rails` to your gemfile."

	@expect /gem\w[\"\']batman\-rails[\"\']/, in: 'Gemfile'

steps = new Batman.Set(
	new Try.InitializeAppStep
)

Try.set('steps', steps)

Try.run()
