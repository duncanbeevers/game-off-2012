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

  $progress = $("#progress")
  onPreloadProgress = (event) ->
    numChars = 6
    filled = Math.ceil((numChars / event.total) * event.loaded)
    text = (new Array(filled + 1).join("=")) + (new Array(numChars - filled + 1).join("-"))
    $progress.text(text)

  onPreloadComplete = ->
    preloader.hydrateLevels()

    $progress.hide()

    onResize()
    $("#loading").hide()

    game = new Game($canvas[0], preloader)
    window.game = game

  preloader = new Preloader(onPreloadProgress, onPreloadComplete)
