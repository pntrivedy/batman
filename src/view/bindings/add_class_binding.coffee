#= require ./abstract_attribute_binding

Batman.DOM.AddClassBinding =
  initialize: (definition) ->
    definition.classes = for name in definition.attr.split('|')
      {name: name, pattern: new RegExp("(?:^|\\s)#{name}(?:$|\\s)", 'i')}

  applyValueToNode: (definition) ->
    {node, classes, invert} = definition
    currentName = node.className
    value = Batman.DOM.Binding.filteredValue(definition)

    for {name, pattern} in classes
      includesClassName = pattern.test(currentName)
      if !!value is !invert
        node.className = "#{currentName} #{name}" if !includesClassName
      else
        node.className = currentName.replace(pattern, ' ') if includesClassName
