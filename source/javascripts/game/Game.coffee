BASE_BGM_VOLUME = 0.2

class @Game
  constructor: (canvas, data) ->
    createjs.Ticker.setFPS(30)

    @playBgm()

    stage = new createjs.Stage(canvas)

    level = new Level(data)
    stage.addChild(level)

    updater = tick: -> stage.update()

    createjs.Ticker.addListener(updater)

  pause: () ->
    @_bgm.pause()
    createjs.Ticker.setPaused(true)

  unpause: () ->
    @_bgm.resume()
    createjs.Ticker.setPaused(false)

  playBgm: () ->
    tracks = [
      "sounds/BGM1.mp3"
      "sounds/BGM2.mp3"
      "sounds/BGM3.mp3"
      "sounds/BGM4.mp3"
    ]

    game = @

    bgm = null
    play = () ->
      track = FW.Math.sample(tracks)
      bgm?.stop()
      bgm = createjs.SoundJS.play(track, createjs.SoundJS.INTERRUPT_NONE, 0, 0, 0, BASE_BGM_VOLUME, 0)
      bgm.onComplete ||= -> play()

      game._bgm = bgm

    play()
