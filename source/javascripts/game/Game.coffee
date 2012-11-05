BASE_BGM_VOLUME = 0.2

class @Game
  constructor: (canvas, preloader, keymap) ->
    createjs.Ticker.setFPS(30)
    @_preloader = preloader

    @playBgm([
      "sounds/BGM1.mp3"
      "sounds/BGM2.mp3"
      "sounds/BGM3.mp3"
      "sounds/BGM4.mp3"
    ])

    stage = new createjs.Stage(canvas)

    # titleScreen = new TitleScreen(@)
    # stage.addChild(titleScreen)

    data = JSON.parse(preloader.getResult("levels/level2.json").result)
    level = new Level(@, data)

    keymap.subscribe FW.Input.KeyMap.SPACE, ->
      level.releasePups()

    stage.addChild(level)

    updater = tick: -> stage.update()

    createjs.Ticker.addListener(updater)

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