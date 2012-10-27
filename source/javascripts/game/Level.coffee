pixelsPerMeter = 120

class @Level extends FW.ContainerProxy
  constructor: ->
    super()

    @_container.scaleX = pixelsPerMeter
    @_container.scaleY = @_container.scaleX
    @setupPhysics()
    @setupMaze()

  setupPhysics: ->
    world = new Box2D.Dynamics.b2World(
      # new Box2D.Common.Math.b2Vec2(0, 0),  # gravity
      new Box2D.Common.Math.b2Vec2(0, 10),  # gravity
      true                                  # allow sleep
    )
    @world = world

    # TODO: Remove debug canvas stuff
    debugCanvas = document.getElementById("debugCanvas")
    debugContext = debugCanvas.getContext("2d")
    b2DebugDraw = Box2D.Dynamics.b2DebugDraw
    debugDraw = new b2DebugDraw()
    debugDraw.SetSprite(debugContext)
    debugDraw.SetFillAlpha(0.7)
    debugDraw.SetLineThickness(1.0)
    debugDraw.SetFlags(
      b2DebugDraw.e_shapeBit        |
      b2DebugDraw.e_jointBit        |
      b2DebugDraw.e_aabbBit         |
      b2DebugDraw.e_centerOfMassBit |
      b2DebugDraw.e_coreShapeBit    |
      b2DebugDraw.e_jointBit        |
      b2DebugDraw.e_obbBit          |
      b2DebugDraw.e_pairBit
    )
    debugDraw.SetDrawScale(1)
    world.SetDebugDraw(debugDraw)


  addChild: (player) ->
    super(player)
    @player = player

  setupMaze: ->
    mazeShape = new createjs.Shape()
    mazeGraphics = mazeShape.graphics

    @_container.addChild(mazeShape)

    world = @world
    level = @
    getPlayer = (fn) ->
      # TODO: Deal with this race condition,
      fn(level.player)

    onMazeGenerated = (maze) ->
      joinSegments(maze.projectedSegments)
      positionPlayerAtBeginning(maze)
      level.mazeGenerated = true

    joinSegments = (segments) ->
      joiner = new Maze.SegmentJoiner(segments)
      joiner.solve(onSegmentsJoined)

    positionPlayer = (maze, player) ->
      walls = maze.project.call(maze, maze.initialIndex(), true)
      [x, y] = FW.Math.centroidOfSegments(walls)
      player.x = x
      player.y = y

      # Create physics entity
    createPhysicsPlayer = (player) ->
      fixtureDef = new Box2D.Dynamics.b2FixtureDef()
      fixtureDef.density = 1
      fixtureDef.friction = 0.6
      fixtureDef.restitution = 0.1
      fixtureDef.shape = new Box2D.Collision.Shapes.b2CircleShape(0.3)
      bodyDef = new Box2D.Dynamics.b2BodyDef()
      bodyDef.type = Box2D.Dynamics.b2Body.b2_dynamicBody
      bodyDef.position.x = player.x
      bodyDef.position.y = player.y
      player.fixture = world.CreateBody(bodyDef).CreateFixture(fixtureDef)

    positionPlayerAtBeginning = (maze) ->
      getPlayer (player) ->
        positionPlayer(maze, player)
        createPhysicsPlayer(player)

    onSegmentsJoined = (segments) ->
      craftPhysicsWalls(segments)
      @walls = segments

    craftPhysicsWalls = (segments) ->
      fixtureDef = new Box2D.Dynamics.b2FixtureDef
      fixtureDef.density     = 1
      fixtureDef.friction    = 0.5
      fixtureDef.restitution = 0.2

      bodyDef = new Box2D.Dynamics.b2BodyDef()

      bodyDef.type = Box2D.Dynamics.b2Body.b2_staticBody
      fixtureDef.shape = new Box2D.Collision.Shapes.b2PolygonShape()
      passageSize = 1
      wallThickness = passageSize / 10
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
      draw: (segments) ->
        drawSegments(mazeGraphics, segments)
      done: onMazeGenerated

    @maze = Maze.createInteractive(options)

  tick: ->
    @_container.regX = @player.x
    @_container.regY = @player.y
    @_container.x = 250
    @_container.y = 200

    if @mazeGenerated
      @world.Step(1 / 10, 10, 10)

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
      # Update player graphic to follow physics entity
      if @player.fixture
        player = @player
        position = player.fixture.GetBody().GetPosition()
        # console.log "graphic: %o,%o body: %o,%o", player.x, player.y, position.x, position.y
        # player.x = position.x
        # player.y = position.y

drawSegments = (graphics, segments) ->
  graphics.setStrokeStyle(0.35, "round", "bevel")
  graphics.beginStroke("rgba(0, 192, 192, 1)")

  for [x1, y1, x2, y2] in segments
    graphics.moveTo(x1, y1)
    graphics.lineTo(x2, y2)
