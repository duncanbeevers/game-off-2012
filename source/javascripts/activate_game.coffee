createjs = @createjs
$ ->
  stage = new createjs.Stage(document.getElementById("gameCanvas"))
  $.getJSON("levels/level1.json").done (data) ->
    Ticker.setFPS(30)

    level = new Level(data)
    stage.addChild(level)

    updater =
      tick: ->
        stage.update()

    Ticker.addListener updater
