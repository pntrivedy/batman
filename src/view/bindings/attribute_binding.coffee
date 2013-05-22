#= require ./abstract_attribute_binding

Batman.DOM.AttributeBinding =
  applyValueToNode: (definition) ->
    definition.node.setAttribute(definition.attr, Batman.DOM.Binding.filteredValue(definition))

  applyValueToModel: ->
    if @isTwoWay()
      @set 'filteredValue', Batman.DOM.attrReaders._parseAttribute(node.getAttribute(@attributeName))
