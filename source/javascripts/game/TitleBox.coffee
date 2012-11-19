class @TitleBox extends FW.ContainerProxy
  constructor: ->
    super()

    background = new createjs.Shape()
    graphics = background.graphics
    graphics.setStrokeStyle(0.02, "round", "round")
    graphics.beginStroke("rgba(0, 0, 0, 0)")
    graphics.beginFill("rgba(192, 0, 192, 0.3)")

    graphics.drawRect(0, 0, 1, 1)
    graphics.endFill()
    graphics.endStroke()

    text = TextFactory.create("Mazeoid", "#eee")
    text.textAlign = "left"
    text.x = 64
    text.y = 23

    logo = new createjs.Bitmap("images/Logo.png")
    logo.x = 4
    logo.y = 0

    @addChild(background)
    @addChild(text)
    @addChild(logo)

    @_background = background

  onTick: ->
    background = @_background

    canvas = @getStage().canvas
    background.scaleX = canvas.width
    background.scaleY = 48
