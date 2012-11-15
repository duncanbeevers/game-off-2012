# Generate an HCI instance bound to DOM events by jQuery
$.FW_HCI = ->
  hci = new FW.HCI.HCI()

  onVisibilityChange = (event) ->
    documentHidden = document.hidden || document.webkitHidden

    if documentHidden
      hci.windowBecameVisible()
    else
      hci.windowBecameInvisible()

  $document = $(document)
  $document.on "visibilitychange",       onVisibilityChange
  $document.on "webkitvisibilitychange", onVisibilityChange
  $document.on "keydown", (event) -> hci.triggerKeyDown(event.keyCode)
  $document.on "keyup",   (event) -> hci.triggerKeyUp(event.keyCode)

  $document.on "touchmove", (event) -> event.preventDefault()

  hci
