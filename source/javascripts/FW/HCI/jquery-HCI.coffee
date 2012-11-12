# Generate an HCI instance bound to DOM events by jQuery
$.FW_HCI = ->
  keyMap = new FW.HCI.KeyMap()
  hci = new FW.HCI.HCI(keyMap)

  onVisibilityChange = (event) ->
    documentHidden = document.hidden || document.webkitHidden

    if documentHidden
      hci.windowBecameVisible()
    else
      hci.windowBecameInvisible()

  $document = $(document)
  $document.on "visibilitychange",       onVisibilityChange
  $document.on "webkitvisibilitychange", onVisibilityChange

  # HCI will subscribe to and map keymap events on behalf of the consumer,
  # so bind DOM events directly to keymap
  $document.on "keydown", (event) -> keyMap.onKeyDown(event.keyCode)
  $document.on "keyup",   (event) -> keyMap.onKeyUp(event.keyCode)

  hci
