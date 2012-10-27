createjs = @createjs
$ ->
  stage = new createjs.Stage(document.getElementById("gameCanvas"))
  level = new Level()

  stage.addChild(level)

  player = new Player()
  level.addChild(player)

  updater =
    tick: ->
      level.tick()
      player.tick()
      stage.update()

  Ticker.addListener updater
