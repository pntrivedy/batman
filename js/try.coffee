$('<script src="lib/dist/batman.jquery.js"></script>').appendTo('head')
$('<script src="lib/extras/batman.rails.js"></script>').appendTo('head')
$('<script src="js/codemirror.js"></script>').appendTo('head')
$('<script src="js/modes/javascript.js"></script>').appendTo('head')
$('<link rel="stylesheet" href="css/codemirror.css" />').appendTo('head')

cm = CodeMirror $('.code-editor-text').html('')[0],
	value: "var foo = 'bar'\nfoo += 'baz'"
	mode: "javascript"

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

	@accessor 'currentStep', ->
		Try.get('steps.first')

class Try.File extends Batman.Model
	@storageKey: 'app_files'

	@persist Batman.RailsStorage

	@encode 'name', 'content', 'isDirectory', 'children'

class Try.FileView extends Batman.View
	html: """
	<div data-addclass-directory="file.isDirectory" data-addclass-expanded="file.isExpanded">
		<a data-bind="file.name" data-event-click="showFile | withArguments file" class="file"></a>
		<ul data-showif="file.isDirectory" data-renderif="file.isDirectory">
			<li data-foreach-file="file.children">
				<div data-view="FileView"></div>
			</li>
		</ul>
	</div>
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
