createjs = @createjs
$ ->
  stage = new createjs.Stage(document.getElementById("gameCanvas"))
  halfCanvasWidth = stage.canvas.width / 2
  halfCanvasHeight = stage.canvas.height / 2

  level = new createjs.Container()
  level.regX = -halfCanvasWidth
  level.regY = -halfCanvasHeight

  stage.addChild(level)

  player = new Player()

  level.addChild(player)

  updater =
    tick: ->
      player.tick()
      stage.update()

  Ticker.addListener updater
