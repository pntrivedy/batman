#= require ./abstract_binding

class Batman.DOM.ViewBinding extends Batman.DOM.AbstractBinding
  skipChildren: true
  onlyObserve: Batman.BindingDefinitionOnlyObserve.Data

  constructor: ({node})->
    node.removeAttribute 'data-view'
    super
    @renderer.prevent 'rendered'

  dataChange: (viewClassOrInstance) ->
    return unless viewClassOrInstance?
    if viewClassOrInstance.isView
      @view = viewClassOrInstance
      @view.set 'context', @renderContext
      @view.set 'node', @node
    else
      @view = new viewClassOrInstance
        node: @node
        context: @renderContext
        parentView: @renderer.view

    @view.on 'ready', =>
      @renderer.allowAndFire 'rendered'

    @forget()
    @_batman.properties?.forEach (key, property) -> property.die()

  die: ->
    @view = null
    super
