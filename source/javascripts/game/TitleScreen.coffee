class @TitleScreen extends FW.ContainerProxy
  constructor: (game, hci) ->
    super()
    screen = @

    preloader = game.getPreloader()

    titleBox = new TitleBox()
    levelPicker = setupLevelPicker(screen, preloader.getLevels(), hci)
    levelDetailsViewer = setupLevelDetailsViewer(screen)

    screen.addChild(levelPicker)
    screen.addChild(titleBox)
    screen.addChild(levelDetailsViewer)

    @_game               = game
    @_hci                = hci
    @_titleBox           = titleBox
    @_levelPicker        = levelPicker
    @_levelDetailsViewer = levelDetailsViewer

  onEnterScene: ->
    game               = @_game
    levelPicker        = @_levelPicker
    levelDetailsViewer = @_levelDetailsViewer
    sceneManager       = game.getSceneManager()

    [ profileName, profileData ] = @_profile

    selectPreviousLevel = ->
      levelPicker.selectPrevious()
      levelDetailsViewer.setLevelData(levelPicker.currentLevelData())

    selectNextLevel = ->
      levelPicker.selectNext()
      levelDetailsViewer.setLevelData(levelPicker.currentLevelData())

    @_hciSet = @_hci.on(
      [ "keyDown:#{FW.HCI.KeyMap.ENTER}", -> game.beginLevel(levelPicker.currentLevelData(), profileName, profileData) ]
      [ "keyDown:#{FW.HCI.KeyMap.ESCAPE}", -> sceneManager.popScene() ]
      [ "keyDown:#{FW.HCI.KeyMap.LEFT}",  selectPreviousLevel ]
      [ "keyDown:#{FW.HCI.KeyMap.RIGHT}", selectNextLevel ]
    )

    levelDetailsViewer.setLevelData(levelPicker.currentLevelData())

  onLeaveScene: ->
    @_hciSet.off()

  setProfileData: (profileName, profileData) ->
    profileData.lastLoadedAt = FW.Time.now()
    @_profile                = [ profileName, profileData ]
    titleBox                 = @_titleBox
    levelDetailsViewer       = @_levelDetailsViewer
    hci                      = @_hci

    titleBox.setTitle(profileName)
    levelDetailsViewer.setProfileData(profileData)
    hci.saveProfile(profileName, profileData)

  onTick: ->
    stage = @getStage()
    if stage
      canvas = stage.canvas
      levelDetailsViewer = @_levelDetailsViewer
      levelDetailsViewer.x = canvas.width / 2
      levelDetailsViewer.y = canvas.height / 3 + canvas.height / 2

setupLevelPicker = (screen, levels, hci) ->
  initialLevelIndex = 0
  levelPicker = new LevelPicker(levels, initialLevelIndex)

  levelPicker.addEventListener "tick", ->
    levelsVisibleOnScreen = 3.5

    canvas = screen.getStage().canvas
    levelPicker.scaleX = canvas.width / levelsVisibleOnScreen
    levelPicker.scaleY = levelPicker.scaleX

    levelPicker.x = canvas.width / 2
    levelPicker.y = canvas.height / 3

  levelPicker

setupLevelDetailsViewer = (screen) ->
  new LevelDetailsViewer()

