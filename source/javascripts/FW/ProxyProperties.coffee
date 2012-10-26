FW = @FW ||= {}

ProxyProperties = (proxy, original, properties) ->
  if properties instanceof String
    property = properties
    Object.defineProperty proxy, properties
      get: ->
        original[property]
      set: (value) ->
        original[property] = value
  else
    for property in properties
      arguments.callee ProxyProperties(proxy, original, property)

FW.ProxyProperties = ProxyProperties