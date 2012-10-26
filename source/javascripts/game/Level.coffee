class @Level extends FW.ContainerProxy
  constructor: ->
    super()

    @setupPhysics()
    @setupMaze()

  setupPhysics: ->
    @world = new Box2D.Dynamics.b2World(
      # new Box2D.Common.Math.b2Vec2(0, 0),  # gravity
      new Box2D.Common.Math.b2Vec2(0, 10),  # gravity
      true                                  # allow sleep
    )

  setupMaze: ->
    mazeShape = new createjs.Shape()
    mazeGraphics = mazeShape.graphics
    @addChild(mazeShape)

    world = @world

    joinMazeSegments = (maze) ->
      segments = maze.projectedSegments
      joiner = new Maze.SegmentJoiner(segments)
      joiner.solve(craftWalls)

    craftWalls = (segments) ->
      fixtureDef = new Box2D.Dynamics.b2FixtureDef
      fixtureDef.density     = 1
      fixtureDef.friction    = 0.5
      fixtureDef.restitution = 0.2

      bodyDef = new Box2D.Dynamics.b2BodyDef()

      bodyDef.type = Box2D.Dynamics.b2Body.b2_staticBody
      fixtureDef.shape = new Box2D.Collision.Shapes.b2PolygonShape()
      passageSize = 15
      wallThickness = 0.2
      for [x1, y1, x2, y2] in segments
        x1 = x1 * passageSize
        y1 = y1 * passageSize
        x2 = x2 * passageSize
        y2 = y2 * passageSize
        length = Math.sqrt(Math.pow(x2 - x1, 2) + Math.pow(y2 - y1, 2))
        fixtureDef.shape.SetAsBox(length / 2, wallThickness)
        bodyDef.position.Set((x2 - x1) / 2 + x1, (y2 - y1) / 2 + y1)
        bodyDef.angle = Math.atan2(y2 - y1, x2 - x1)
        world.CreateBody(bodyDef).CreateFixture(fixtureDef)

    options = $.extend {}, Maze.Structures.FoldedHexagon,
      project: new Maze.Projections.FoldedHexagonCell()
      done:    joinMazeSegments

    @maze = Maze.createInteractive(options)


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



  #   width: 6
  #   height: 6

  # window.maze = Maze.createInteractive(options)

# drawSegments = (graphics, segments) ->
#   graphics.setStrokeStyle(0.35, "round", "bevel")
#   graphics.beginStroke("rgba(0, 192, 192, 1)")

#   for [x1, y1, x2, y2] in segments
#     graphics.moveTo(x1, y1)
#     graphics.lineTo(x2, y2)
