createjs = @createjs
$ ->
  $canvas = $("#gameCanvas")
  $window = $(window)

  onResize = ->
    $canvas.attr(width: $window.width(), height: $window.height())

  $(window).on "resize", onResize
  onResize()

  onPreloadComplete = ->
    stage = new createjs.Stage($canvas[0])

    $.getJSON("levels/level3.json").done (data) ->
      Ticker.setFPS(30)

      level = new Level(data)
      stage.addChild(level)

      updater =
        tick: ->
          stage.update()

      Ticker.addListener updater

      $canvas.show()
      $("#loading").hide()

  preloader = new Preloader(onPreloadComplete)
  # onPreloadComplete()