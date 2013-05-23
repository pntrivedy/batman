#= require ./node_attribute_binding

Batman.DOM.CheckedBinding =
  initialize: (binding) ->
    node = binding.node
    if Batman.DOM.nodeIsEditable(node)
      callback = binding.changeCallback = Batman.DOM.CheckedBinding.applyValueToModel.bind(null, binding)
      Batman.DOM.events.change(node, callback)

  applyValueToNode: (binding) ->
    binding.node[binding.attr] = !!Batman.DOM.Binding.filteredValue(binding)

  applyValueToModel: (binding) ->
    Batman.DOM.Binding.setUnfilteredValue(binding, Batman.DOM.attrReaders._parseAttribute(binding.node[binding.attr]))
