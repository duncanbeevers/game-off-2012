class @Game
  constructor: (canvas, data) ->
    Ticker.setFPS(30)

    @_bgm = createjs.SoundJS.play("sounds/BGM1.mp3", createjs.SoundJS.INTERRUPT_NONE, 0, 0, -1, 0.2, 0)

    stage = new createjs.Stage(canvas)

    level = new Level(data)
    stage.addChild(level)

    updater = tick: -> stage.update()

    Ticker.addListener(updater)

  pause: () ->
    createjs.Ticker.setPaused(true)
    @_bgm.pause()

  unpause: () ->
    createjs.Ticker.setPaused(false)
    @_bgm.resume()
