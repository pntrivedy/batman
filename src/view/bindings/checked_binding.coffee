#= require ./node_attribute_binding

Batman.DOM.CheckedBinding =
  applyValueToNode: (definition) ->
    definition.node[definition.attr] = !!Batman.DOM.Binding.filteredValue(definition)
