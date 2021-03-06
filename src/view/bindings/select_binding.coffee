#= require ./abstract_binding

class Batman.DOM.SelectBinding extends Batman.DOM.AbstractBinding
  isInputBinding: true
  canSetImplicitly: true

  constructor: ->
    @selectedBindings = new Batman.SimpleSet
    super

  childBindingAdded: (binding) =>
    if binding instanceof Batman.DOM.CheckedBinding
      binding.on 'dataChange', dataChangeHandler = => @nodeChange()
      binding.on 'die', =>
        binding.forget 'dataChange', dataChangeHandler
        @selectedBindings.remove(binding)

      @selectedBindings.add(binding)
    else if binding instanceof Batman.DOM.IteratorBinding
      binding.on 'nodeAdded', dataChangeHandler = =>
        @_fireDataChange(@get('filteredValue')) unless @dead
      binding.on 'nodeRemoved', dataChangeHandler
      binding.on 'die', ->
        binding.forget 'nodeAdded', dataChangeHandler
        binding.forget 'nodeRemoved', dataChangeHandler
    else
      return

    @_fireDataChange(@get('filteredValue'))

  lastKeyContext: null

  dataChange: (newValue) =>
    @lastKeyContext ||= @get('keyContext')
    if @lastKeyContext != @get('keyContext')
      @canSetImplicitly = true
      @lastKeyContext = @get('keyContext')

    # For multi-select boxes, the `value` property only holds the first
    # selection, so go through the child options and update as necessary.
    if newValue?.forEach
      # Use a hash to map values to their nodes to avoid O(n^2).
      valueToChild = {}
      for child in @node.children
        # Clear all options.
        child.selected = false

        # Avoid collisions among options with same values.
        matches = valueToChild[child.value] ||= []
        matches.push child

      # Select options corresponding to the new values
      newValue.forEach (value) =>
        if children = valueToChild[value]
          node.selected = true for node in children
        return

    # For a regular select box, update the value.
    else
      if !newValue? && @canSetImplicitly
        if @node.value
          @canSetImplicitly = false
          @set('unfilteredValue', @node.value)
      else
        @canSetImplicitly = false
        Batman.DOM.valueForNode(@node, newValue, @escapeValue)

    # Finally, update the options' `selected` bindings
    @updateOptionBindings()
    @fixSelectElementWidth()
    return

  nodeChange: =>
    if @isTwoWay()
      selections = Batman.DOM.valueForNode(@node)
      selections = selections[0] if typeof selections is Array && selections.length == 1
      @set 'unfilteredValue', selections

      @updateOptionBindings()
    return

  updateOptionBindings: =>
    @selectedBindings.forEach (binding) -> binding._fireNodeChange()

  fixSelectElementWidth: ->
    return if window.navigator.userAgent.toLowerCase().indexOf('msie') is -1 # I. Hate. Everything.
    clearTimeout(@_fixWidthTimeout) if @_fixWidthTimeout

    @_fixWidthTimeout = setTimeout =>
      @_fixWidthTimeout = null
      @_fixSelectElementWidth()
    , 100

  _fixSelectElementWidth: ->
    # There is a nasty bug in IE where select elements never reflow themselves (like ever),
    # until there is mouse interaction with them. This is a fix for select elements which
    # have their options set after they are rendered. They won't ever show their width without it.
    style = @get('node')?.style
    return if not style

    previousWidth = @get('node').currentStyle.width
    style.width = '100%'
    style.width = previousWidth ? ''
