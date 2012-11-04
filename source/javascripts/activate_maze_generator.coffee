createjs = @createjs

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
  mazeContainer = new createjs.Shape()
  mazeGraphics = mazeContainer.graphics
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
    drawSegments("#fff", segments)

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

  generateMaze = (type, options) ->
    resetBoundaries()
    mazeGraphics.clear()

    status = "Generating"
    disable = true

    # Define maze options common to all mazes
    mazeOptions = $.extend {}, options || {},
      draw: (segments) -> drawSegments("#0f0", segments)
      done: onMazeAvailable


    switch type
      when "GraphPaper"
        $.extend mazeOptions, Maze.Structures.GraphPaper,
          project: new Maze.Projections.GraphPaper()

      when "Hexagon"
        size = Math.floor((mazeOptions.size + 1) / 2) * 2
        $.extend mazeOptions, Maze.Structures.FoldedHexagon,
          project: new Maze.Projections.FoldedHexagonCell()
          width: size
          height: size

      else
        status = "Unknown maze type: #{type}"
        disable = false

    updateStatus(status, disable)
    if disable
      maze = Maze.createInteractive(mazeOptions)


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
      options[$input.attr("name")] = + $input.val()

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
