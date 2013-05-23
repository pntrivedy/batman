#= require ./dom

Batman.DOM.AttrReaderBindingDefinition = (node, attr, keyPath, context, renderer) ->
  {node, attr, keyPath, context, renderer}

# `Batman.DOM.attrReaders` contains all the DOM directives which take an argument in their name, in the
# `data-dosomething-argument="keypath"` style. This means things like foreach, binding attributes like
# disabled or anything arbitrary, descending into a context, binding specific classes, or binding to events.
Batman.DOM.attrReaders =
  _parseAttribute: (value) ->
    if value is 'false' then value = false
    if value is 'true' then value = true
    value

  source: (definition) ->
    definition.onlyObserve = Batman.BindingDefinitionOnlyObserve.Data
    Batman.DOM.attrReaders.bind(definition)

  bind: (binding) ->
    binding.bindingClass = switch binding.attr
      when 'checked', 'disabled', 'selected'
        Batman.DOM.CheckedBinding
      when 'value', 'href', 'src', 'size'
        Batman.DOM.NodeAttributeBinding
      when 'class'
        Batman.DOM.ClassBinding
      when 'style'
        Batman.DOM.StyleBinding
      else
        Batman.DOM.AttributeBinding

  context: (definition) ->
    definition.context.descendWithDefinition(definition)

  event: (definition) ->
    new Batman.DOM.EventBinding(definition)

  addclass: (binding) ->
    binding.bindingClass = Batman.DOM.AddClassBinding

  removeclass: (binding) ->
    binding.invert = true
    binding.bindingClass = Batman.DOM.AddClassBinding

  foreach: (definition) ->
    new Batman.DOM.IteratorBinding(definition)

  formfor: (definition) ->
    new Batman.DOM.FormBinding(definition)
    definition.context.descendWithDefinition(definition)
