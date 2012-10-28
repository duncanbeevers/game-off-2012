@FW ||= {}
FW = @FW

FW.MouseHarness =
  outfit: (displayObject, receiver) ->
    originalOnMouseDown = displayObject.onMouseDown
    originalOnMouseUp   = displayObject.onMouseUp
    originalOnMouseMove = displayObject.onMouseMove
    originalOnMouseOver = displayObject.onMouseOver
    originalOnMouseOut  = displayObject.onMouseOut
    originalOnClick     = displayObject.onClick

    graphics = new createjs.Graphics()

    tracker = new createjs.Shape(graphics)
    displayObject.addChild(tracker)

    harness_x = 0
    harness_y = 0
    harness_activated = false

    activateHarness = ->
      return if harness_activated
      harness_activated = true
      renderHarness(harness_activated)

    deactivateHarness = ->
      return unless harness_activated
      harness_activated = false
      renderHarness(harness_activated)

    renderHarness = (activated) ->
      if activated
        color = "193, 255, 33"
      else
        color = "0, 0, 255"

      graphics.clear()
      graphics.setStrokeStyle(4)
      graphics.beginStroke("rgba(#{color}, 0.6)")
      graphics.beginFill("rgba(#{color}, 0.45)")
      graphics.drawCircle(0, 0, 15)

    renderHarness(false)

    displayObject.onMouseDown = (event) ->
      activateHarness()
      originalOnMouseDown && originalOnMouseDown.call(@, event)

    displayObject.onMouseUp = (event) ->
      deactivateHarness()
      harness_x = event.rawX
      harness_y = event.rawY
      originalOnMouseUp && originalOnMouseUp.call(@, event)

    displayObject.onMouseMove = (event) ->
      harness_x = event.rawX
      harness_y = event.rawY
      originalOnMouseMove && originalOnMouseMove.call(@, event)

    displayObject.onMouseOver = (event) ->
      # debugger
      originalOnMouseOver && originalOnMouseOver.call(@, event)

    displayObject.onMouseOut = (event) ->
      # debugger
      originalOnMouseOut && originalOnMouseOut.call(@, event)

    displayObject.onClick = (event) ->
      # debugger
      originalOnClick && originalOnClick.call(@, event)

    Ticker.addListener
      tick: ->
        tracker.x = harness_x
        tracker.y = harness_y

    ->
      x: harness_x
      y: harness_y
      activated: harness_activated