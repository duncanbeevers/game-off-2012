createjs = @createjs
$ ->
  stage = new createjs.Stage(document.getElementById("gameCanvas"))
  halfCanvasWidth = stage.canvas.width / 2
  halfCanvasHeight = stage.canvas.height / 2

  level = new Level()
  level.regX = -halfCanvasWidth
  level.regY = -halfCanvasHeight

  stage.addChild(level)

  player = new Player()

  level.addChild(player)

  updater =
    tick: ->
      level.tick()
      player.tick()
      stage.update()

  Ticker.addListener updater
