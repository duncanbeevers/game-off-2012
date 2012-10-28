pixelsPerMeter = 120

class @Level extends FW.ContainerProxy
  constructor: ->
    super()

    @_container.scaleX = pixelsPerMeter
    @_container.scaleY = @_container.scaleX
    @setupPhysics()
    @setupMaze()

  setupPhysics: ->
    b2DebugDraw = Box2D.Dynamics.b2DebugDraw
    world = new Box2D.Dynamics.b2World(
      new Box2D.Common.Math.b2Vec2(0, 0), # no gravity
      true                                # allow sleep
    )
    @world = world

    # TODO: Remove debug canvas stuff
    debugCanvas = document.getElementById("debugCanvas")
    debugContext = debugCanvas.getContext("2d")
    debugDraw = new b2DebugDraw()
    @debugDraw = debugDraw
    debugDraw.SetSprite(debugContext)
    debugDraw.SetFillAlpha(1)
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
    debugDraw.SetDrawScale(pixelsPerMeter)
    world.SetDebugDraw(debugDraw)

  onAddedAsChild: (parent) ->
    @harness = FW.MouseHarness.outfit(parent.getStage())

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
      # fixtureDef.shape = new Box2D.Collision.Shapes.b2CircleShape(50)
      fixtureDef.shape = new Box2D.Collision.Shapes.b2CircleShape(0.25)
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
      level.walls = segments
      level.mazeGenerated = true


    craftPhysicsWalls = (segments) ->
      fixtureDef = new Box2D.Dynamics.b2FixtureDef
      fixtureDef.density     = 1
      fixtureDef.friction    = 0.5
      fixtureDef.restitution = 0.2

      bodyDef = new Box2D.Dynamics.b2BodyDef()

      bodyDef.type = Box2D.Dynamics.b2Body.b2_staticBody
      fixtureDef.shape = new Box2D.Collision.Shapes.b2PolygonShape()
      wallThickness = 0.1
      for [x1, y1, x2, y2] in segments
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
    harness = @harness()
    @_container.regX = @player.x
    @_container.regY = @player.y
    @_container.x = 250
    @_container.y = 200

    if @mazeGenerated
      @world.Step(1 / 20, 10, 10)

      # Update player graphic to follow physics entity
      if @player.fixture
        player = @player
        canvas = @_container.getStage().canvas
        xOffset = canvas.width / 2 / pixelsPerMeter - player.x
        yOffset = canvas.height / 2 / pixelsPerMeter - player.y
        @debugDraw.SetDrawTranslate(new Box2D.Common.Math.b2Vec2(xOffset, yOffset))
        body = player.fixture.GetBody()
        position = body.GetPosition()
        angle = body.GetAngle()

        player.x = position.x
        player.y = position.y
        @_container.rotation = angle * FW.Math.RAD_TO_DEG

      @world.DrawDebugData()

drawSegments = (graphics, segments) ->
  graphics.setStrokeStyle(0.35, "round", "bevel")
  graphics.beginStroke("rgba(0, 192, 192, 1)")

  for [x1, y1, x2, y2] in segments
    graphics.moveTo(x1, y1)
    graphics.lineTo(x2, y2)
