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

    titleScreen = new TitleScreen(@, hci)
    sceneManager.addScene("titleScreen", titleScreen)
    sceneManager.gotoScene("titleScreen")

    # data = JSON.parse(preloader.getResult("levels/crackedice.json").result)
    # data = FW.Math.sample(preloader.getLevels())
    # level = new Level(@, data)
    # stage.addChild(level)
    @_sceneManager = sceneManager

    # TODO: Hook up pause
    # togglePause = ->
    #   level.togglePause()

    # Maybe don't need this?
    updater = tick: -> stage.update()
    createjs.Ticker.addListener(updater)

    @_hci = hci

  beginLevel: (levelData) ->
    sceneManager = @_sceneManager

    level = new Level(@, @_hci, levelData)

    sceneManager.addScene("level", level)
    sceneManager.gotoScene("level")

  pause: () ->
    @_bgm.pause()
    createjs.Ticker.setPaused(true)

  unpause: () ->
    @_bgm.resume()
    createjs.Ticker.setPaused(false)

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

  getPreloader: ->
    @_preloader
