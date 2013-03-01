$('<script src="lib/dist/batman.jquery.js"></script>').appendTo('head')
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

class Try.File extends Batman.Model
	@encode 'name', 'content', 'isDirectory'

	@accessor 'children', ->
		new Batman.Set(
			new Try.File(name: 'foo', isDirectory: false),
			new Try.File(name: 'bar', isDirectory: false)
		)

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

files = new Batman.Set(new Try.File(name: 'rdio', isDirectory: true))
Try.set('files', files)

Try.run()
