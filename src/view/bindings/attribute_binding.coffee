#= require ./abstract_attribute_binding

Batman.DOM.AttributeBinding =
  applyValueToNode: (binding) ->
    binding.node.setAttribute(binding.attr, Batman.DOM.Binding.filteredValue(binding))

  applyValueToModel: (binding) ->
    Batman.DOM.setUnfilteredValue(Batman.DOM.attrReaders._parseAttribute(binding.node.getAttribute(binding.attr)))
