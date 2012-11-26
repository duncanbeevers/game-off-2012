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
    @_titleBox = titleBox
    @_levelPicker = levelPicker

  onEnterScene: ->
    game = @_game
    levelPicker = @_levelPicker
    [ profileName, profileData ] = @_profile

    @_hciSet = @_hci.on(
      [ "keyDown:#{FW.HCI.KeyMap.ENTER}", -> game.beginLevel(levelPicker.currentLevelData(), profileName, profileData) ]
      [ "keyDown:#{FW.HCI.KeyMap.LEFT}",  -> levelPicker.selectPrevious() ]
      [ "keyDown:#{FW.HCI.KeyMap.RIGHT}", -> levelPicker.selectNext() ]
    )

  onLeaveScene: ->
    @_hciSet.off()

  setProfileData: (profileName, profileData) ->
    @_profile = [ profileName, profileData ]
    titleBox = @_titleBox
    titleBox.setTitle(profileName)

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
