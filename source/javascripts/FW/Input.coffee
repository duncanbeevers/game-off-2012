FW = @FW ||= {}

Input = FW.Input ||= {}

class KeyMap
  constructor: ->
    @_map = {}
    @_handlers = {}

  onKeyDown: (code) ->
    # console.log "keyCode: %o", code
    @_map[code] = (new Date()).getTime()
    handlers = @_handlers[code]
    if handlers && handlers.length
      for [onDown, _] in handlers
        if onDown
          onDown()

  onKeyUp: (code) ->
    now = (new Date()).getTime()
    start = @_map[code]
    duration = now - start

    @_map[code] = undefined
    handlers = @_handlers[code]
    if handlers && handlers.length
      for [_, onUp] in handlers
        if onUp
          onUp(duration)

  subscribe: (code, onDown, onUp) ->
    @_handlers[code] ||= []
    @_handlers[code].push([ onDown, onUp ])

KeyMap.SPACE = 32
KeyMap.SHIFT = 16
KeyMap.COMMAND = 91

KeyMap.LEFT  = 37
KeyMap.UP    = 38
KeyMap.RIGHT = 39
KeyMap.DOWN  = 40

Input.KeyMap = KeyMap