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

class EventSet
  constructor: (hciInstance, eventMap) ->
    @_hciInstance = hciInstance
    @_handlers = {}

    for [eventName, handler, args...] in eventMap
      # [ eventName, args... ] = fullEventName.split(":")
      handlers = @_handlers[eventName] ||= []
      handlers.push([ handler, args ])

  off: ->
    @_hciInstance.off(@)

  trigger: (hci, eventName, args...) ->
    handlers = @_handlers[eventName]

    if handlers
      for [handler, handlerArgs...] in handlers
        # [ handler, handlerArgs... ] = handlerAndArgs
        handler.apply(hci, handlerArgs.concat(args))


class HCI.HCI
  constructor: ->
    @_eventSets = []

  windowBecameVisible: ->
    @trigger("windowBecameVisible")

  windowBecameInvisible: ->
    @trigger("windowBecameInisible")

  triggerKeyDown: (keyCode) ->
    @trigger("keyDown:#{keyCode}")

  triggerKeyUp: (keyCode) ->
    @trigger("keyUp:#{keyCode}")

  on: (eventMap...) ->
    eventSet = new EventSet(@, eventMap)

    eventSets = @_eventSets
    eventSets.push(eventSet)

    eventSet

  off: (eventSetToRemove) ->
    eventSets = (eventSet for eventSet in @_eventSets when eventSet != eventSetToRemove)
    @_eventSets = eventSets

  trigger: (eventName, args...) ->
    eventSets = @_eventSets

    for eventSet in eventSets
      eventSet.trigger(@, eventName, args)
