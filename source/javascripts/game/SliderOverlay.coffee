class @SliderOverlay extends FW.ContainerProxy
  constructor: ->
    super()

    leftShape          = new createjs.Shape()
    rightShape         = new createjs.Shape()

    @addChild(leftShape)
    @addChild(rightShape)

    leftShape.regY      = 0.5
    leftShape.x         = 0
    leftShape.y         = 0.5
    rightShape.regY     = 0.5
    rightShape.rotation = 180
    rightShape.x        = 1
    rightShape.y        = 0.5

    @_harness    = FW.MouseHarness.outfit(@)
    @_rightShape = rightShape
    @_leftShape  = leftShape

  onTick: ->
    container = @
    stage = container.getStage()
    if stage
      canvas = stage.canvas
      container.scaleX = canvas.width
      container.scaleY = canvas.height
      container.x = 0
      container.y = 0

      leftShape = @_leftShape
      rightShape = @_rightShape
      leftShapeGraphics  = leftShape.graphics
      rightShapeGraphics = rightShape.graphics

      sliderMargin = 1 / 3.8
      leftShape.scaleX = sliderMargin
      rightShape.scaleX = sliderMargin

      mouse = @_harness()

      if mouse.x < sliderMargin
        # Do something with the left one
        drawHoverOverlay(leftShapeGraphics)
        drawAtRestOverlay(rightShapeGraphics)
      else if mouse.x > 1 - sliderMargin
        # Do something with the right one
        drawAtRestOverlay(leftShapeGraphics)
        drawHoverOverlay(rightShapeGraphics)
      else
        drawAtRestOverlay(leftShapeGraphics)
        drawAtRestOverlay(rightShapeGraphics)


drawAtRestOverlay = (graphics) ->
  graphics.clear()
  graphics.beginFill("rgba(255, 0, 0, 0.5)")
  graphics.drawRect(0, 0, 1, 1)
  graphics.endFill()

drawHoverOverlay = (graphics) ->
  graphics.clear()
  graphics.beginFill("rgba(0, 255, 0, 0.5)")
  graphics.drawRect(0, 0, 1, 1)
  graphics.endFill()
