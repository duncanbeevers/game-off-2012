FW = @FW ||= {}
HCI = FW.HCI ||= {}

# Human-Computer Interface
# Represents a unified source for interactions that come in
# directtly through human interaction, such as keypresses,
# mouse moves, and browser size and visibility changes.
#
# Emits
# -- low-level
#   visibilitychange
#   keyup
#   keydown
# -- high-level
#   key:CODE
#   windowBecameVisibile
#   windowBecameInvisible

class HCI.HCI
  constructor: (keyMap) ->
    @_keyMap = keyMap
    @_handlers = {}

  windowBecameVisible: ->
    @trigger("windowBecameVisible")

  windowBecameInvisible: ->
    @trigger("windowBecameInisible")

  on: (eventName, args...) ->
    parts = eventName.split(":")
    switch parts[0]
      when "key"
        @_keyMap.on(parts[1], args[1], args[2])
      else
        handlers = @_handlers[parts[0]] ||= []
        handlers.push [ parts, args ]

  trigger: (eventName, args...) ->
    parts = eventName.split(":")
    handlers = @_handlers[parts[0]]
    if handlers
      for [eventNameParts, handlerAndArgs] in handlers
        [ handler, handlerArgs... ] = handlerAndArgs
        handler.apply(@, handlerArgs)
