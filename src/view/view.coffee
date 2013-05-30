#= require ../object
#= require ./html_store

class Batman.View extends Batman.Object

  @store: new Batman.HTMLStore

  @option: (keys...) ->
    Batman.initializeObject(this)
    @_batman.set('options', keys)

  subviews: {}
  superview: null
  controller: null

  source: null
  html: null
  node: null

  bindImmediately: true

  isInDOM: false
  isView: true

  constructor: ->
    @subviews = new Batman.Hash
    @_yieldNodes = {}

    @subviews.on 'itemsWereAdded', (subviewNames, newSubviews) =>
      @_addSubview(subviewNames[i], subview) for subview, i in newSubviews
      return

    @subviews.on 'itemsWereRemoved', (subviewNames, oldSubviews) =>
      subview._removeFromSuperview() for subview in oldSubviews
      return

    @subviews.on 'itemsWereChanged', (subviewNames, newSubviews, oldSubviews) =>
      for name, i in subviewNames
        oldSubviews[i]._removeFromSuperview()
        @_addSubview(name, newSubviews[i])
      return

    super

  _addSubview: (as, subview) ->
    if siblingViews = subview.superview?.subviews
      for key, value of siblingViews.toObject() when value == subview
        siblingViews.unset(key)
        break

    subview.set('superview', this)
    subview.fire('viewDidMoveToSuperview')

    @prevent('childViewsReady')
    subview.once('ready', @_fireChildViewsReady ||= => @allowAndFire('childViewsReady'))

    isInDOM = @get('isInDOM')
    subview.fire('viewWillAppear') if isInDOM

    yieldNode = @_yieldNodes[as] if typeof as is 'string'
    yieldNode ||= @get('node')
    subview.addToDOM?(yieldNode)
    subview.set('isInDOM', isInDOM)

    if isInDOM
      subview.fire('viewDidAppear')
    else
      @on('viewWillAppear', subview._fireViewWillAppear ||= -> subview.fire('viewWillAppear'))
      @on('viewDidAppear', subview._fireViewDidAppear ||= -> subview.fire('viewDidAppear'))

  _removeFromSuperview: ->
    @fire('viewWillRemoveFromSuperview')

    superview = @get('superview')
    superview.off('viewWillAppear', @_fireViewWillAppear)
    superview.off('viewDidAppear', @_fireViewDidAppear)
    @off('ready', superview._fireChildViewsReady)

    isInDOM = @get('isInDOM')
    @fire('viewWillDisappear') if isInDOM

    @removeFromDOM?()
    @set('superview', null)

    @fire('viewDidDisappear') if isInDOM

  addToDOM: (parentNode) ->
    node = @get('node')
    parentNode.appendChild(node) if node

  removeFromDOM: ->
    Batman.DOM.removeNode(@get('node'))

  loadView: ->
    if html = @get('html')
      node = document.createElement('div')
      Batman.DOM.setInnerHTML(node, html)
      return node

  @accessor 'html',
    get: ->
      return @html if @html?
      return unless source = @get('source')

      source = Batman.Navigator.normalizePath(source)
      @html = @constructor.store.get(source)

    set: Batman.Property.defaultAccessor.set

  @accessor 'node',
    get: ->
      if not @node
        node = @loadView()
        @set('node', node) if node
        @fire('viewDidLoad')

      return @node

    set: (key, node) ->
      @node = node
      return if not node

      Batman._data(node, 'view', this)
      Batman.developer.do =>
        extraInfo = @get('displayName') || @get('source')
        (if node == document then document.body else node).setAttribute?('data-batman-view', @constructor.name + if extraInfo then ": #{extraInfo}" else '')

      @initializeYields()
      @initializeBindings() if @bindImmediately

      return node

  initializeYields: ->
    return if @node.nodeType is @node.COMMENT_NODE

    yieldNodes = Batman.DOM.querySelectorAll(@node, '[data-yield]')
    for node in yieldNodes
      yieldName = node.getAttribute('data-yield')
      @declareYieldNode(yieldName, node)

    return

  initializeBindings: ->
    new Batman.Renderer(@node, this)
    @fire('ready')

  baseForKeypath: (keypath) ->
    keypath.split('.')[0].split('|')[0].trim()

  targetForKeypathBase: (base) ->
    proxiedObject = @proxiedObject
    lookupNode = proxiedObject || this

    while lookupNode
      if Batman.get(lookupNode, base)?
        return lookupNode

      controller = lookupNode.controller if lookupNode.isView and lookupNode.controller

      if proxiedObject and lookupNode == proxiedObject
        lookupNode = this
      else if lookupNode.isView and lookupNode.superview
        lookupNode = lookupNode.superview
      else if controller
        lookupNode = controller
        controller = null
      else if lookupNode != Batman.currentApp
        lookupNode = Batman.currentApp
      else
        lookupNode = null

  lookupKeypath: (keypath) ->
    base = @baseForKeypath(keypath)
    target = @targetForKeypathBase(base)

    Batman.get(target, keypath) if target

  declareYieldNode: (yieldName, node) ->
    @_yieldNodes[yieldName] = node

  firstAncestorWithYieldNamed: (yieldName) ->
    superview = this
    while superview
      return superview if yieldName of superview._yieldNodes
      superview = superview.superview

  die: ->
    @fire('destroy', @node)
    @forget()
    @_batman.properties?.forEach (key, property) -> property.die()
    @subview.forEach (name, subview) -> subview.die()
    @_removeFromSuperview() if @superview


Batman.container.$context ?= (node) ->
  while node
    return view if view = (Batman._data(node, 'backingView') || Batman._data(node, 'view'))
    node = node.parentNode

Batman.container.$subviews ?= (view = Batman.currentApp.layout) ->
  subviews = {}

  view.subviews.forEach (key, subview) ->
    obj = Batman.mixin({}, subview)
    obj.constructor = subview.constructor
    obj.subviews = if subview.subviews?.length then $subviews(subview) else null
    Batman.unmixin(obj, {'_batman': true})

    subviews[key.toString()] = obj

  subviews
