class @Level
  constructor: ->
    container = new createjs.Container()

    parent = undefined
    Object.defineProperty @, 'parent'
      get: ->
        parent
      set: (value) ->
        if parent
          parent.removeChild(container)
        parent = value
        if parent
          parent.addChild(container)

    FW.ProxyProperties(@, container, [ 'regX', 'regY' ])

    @_container = container

  addChild: (child) ->
    @_container.addChild(child)

  removeChild: (child) ->
    @_container.removeChild(child)

  isVisible: ->
    @_container.isVisible()

  updateContext: (context) ->

  draw: (context) ->

  tick: ->


  # joinSegments = (segments) ->
  #   joiner = new Maze.SegmentJoiner segments

  #   draw = (segments) ->
  #     mazeGraphics.clear()
  #     scaler.speed = 1
  #     scaler.updateFreq = 1
  #     drawSegments segments, 0, (next) ->
  #       setTimeout next, 20

  #   solveAndDraw = ->
  #     collectedSegments = joiner.solve(draw)

  #   setTimeout solveAndDraw

  # drawSegments = (segments, i, next) ->
  #   segment = segments[i]

  #   [x1, y1, x2, y2] = segment

  #   solutionGraphics.setStrokeStyle(0.05, "square", "bevel")
  #   solutionGraphics.beginStroke("rgba(0, 64, 192, 1)")
  #   solutionGraphics.moveTo(x1, y1)
  #   solutionGraphics.lineTo(x2, y2)
  #   solutionGraphics.endStroke()
  #   stage.update()

  #   if i < segments.length - 1
  #     next ->
  #       drawSegments(segments, i + 1, next)

  # options = $.extend {}, Maze.Structures.FoldedHexagon,
  #   project: new Maze.Projections.FoldedHexagonCell()

  #   draw: (segments) ->
  #     mazeGraphics.setStrokeStyle(0.35, "round", "bevel")
  #     mazeGraphics.beginStroke("rgba(0, 192, 192, 1)")

  #     for [x1, y1, x2, y2] in segments
  #       minX = Math.min(minX, x1, x2)
  #       minY = Math.min(minY, y1, y1)
  #       maxX = Math.max(maxX, x1, x2)
  #       maxY = Math.max(maxY, y1, y1)
  #       mazeGraphics.moveTo(x1, y1)
  #       mazeGraphics.lineTo(x2, y2)

  #     stage.update()
  #   done: (maze) ->
  #     joinSegments(maze.projectedSegments)

  #   width: 6
  #   height: 6

  # window.maze = Maze.createInteractive(options)
