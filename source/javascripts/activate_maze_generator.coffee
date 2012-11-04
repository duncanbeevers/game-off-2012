createjs = @createjs
pixelsPerMeter = 25

$ ->
  maze = null
  $type = $("#type")

  onTypeChange = ->
    type = $type.val()
    $(".config:not(.#{type})").hide()
    $(".config.#{type}").show()

  updateStatus = (status, disable) ->
    $("#status_text").text(status)
    $("button,select").attr("disabled", disable || false)

  updateInfo = (maze) ->
    info =
      terminations: maze.terminations.length
      maxLength: maze.maxTermination[1]
    $("#info").text(JSON.stringify(info))

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
  mazeContainer.scaleX = pixelsPerMeter
  mazeContainer.scaleY = mazeContainer.scaleX

  onMazeAvailable = (maze) ->
    updateStatus("Joining segments", true)
    updateInfo(maze)
    joiner = new Maze.SegmentJoiner(maze.projectedSegments)
    joiner.solve(onSegmentsJoined)

  onSegmentsJoined = (segments) ->
    updateStatus("Ready")
    maze.joinedSegments = segments
    mazeGraphics.clear()
    FW.CreateJS.drawSegments(mazeGraphics, "#fff", segments)

  generateMaze = (type, options) ->
    mazeGraphics.clear()
    status = "Generating"
    disable = true

    # Define maze options common to all mazes
    mazeOptions = $.extend {}, options || {},
      draw: (segments) ->
        FW.CreateJS.drawSegments(mazeGraphics, "#0f0", segments)
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

  # Set up initial state
  updateStatus("Ready", false)
  onTypeChange()

  createjs.Ticker.addListener tick: -> stage.update()
