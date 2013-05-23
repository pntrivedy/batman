#= require ./abstract_collection_binding

class Batman.DOM.IteratorBinding extends Batman.DOM.AbstractCollectionBinding
  currentActionNumber: 0
  queuedActionNumber: 0
  bindImmediately: false
  skipChildren: true
  onlyObserve: Batman.BindingDefinitionOnlyObserve.Data

  constructor: (definition) ->
    {node: sourceNode, attr: @iteratorName, keyPath: @key, renderer: @parentRenderer} = definition

    @prototypeNode = sourceNode.cloneNode(true)
    @prototypeNode.removeAttribute "data-foreach-#{@iteratorName}"

    # Create a reference sibling node in order to know where this foreach ends,
    # and move any Batman._data from the sourceNode to the sibling because we need to
    # retain the bindings, and we want to dispose of the node.
    previousSiblingNode = sourceNode.nextSibling
    @startNode = document.createComment "start #{@iteratorName}-#{@get('_batmanID')}"
    @endNode = document.createComment "end #{@iteratorName}-#{@get('_batmanID')}"
    @endNode[Batman.expando] = sourceNode[Batman.expando]
    delete sourceNode[Batman.expando] if Batman.canDeleteExpando
    Batman.DOM.insertBefore sourceNode.parentNode, @startNode, previousSiblingNode
    Batman.DOM.insertBefore sourceNode.parentNode, @endNode, previousSiblingNode

    # Don't let the parent emit its rendered event until this iteration has set up
    @parentRenderer.prevent 'rendered'

    # Remove the original node once the parent has moved past it.
    Batman.DOM.onParseExit sourceNode.parentNode, =>
      Batman.DOM.destroyNode sourceNode
      @bind()
      @parentRenderer.allowAndFire 'rendered'

    definition.node = @endNode
    super

  # The parent node can change if this content is yielded into a different container,
  # so use a function to grab it.
  parentNode: -> @endNode.parentNode

  dataChange: (collection) ->
    if collection?
      unless @bindCollection(collection)
        items = if collection?.forEach
          _items = []
          collection.forEach (item) -> _items.push item
          _items
         else
          Object.keys(collection)
        @handleArrayChanged(items)
    else
      @handleArrayChanged([])

  handleArrayChanged: (newItems) =>
    if @nodes
      for node in @nodes
        if @_nodesToBeRendered.has(node)
          @_nodesToBeRemoved ||= new Batman.SimpleSet
          @_nodesToBeRemoved.add(node)

    oldNodes = @nodes
    @nodes = []

    if newItems
      childRenderTracker = new Batman.Object
      @parentRenderer.prevent 'rendered'

      childRenderTracker.once 'rendered', =>
        @_replaceNodes(@nodes, oldNodes)
        @parentRenderer.allowAndFire 'rendered'

      for newItem, index in newItems
        @nodes ?= []
        @nodes.push node = @_newNodeForItem(newItem, childRenderTracker)

    return

  _itemForNode: (node) ->
    Batman._data(node, "#{@iteratorName}Item")

  _newNodeForItem: (newItem, childRenderTracker) ->
    newNode = @prototypeNode.cloneNode(true)
    @_nodesToBeRendered ||= new Batman.SimpleSet
    @_nodesToBeRendered.add(newNode)

    Batman._data(newNode, "#{@iteratorName}Item", newItem)
    childRenderTracker.prevent 'rendered'

    renderer = new Batman.Renderer newNode, @renderContext.descend(newItem, @iteratorName), @parentRenderer.view
    renderer.once 'parsed', =>
      @_nodesToBeRendered.remove(newNode)
      if @_nodesToBeRemoved?.has(newNode)
        @_nodesToBeRemoved.remove(newNode)
        @_removeNode(newNode)
      else
        Batman.DOM.propagateBindingEvents(newNode)
        @fire 'nodeAdded', newNode

      childRenderTracker.allowAndFire 'rendered'

    newNode

  _replaceNodes: (newNodes, oldNodes) =>
    fragment = document.createDocumentFragment()

    fragment.appendChild node for node in newNodes if newNodes?
    @_removeNode node for node in oldNodes if oldNodes?

    @parentNode().insertBefore(fragment, @endNode) if newNodes.length

  _removeNode: (node) ->
    Batman.DOM.destroyNode(node)
    @fire 'nodeRemoved', node

  die: ->
    # ensure any remaining un-rendered nodes are removed once rendering is complete
    # if this binding dies before they're done rendering
    if @_nodesToBeRendered && !@_nodesToBeRendered.isEmpty()
      @_nodesToBeRemoved ||= new Batman.SimpleSet
      @_nodesToBeRemoved.add(@_nodesToBeRendered.toArray()...)
    super
