pixelsPerMeter = 120

class @Level extends FW.ContainerProxy
  constructor: ->
    super()

    goal = new Goal()
    @_container.addChild(goal)
    @_goal = goal

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
    @harness = FW.MouseHarness.outfit(@_container)

  addChild: (player) ->
    super(player)
    @player = player

  setupMaze: ->
    mazeShape = new createjs.Shape()
    mazeGraphics = mazeShape.graphics
    @mazeShape = mazeShape

    @_container.addChild(mazeShape)

    world = @world
    level = @
    getPlayer = (fn) ->
      # TODO: Deal with this race condition,
      fn(level.player)

    onMazeGenerated = (maze) ->
      joinSegments(maze.projectedSegments)
      positionPlayerAtBeginning(maze)
      positionGoalAtEnd(maze, level._goal)

    joinSegments = (segments) ->
      joiner = new Maze.SegmentJoiner(segments)
      joiner.solve(onSegmentsJoined)

    positionPlayer = (maze, player) ->
      walls = maze.project.call(maze, maze.initialIndex(), true)
      [x, y] = FW.Math.centroidOfSegments(walls)
      player.x = x
      player.y = y
      level._lastPlayerDot = new Box2D.Common.Math.b2Vec2(player.x, player.y)

    # Create physics entity
    createPhysicsPlayer = (player) ->
      fixtureDef = new Box2D.Dynamics.b2FixtureDef()
      fixtureDef.density = 1
      fixtureDef.friction = 0.1
      fixtureDef.restitution = 0.1
      fixtureDef.shape = new Box2D.Collision.Shapes.b2CircleShape(0.25)
      bodyDef = new Box2D.Dynamics.b2BodyDef()
      bodyDef.type = Box2D.Dynamics.b2Body.b2_dynamicBody
      bodyDef.position.x = player.x
      bodyDef.position.y = player.y
      player.fixture = world.CreateBody(bodyDef).CreateFixture(fixtureDef)

    createPhysicsGoal = (goal) ->
      fixtureDef = new Box2D.Dynamics.b2FixtureDef()
      fixtureDef.density = 1
      fixtureDef.friction = 0.6
      fixtureDef.restitution = 0.1
      fixtureDef.shape = new Box2D.Collision.Shapes.b2CircleShape(0.25)
      bodyDef = new Box2D.Dynamics.b2BodyDef()
      bodyDef.type = Box2D.Dynamics.b2Body.b2_dynamicBody
      bodyDef.position.x = goal.x
      bodyDef.position.y = goal.y
      goal.fixture = world.CreateBody(bodyDef).CreateFixture(fixtureDef)

    positionPlayerAtBeginning = (maze) ->
      getPlayer (player) ->
        positionPlayer(maze, player)
        createPhysicsPlayer(player)

    positionGoalAtEnd = (maze, goal) ->
      # maximumDistanceTermination = [ undefined, -Infinity ]
      # for [i, distance] in maze.terminations
      #   if distance > maximumDistanceTermination[1]
      #     maximumDistanceTermination[0] = i
      #     maximumDistanceTermination[1] = distance
      maximumDistanceTermination = maze.maxTermination

      endingIndex = maximumDistanceTermination[0]
      walls = maze.project.call(maze, endingIndex, true)
      [goal.x, goal.y] = FW.Math.centroidOfSegments(walls)
      createPhysicsGoal(goal)

    onSegmentsJoined = (segments) ->
      drawSegments(mazeGraphics, segments)

      craftPhysicsWalls(segments)
      level.walls = segments
      level.mazeGenerated = true


    craftPhysicsWalls = (segments) ->
      fixtureDef = new Box2D.Dynamics.b2FixtureDef
      fixtureDef.density     = 1
      fixtureDef.friction    = 0.1
      fixtureDef.restitution = 0.1

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
      width: 6
      height: 6
      done: onMazeGenerated

    @maze = Maze.createInteractive(options)

  tick: ->
    container = @_container
    harness = @harness()
    container.regX = @player.x
    container.regY = @player.y

    if @mazeGenerated
      @_goal.tick()
      @world.Step(1 / 20, 10, 10)

      # Update player graphic to follow physics entity
      if @player.fixture
        player = @player
        canvas = container.getStage().canvas
        halfWidth = canvas.width / 2
        halfHeight = canvas.height / 2
        xOffset = halfWidth / pixelsPerMeter - player.x
        yOffset = halfHeight / pixelsPerMeter - player.y
        @debugDraw.SetDrawTranslate(new Box2D.Common.Math.b2Vec2(xOffset, yOffset))
        body = player.fixture.GetBody()
        position = body.GetPosition()

        player.x += (position.x - player.x) / 5
        player.y += (position.y - player.y) / 5

        bodyAngle = body.GetAngle()
        currentRotation = FW.Math.normalizeToCircle(container.rotation * FW.Math.DEG_TO_RAD)

        diff = FW.Math.radiansDiff(currentRotation, bodyAngle)
        diff /= 10
        container.rotation += diff * FW.Math.RAD_TO_DEG
        velocity = body.GetLinearVelocity()
        boost = FW.Math.magnitude(velocity.x, velocity.y) * 6
        targetScale = pixelsPerMeter - boost

        container.scaleX += (targetScale - container.scaleX) / 3
        container.scaleY = container.scaleX
        container.x = halfWidth
        container.y = halfHeight

        # Align the thrust reticle graphic toward the mouse
        angleToMouse = Math.atan2(player.y - harness.y, player.x - harness.x)
        player.setThrustAngle(angleToMouse)

        # Clear existing forces, then accelerate towards the mouse
        forceVector = new Box2D.Common.Math.b2Vec2(-Math.cos(angleToMouse) / 2, -Math.sin(angleToMouse) / 2)
        body.ClearForces()
        body.m_angularVelocity /= 10
        body.ApplyForce(forceVector, body.GetWorldCenter())

        # Align the goal reticle graphic towards the goal
        angleToGoal = Math.atan2(player.y - @_goal.y, player.x - @_goal.x)
        player.setGoalAngle(angleToGoal)

        # Leave a trail of dots!
        lastDot = @_lastPlayerDot
        lastDotDistance = FW.Math.distance(lastDot.x, lastDot.y, player.x, player.y)

        if lastDotDistance > 0.1
          graphics = @mazeShape.graphics
          graphics.setStrokeStyle(0.02, "round", "bevel")
          graphics.beginStroke("rgba(192, 255, 64, 0.2)")
          graphics.moveTo(player.x, player.y)
          graphics.drawCircle(player.x, player.y, 0.01)
          # graphics.lineTo(lastDot.x, lastDot.y)
          graphics.endStroke()
          @_lastPlayerDot.Set(player.x, player.y)

      @world.DrawDebugData()

drawSegments = (graphics, segments) ->
  graphics.setStrokeStyle(0.25, "round", "bevel")
  graphics.beginStroke("rgba(0, 192, 192, 0.3)")

  minX = Infinity
  minY = Infinity
  maxX = -Infinity
  maxY = -Infinity
  for [x1, y1, x2, y2] in segments
    graphics.moveTo(x1, y1)
    graphics.lineTo(x2, y2)
    minX = Math.min(minX, x1, x2)
    minY = Math.min(minY, y1, y2)
    maxX = Math.max(maxX, x1, x2)
    maxY = Math.max(maxY, y1, y2)

  [ minX, minY, maxX, maxY ]