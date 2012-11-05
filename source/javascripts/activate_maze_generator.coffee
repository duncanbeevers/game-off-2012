createjs = @createjs
# gui = new dat.GUI()

$ ->
  maze = null
  $type = $("#type")

  onTypeChange = ->
    type = $type.val()
    $(".config:not(.#{type})").hide()
    $(".config.#{type}").show()

  updateStatus = (status, disable) ->
    $("#status_text").text(status)
    $("button,select").attr("disabled", !!disable)

  updateInfo = (maze) ->
    if maze.terminations
      info =
        terminations: maze.terminations.length
        maxLength: maze.maxTermination[1]
      text = JSON.stringify(info)
    else
      text = ""

    $("#info").text(text)

  $canvas = $("#generatorCanvas")
  $canvas.attr(width: "500", height: "500")
  stage = new createjs.Stage($canvas[0])
  mazeContainer = new createjs.Container()

  mazeShape = new createjs.Shape()
  mazeGraphics = mazeShape.graphics

  mazeContainer.addChild(mazeShape)
  stage.addChild(mazeContainer)

  canvasWidth = stage.canvas.width
  canvasHeight = stage.canvas.height
  halfCanvasWidth = canvasWidth / 2
  halfCanvasHeight = canvasHeight / 2

  mazeContainer.x = halfCanvasWidth
  mazeContainer.y = halfCanvasHeight

  onMazeAvailable = (maze) ->
    updateStatus("Ready")
    updateInfo(maze)

  onSegmentsJoined = (segments) ->
    updateStatus("Ready")
    maze.joinedSegments = segments

    mazeGraphics.clear()
    drawSegments("rgba(73, 21, 172, 0.5)", segments)

  minX = null
  maxX = null
  minY = null
  maxY = null
  targetScale = null
  resetBoundaries = ->
    minX = Infinity
    maxX = -Infinity
    minY = Infinity
    maxY = -Infinity
    targetScale = 1

  drawSegments = (color, segments) ->
    canvas = mazeContainer.getStage().canvas
    canvasWidth = canvas.width
    canvasHeight = canvas.height
    canvasSize = Math.min(canvasWidth, canvasHeight)
    canvasSize -= canvasSize / 15

    [_minX, _minY, _maxX, _maxY] = FW.CreateJS.drawSegments(mazeGraphics, color, segments)
    minX = Math.min(minX, _minX)
    maxX = Math.max(maxX, _maxX)
    minY = Math.min(minY, _minY)
    maxY = Math.max(maxY, _maxY)
    targetScale = canvasSize / Math.max(maxX * 2, -minX * 2, maxY * 2, -minY * 2, maxX - minX, maxY - minY)

  substrateContainer = null
  generateMaze = (type, options) ->
    resetBoundaries()
    mazeGraphics.clear()

    status = "Generating"
    disable = true

    # Define maze options common to all mazes
    mazeOptions = $.extend {}, options || {},
      draw: (segments) -> drawSegments("rgba(33, 153, 255, 0.5)", segments)
      done: onMazeAvailable

    next = -> maze = Maze.createInteractive(mazeOptions)

    switch type
      when "GraphPaper"
        $.extend mazeOptions, Maze.Structures.GraphPaper,
          projection: new Maze.Projections.GraphPaper()

      when "Hexagon"
        size = Math.floor((mazeOptions.size + 1) / 2) * 2
        $.extend mazeOptions, Maze.Structures.FoldedHexagon,
          projection: new Maze.Projections.FoldedHexagonCell()
          width: size
          height: size

      when "Substrate"
        $.extend mazeOptions, Maze.Structures.Substrate,
          projection: new Maze.Projections.GraphPaper()

        createMaze = next
        imageUrl = mazeOptions.imageUrl

        if !substrateContainer
          substrateContainer = new createjs.Container()
          mazeContainer.addChildAt(substrateContainer, 0)

        next = ->
          preloader = new createjs.PreloadJS()
          preloader.onComplete = ->
            bitmap = new createjs.Bitmap(imageUrl)
            bitmap.regX = bitmap.image.width / 2
            bitmap.regY = bitmap.image.height / 2
            bitmap.scaleX = 1 / mazeOptions.substratePixelsPerMeter
            bitmap.scaleY = bitmap.scaleX

            mazeOptions.substrateBitmap = bitmap
            substrateContainer.removeAllChildren()
            substrateContainer.addChild(bitmap)
            createMaze()

          preloader.loadManifest([ imageUrl ])

      else
        status = "Unknown maze type: #{type}"
        disable = false

    updateStatus(status, disable)
    if disable
      next()


  # Register event handlers
  $("#serialize").on "click", ->
    $("#serialized").text(JSON.stringify(maze.serialize()))

  $type.on "change", onTypeChange

  $("#generate").on "click", ->
    options = {}

    type = $type.val()
    inputs = $(".config.#{type} input")
    for input in inputs
      $input = $(input)
      val = $input.val()
      if $input.attr("type") == "number"
        val = +val

      options[$input.attr("name")] = val

    generateMaze(type, options)

  $("#optimize").on "click", ->
    if maze.projectedSegments
      updateStatus("Joining segments", true)
      joiner = new Maze.SegmentJoiner(maze.projectedSegments)
      joiner.solve(onSegmentsJoined)
    else
      updateStatus("No maze generated")

  # Set up initial state
  updateStatus("Ready", false)
  onTypeChange()

  createjs.Ticker.addListener tick: ->
    mazeContainer.scaleX += (targetScale - mazeContainer.scaleX) / 10
    mazeContainer.scaleY = mazeContainer.scaleX
    stage.update()
