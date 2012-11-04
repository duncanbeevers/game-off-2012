createjs = @createjs
pixelsPerMeter = 25

$ ->
  maze = null

  $("#serialize").on "click", ->
    $("#serialized").text(JSON.stringify(maze.serialize()))

  $("#generate").on "click", ->
    type = $("#type").val()
    generateMaze(type)

  updateStatus = (status) ->
    $("#status_text").text(status)

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
    updateStatus("Joining segments")
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

    # Define maze options common to all mazes
    mazeOptions = $.extend {}, options || {},
      draw: (segments) ->
        FW.CreateJS.drawSegments(mazeGraphics, "#0f0", segments)
      done: onMazeAvailable


    switch type
      when "GraphPaper"
        $.extend mazeOptions, Maze.Structures.GraphPaper,
          project: new Maze.Projections.GraphPaper()
          width: 6
          height: 6

      when "Hexagon"
        $.extend mazeOptions, Maze.Structures.FoldedHexagon,
          project: new Maze.Projections.FoldedHexagonCell()
          width: 16
          height: 16

      else
        status = "Unknown maze type: #{type}"

    updateStatus(status)
    maze = Maze.createInteractive(mazeOptions)

  updateStatus("Ready")
  # stage.addChild(level)

  updater =
    tick: ->
      stage.update()

  createjs.Ticker.addListener updater
