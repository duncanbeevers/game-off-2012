createjs = @createjs
$ ->
  stage = new createjs.Stage(document.getElementById("gameCanvas"))
  $.getJSON("levels/level1.json").done (data) ->
    level = new Level(data)
    stage.addChild(level)

    updater =
      tick: ->
        level.tick()
        stage.update()

    Ticker.addListener updater
