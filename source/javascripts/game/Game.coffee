BASE_BGM_VOLUME = 0.2

class @Game
  constructor: (canvas, preloader, hci) ->
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

    data = JSON.parse(preloader.getResult("levels/crackedice.json").result)
    # data = FW.Math.sample(preloader.getLevels())
    level = new Level(@, data)

    beginBacktrack = ->
      level.beginBacktrack()

    endBacktrack = ->
      level.endBacktrack()

    togglePause = ->
      level.togglePause()


    hci.on "key:#{FW.HCI.KeyMap.SPACE}", beginBacktrack, endBacktrack
    # keymap.subscribe FW.Input.KeyMap.P, togglePause
    hci.on "key:#{FW.HCI.KeyMap.LEFT}", ->
      @trigger("levelPickerFocusOnPreviousLevel")
    hci.on "key:#{FW.HCI.KeyMap.RIGHT}", ->
      @trigger("levelPickerFocusOnNextLevel")

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