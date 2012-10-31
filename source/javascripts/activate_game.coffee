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
    onResize()
    $canvas.show()
    $("#loading").hide()

    game = new Game($canvas[0], preloader)
    window.game = game

  preloader = new Preloader(onPreloadComplete)
