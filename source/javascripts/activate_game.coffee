createjs = @createjs
$ ->
  $canvas = $("#gameCanvas")
  $window = $(window)

  onResize = ->
    $("canvas").
      attr(width: $window.width(), height: $window.height()).
      css(left: 0, top: 0, position: 'absolute')

  $(window).on "resize", onResize

  game = null

  hci = $.FW_HCI()
  hci.on "windowBecameVisible", ->
    game?.unpause()

  hci.on "windowBecamseInvisible", ->
    game?.pause()

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

    game = new Game($canvas[0], preloader, hci)

    window.game = game

  preloader = new Preloader(onPreloadProgress, onPreloadComplete)
