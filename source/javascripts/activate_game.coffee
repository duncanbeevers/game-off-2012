createjs = @createjs
$ ->
  $canvas = $("#gameCanvas")
  $window = $(window)

  onResize = ->
    $canvas.attr(width: $window.width(), height: $window.height())

  $(window).on "resize", onResize

  game = null
  onVisibilityChange = (event) ->
    documentHidden = document.hidden || document.webkitHidden

    if documentHidden
      game?.pause()
    else
      game?.unpause()

  $(document).on "visibilitychange", onVisibilityChange
  $(document).on "webkitvisibilitychange", onVisibilityChange

  onPreloadComplete = ->
    # TODO: Integrate this with preloader, make LevelLoader
    $.getJSON("levels/level3.json").done (data) ->

      onResize()
      $canvas.show()
      $("#loading").hide()

      game = new Game($canvas[0], data)
      window.game = game


  preloader = new Preloader(onPreloadComplete)
