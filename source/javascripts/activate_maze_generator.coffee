createjs = @createjs
pixelsPerMeter = 25

$ ->
  maze = null

  $("#serialize").on "click", ->
    $("#serialized").text(JSON.stringify(maze.serialize()))

  $("#generate").on "click", ->
    generateMaze()

  updateStatus = (status) ->
    $("#status_text").text(status)

  stage = new createjs.Stage(document.getElementById("gameCanvas"))
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
    joiner = new Maze.SegmentJoiner(maze.projectedSegments)
    joiner.solve(onSegmentsJoined)

  onSegmentsJoined = (segments) ->
    updateStatus("Ready")
    maze.joinedSegments = segments
    mazeGraphics.clear()
    FW.CreateJS.drawSegments(mazeGraphics, segments)

  options = $.extend {}, Maze.Structures.FoldedHexagon,
    project: new Maze.Projections.FoldedHexagonCell()
    draw: (segments) ->
      FW.CreateJS.drawSegments(mazeGraphics, segments)
    width: 14
    height: 14
    done: onMazeAvailable

  generateMaze = ->
    updateStatus("Generating")
    mazeGraphics.clear()
    maze = Maze.createInteractive(options)

  updateStatus("Ready")
  # stage.addChild(level)

  updater =
    tick: ->
      stage.update()

  Ticker.addListener updater
