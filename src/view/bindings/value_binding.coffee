#= require ./abstract_binding

Batman.DOM.ValueBinding =
  applyValueToNode: (definition) ->
    Batman.DOM.valueForNode(definition.node, Batman.DOM.Binding.filteredValue(definition), definition.escapeValue ? true)

  applyValueToModel: ->



  # constructor: (definition) ->
  #   @isInputBinding = definition.node.nodeName.toLowerCase() in ['input', 'textarea']
  #   super

  # nodeChange: (node, context) ->
  #   if @isTwoWay()
  #     @set 'filteredValue', @node.value
