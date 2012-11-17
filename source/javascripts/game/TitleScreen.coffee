class @TitleScreen extends FW.ContainerProxy
  constructor: (game, hci) ->
    super()

    preloader = game.getPreloader()

    titleBox = setupTitleBox(@)
    levelPicker = setupLevelPicker(@, preloader.getLevels(), hci)

    screen = @
    screen.addChild(levelPicker)
    screen.addChild(titleBox)

    @_hci = hci
    @_levelPicker = levelPicker

  onEnterScene: ->
    levelPicker = @_levelPicker

    @_hciSet = @_hci.on(
      [ "keyDown:#{FW.HCI.KeyMap.ENTER}", -> game.beginLevel(levelPicker.currentLevelData()) ]
      [ "keyDown:#{FW.HCI.KeyMap.LEFT}",  -> levelPicker.focusOnPreviousLevel() ]
      [ "keyDown:#{FW.HCI.KeyMap.RIGHT}", -> levelPicker.focusOnNextLevel() ]
    )

  onLeaveScene: ->
    @_hciSet.off()


setupTitleBox = (screen) ->
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
  container.onTick = ->
    canvas = screen.getStage().canvas
    background.scaleX = canvas.width
    background.scaleY = 48

  container

setupLevelPicker = (screen, levels, hci) ->
  initialLevelIndex = 0
  levelPicker = new LevelPicker(screen, levels, initialLevelIndex)

  levelPicker.addEventListener "tick", ->
    levelsVisibleOnScreen = 3.5

    canvas = screen.getStage().canvas
    levelPicker.scaleX = canvas.width / levelsVisibleOnScreen
    levelPicker.scaleY = levelPicker.scaleX

    levelPicker.x = canvas.width / 2
    levelPicker.y = canvas.width / 20 + 150

  levelPicker
