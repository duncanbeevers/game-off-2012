FW = @FW ||= {}

FW.MouseHarness =
  outfit: (displayObject, receiver) ->
    stage = displayObject.getStage()
    originalOnMouseDown = stage.onMouseDown
    originalOnMouseUp   = stage.onMouseUp
    originalOnMouseMove = stage.onMouseMove
    originalOnMouseOver = stage.onMouseOver
    originalOnMouseOut  = stage.onMouseOut
    originalOnClick     = stage.onClick

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
      # if activated
      #   color = "193, 255, 33"
      # else
      #   color = "0, 0, 255"

      # graphics.clear()
      # scalar = 1 / displayObject.scaleX
      # graphics.setStrokeStyle(4 * scalar)
      # graphics.beginStroke("rgba(#{color}, 0.6)")
      # graphics.beginFill("rgba(#{color}, 0.45)")
      # graphics.drawCircle(0, 0, 15 * scalar)

    renderHarness(false)

    stage.onMouseDown = (event) ->
      activateHarness()
      originalOnMouseDown && originalOnMouseDown.call(@, event)

    stage.onMouseUp = (event) ->
      deactivateHarness()
      harness_x = event.stageX
      harness_y = event.stageY
      originalOnMouseUp && originalOnMouseUp.call(@, event)

    stage.onMouseMove = (event) ->
      harness_x = event.stageX
      harness_y = event.stageY
      originalOnMouseMove && originalOnMouseMove.call(@, event)

    stage.onMouseOver = (event) ->
      # debugger
      originalOnMouseOver && originalOnMouseOver.call(@, event)

    stage.onMouseOut = (event) ->
      # debugger
      originalOnMouseOut && originalOnMouseOut.call(@, event)

    stage.onClick = (event) ->
      # debugger
      originalOnClick && originalOnClick.call(@, event)

    Ticker.addListener
      tick: ->
        point = displayObject.globalToLocal(harness_x, harness_y)
        tracker.x = point.x
        tracker.y = point.y

    ->
      point = displayObject.globalToLocal(harness_x, harness_y)
      x: point.x
      y: point.y
      activated: harness_activated