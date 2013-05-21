#= require ./renderer

class Batman.AsyncRenderer extends Batman.Renderer
  deferEvery: 50
 
  constructor: (@node, @context, @view) ->
    super(@node, @context, @view)
    Batman.setImmediate @start

  start: =>
    @startTime = new Date
    super()

  resume: =>
    @startTime = new Date
    @parseNode @resumeNode

  finish: ->
    @startTime = null
    super()

  stop: ->
    Batman.clearImmediate @immediate
    @fire 'stopped'

  @::event('stopped').oneShot = true

  parseNode: (node) ->
    if @deferEvery && (new Date - @startTime) > @deferEvery
      @resumeNode = node
      @timeout = Batman.setImmediate @resume
      return
    super(node)
