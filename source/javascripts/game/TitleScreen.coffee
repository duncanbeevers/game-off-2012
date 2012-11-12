class @TitleScreen extends FW.ContainerProxy
  constructor: (game, hci) ->
    super()

    @_tickHandlers = []

    preloader = game.getPreloader()

    createTitleBox(@)
    createLevelPicker(@, preloader.getLevels(), hci)

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
  graphics.beginFill("rgba(192, 0, 192, 0.3)")

  graphics.drawRect(0, 0, 1, 1)
  graphics.endFill()
  graphics.endStroke()

  text = new createjs.Text("Mazeoid")
  text.font = "48px Upheaval"
  text.textAlign = "left"
  text.color = "#eee"
  text.x = 64

  logo = new createjs.Bitmap("images/Logo.png")
  logo.x = 4
  logo.y = 0

  container.addChild(background)
  container.addChild(text)
  container.addChild(logo)

  screen.addChild(container)
  screen.addTickHandler ->
    canvas = screen.getStage().canvas
    background.scaleX = canvas.width
    background.scaleY = 48

createLevelPicker = (screen, levels, hci) ->
  initialLevelIndex = 0
  levelPicker = new LevelPicker(screen, levels, initialLevelIndex)

  screen.addChild(levelPicker)
  screen.addTickHandler ->
    levelsVisibleOnScreen = 3.5

    canvas = screen.getStage().canvas
    levelPicker.scaleX = canvas.width / levelsVisibleOnScreen
    levelPicker.scaleY = levelPicker.scaleX

    levelPicker.x = canvas.width / 2
    levelPicker.y = canvas.width / 20 + 150
    levelPicker.tick()

  hci.on "levelPickerFocusOnPreviousLevel", -> levelPicker.focusOnPreviousLevel()
  hci.on "levelPickerFocusOnNextLevel", -> levelPicker.focusOnNextLevel()
