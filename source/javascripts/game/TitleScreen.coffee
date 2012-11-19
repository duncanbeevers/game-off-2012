class @TitleScreen extends FW.ContainerProxy
  constructor: (game, hci) ->
    super()
    screen = @

    preloader = game.getPreloader()

    titleBox = new TitleBox()
    levelPicker = setupLevelPicker(screen, preloader.getLevels(), hci)

    screen.addChild(levelPicker)
    screen.addChild(titleBox)

    @_game = game
    @_hci = hci
    @_levelPicker = levelPicker

  onEnterScene: ->
    game = @_game
    levelPicker = @_levelPicker

    @_hciSet = @_hci.on(
      [ "keyDown:#{FW.HCI.KeyMap.ENTER}", -> game.beginLevel(levelPicker.currentLevelData()) ]
      [ "keyDown:#{FW.HCI.KeyMap.LEFT}",  -> levelPicker.selectPrevious() ]
      [ "keyDown:#{FW.HCI.KeyMap.RIGHT}", -> levelPicker.selectNext() ]
    )

  onLeaveScene: ->
    @_hciSet.off()

  loadProfile: (profileData) ->
    console.log "loaded profile: %o", profileData

setupLevelPicker = (screen, levels, hci) ->
  initialLevelIndex = 0
  levelPicker = new LevelPicker(levels, initialLevelIndex)

  levelPicker.addEventListener "tick", ->
    levelsVisibleOnScreen = 3.5

    canvas = screen.getStage().canvas
    levelPicker.scaleX = canvas.width / levelsVisibleOnScreen
    levelPicker.scaleY = levelPicker.scaleX

    levelPicker.x = canvas.width / 2
    levelPicker.y = canvas.width / 20 + 150

  levelPicker
