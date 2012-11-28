BASE_BGM_VOLUME = 0.2

class @Game
  constructor: (canvas, preloader, hci) ->
    createjs.Ticker.useRAF = true
    createjs.Ticker.setFPS(30)
    @_preloader = preloader

    @playBgm([
      "sounds/BGM1.mp3"
      "sounds/BGM2.mp3"
      "sounds/BGM3.mp3"
      "sounds/BGM4.mp3"
    ])

    stage = new createjs.Stage(canvas)
    sceneManager = new SceneManager(stage)

    @_hci = hci
    # Declare this early since its accessed by getSceneManager
    @_sceneManager = sceneManager

    profilePickerScreen = new ProfilePickerScreen(@, hci)
    titleScreen = new TitleScreen(@, hci)

    sceneManager.addScene("profilePickerScreen", profilePickerScreen)
    sceneManager.addScene("titleScreen", titleScreen)

    sceneManager.gotoScene("profilePickerScreen")

    @_titleScreen = titleScreen

    updater = tick: -> stage.update()
    createjs.Ticker.addListener(updater)

  beginLevel: (levelData, profileName, profileData) ->
    sceneManager = @_sceneManager
    hci = @_hci

    level = new Level @, hci, levelData, (completionTime, wallImpactsCount) ->
      profileLevelsData = profileData.levels ||= {}
      profileLevelData = profileLevelsData[levelData.name] ||= {}
      profileLevelData.lastCompletionTime = completionTime
      previousBestCompletionTime = profileLevelData.bestCompletionTime || Infinity
      profileLevelData.bestCompletionTime = Math.min(previousBestCompletionTime, completionTime)

      profileLevelData.lastWallImpactsCount = wallImpactsCount
      previousBestWallImpactsCount = profileLevelData.bestWallImpactsCount || Infinity
      profileLevelData.bestWallImpactsCount = Math.min(previousBestWallImpactsCount, wallImpactsCount)

      hci.saveProfile(profileName, profileData)

    sceneManager.addScene("level", level)
    sceneManager.pushScene("level")

  pause: () ->
    @_bgm.pause()
    createjs.Ticker.setPaused(true)

  unpause: () ->
    @_bgm.resume()
    createjs.Ticker.setPaused(false)

  setProfileData: (profileName, profileData) ->
    titleScreen = @_titleScreen
    titleScreen.setProfileData(profileName, profileData)

  returnToTitleScreen: ->
    @_sceneManager.gotoScene("titleScreen")

  setBgmTracks: (tracks) ->
    @_bgmTracks = tracks

  playBgm: (tracks) ->
    game = @
    bgm = game._bgm
    if tracks
      game._bgmTracks = tracks

    track = FW.Math.sample(game._bgmTracks)
    bgm?.stop()
    newBgm = createjs.SoundJS.play(track, createjs.SoundJS.INTERRUPT_NONE, 0, 0, 0, BASE_BGM_VOLUME, 0)
    if newBgm != bgm
      newBgm.onComplete = -> game.playBgm()

    game._bgm = newBgm

  getSceneManager: ->
    @_sceneManager

  getPreloader: ->
    @_preloader
