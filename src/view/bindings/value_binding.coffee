#= require ./abstract_binding

Batman.DOM.ValueBinding =
  initialize: (definition) ->
    node = definition.node
    if Batman.DOM.nodeIsEditable(node)
      callback = definition.changeCallback = Batman.DOM.ValueBinding.applyValueToModel.bind(null, definition)
      Batman.DOM.events.change(node, callback)

  applyValueToNode: (definition) ->
    Batman.DOM.valueForNode(definition.node, Batman.DOM.Binding.filteredValue(definition), definition.escapeValue ? true)

  applyValueToModel: (definition) ->
    Batman.DOM.Binding.setUnfilteredValue(definition, definition.node.value)


  # nodeChange: (node, context) ->
  #   if @isTwoWay()
  #     @set 'filteredValue', @node.value
