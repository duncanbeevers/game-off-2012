createjs = @createjs
$ ->
  stage = new createjs.Stage(document.getElementById("gameCanvas"))
  level = new Level()

  stage.addChild(level)

  updater =
    tick: ->
      level.tick()
      stage.update()

  Ticker.addListener updater
