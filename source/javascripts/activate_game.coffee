createjs = @createjs
$ ->
  $canvas = $("#gameCanvas")
  $window = $(window)

  onResize = ->
    $canvas.attr(width: $window.width(), height: $window.height())

  $(window).on "resize", onResize
  onResize()

  stage = new createjs.Stage($canvas[0])
  $.getJSON("levels/level1.json").done (data) ->
    Ticker.setFPS(30)

    level = new Level(data)
    stage.addChild(level)

    updater =
      tick: ->
        stage.update()

    Ticker.addListener updater
