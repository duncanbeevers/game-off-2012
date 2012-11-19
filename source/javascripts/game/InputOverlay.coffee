settings =
  cursorBlinkRate: 530

class @InputOverlay extends FW.ContainerProxy
  constructor: (prompt, defaultValue) ->
    super()

    defaultValue ||= ""

    backdrop = setupBackdrop()
    gui = setupGui(prompt, defaultValue)
    cursor = setupCursor()

    @addChild(backdrop)
    @addChild(gui)
    @addChild(cursor)

    @_backdrop = backdrop
    @_gui = gui
    @_cursor = cursor
    @_value = defaultValue
    @_cursorPosition = defaultValue.length

  onTick: ->
    super()

    backdrop = @_backdrop
    gui = @_gui
    cursor = @_cursor
    cursorPosition = @_cursorPosition

    stage = @getStage()
    canvas = stage.canvas

    backdrop.scaleX = canvas.width
    backdrop.scaleY = canvas.height

    xOffset = canvas.width / 2
    yOffset = canvas.height / 2
    gui.x = xOffset
    gui.y = yOffset

    characterWidth = 30
    cursor.scaleY = 24
    cursor.x = xOffset + cursorPosition * characterWidth
    cursor.y = yOffset + 24

    blinkState = Math.floor(createjs.Ticker.getTime() / settings.cursorBlinkRate) % 2

    cursor.visible = blinkState

setupBackdrop = ->
  shape = new createjs.Shape()
  graphics = shape.graphics

  # 1x1 black half-opaque box, gets scaled to match screen size
  graphics.beginFill("rgba(0, 0, 0, 0.5)")
  graphics.drawRect(0, 0, 1, 1)
  graphics.endFill()
  shape

setupGui = (prompt, defaultValue) ->
  container = new createjs.Container()

  promptText = new createjs.Text(prompt)
  promptText.font = "48px Upheaval"
  promptText.textAlign = "center"
  promptText.textBaseline = "middle"
  promptText.color = "#FFFFFF"
  promptText.y = -24

  inputText = new createjs.Text(defaultValue)
  inputText.font = "48px Upheaval"
  inputText.textAlign = "center"
  inputText.textBaseline = "middle"
  inputText.color = "#FFFFFF"
  inputText.y = 24

  container.addChild(promptText)
  container.addChild(inputText)

  container

setupCursor = ->
  shape = new createjs.Shape()
  graphics = shape.graphics

  graphics.setStrokeStyle(0.25, "round", "bevel")
  graphics.beginStroke("#FFFFFF")
  graphics.moveTo(0, 0)
  graphics.lineTo(0, 1)

  shape
