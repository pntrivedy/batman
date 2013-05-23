#= require ./abstract_binding

Batman.DOM.ValueBinding =
  initialize: (binding) ->
    node = binding.node
    if Batman.DOM.nodeIsEditable(node)
      callback = binding.changeCallback = Batman.DOM.ValueBinding.applyValueToModel.bind(null, binding)
      Batman.DOM.events.change(node, callback)

  applyValueToNode: (binding) ->
    Batman.DOM.valueForNode(binding.node, Batman.DOM.Binding.filteredValue(binding), binding.escapeValue ? true)

  applyValueToModel: (binding) ->
    Batman.DOM.Binding.setUnfilteredValue(binding, binding.node.value)


  # nodeChange: (node, context) ->
  #   if @isTwoWay()
  #     @set 'filteredValue', @node.value
