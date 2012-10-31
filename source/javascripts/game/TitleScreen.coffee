class @TitleScreen extends FW.ContainerProxy
  constructor: ->
    super()
    @_tickHandlers = []

    createTitleBox(@)
    createjs.Ticker.addListener(@)

  addTickHandler: (handler) ->
    @_tickHandlers.push(handler)

  tick: ->
    for handler in @_tickHandlers
      handler()


createTitleBox = (screen) ->
  container = new createjs.Container()

  background = new createjs.Shape()
  graphics = background.graphics
  graphics.setStrokeStyle(0.02, "round", "round")
  graphics.beginStroke("rgba(0, 0, 0, 0)")
  graphics.beginFill("rgba(192, 0, 192, 0.5)")

  graphics.drawRect(0, 0, 1, 1)
  graphics.endFill()
  graphics.endStroke()

  text = new createjs.Text("Mazeoid")
  text.font = "48px Upheaval"
  text.textAlign = "left"
  text.x = 10

  container.addChild(background)
  container.addChild(text)

  screen.addChild(container)
  screen.addTickHandler ->
    canvas = screen.getStage().canvas
    background.scaleX = canvas.width
    background.scaleY = 48