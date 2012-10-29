pixelsPerMeter = 120

class @Level extends FW.ContainerProxy
  constructor: (mazeData) ->
    super()

    mazeContainer = new createjs.Container()
    player = new Player()
    goal = new Goal()
    mazeContainer.addChild(player)
    mazeContainer.addChild(goal)
    @_container.addChild(mazeContainer)

    @_player = player
    @_mazeContainer = mazeContainer
    @_goal = goal

    @setupPhysics()
    @setupMaze(mazeData)

  setupPhysics: ->
    contactListener = new FW.NamedContactListener()
    @_contactListener = contactListener

    b2DebugDraw = Box2D.Dynamics.b2DebugDraw
    world = new Box2D.Dynamics.b2World(
      new Box2D.Common.Math.b2Vec2(0, 0), # no gravity
      true                                # allow sleep
    )
    @world = world
    world.SetContactListener(contactListener)

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

    level = @
    contactListener.registerContactListener "Player", "Goal", ->
      level.solved = true


  onAddedAsChild: (parent) ->
    @harness = FW.MouseHarness.outfit(@_mazeContainer)

  setupMaze: (mazeData) ->
    mazeShape = new createjs.Shape()
    mazeGraphics = mazeShape.graphics
    @_mazeShape = mazeShape

    @_mazeContainer.addChild(mazeShape)

    world = @world
    level = @
    getPlayer = (fn) ->
      # TODO: Deal with this race condition,
      fn(level._player)

    onMazeDataAvailable = (mazeData) ->
      positionPlayerAtBeginning(mazeData.start)
      positionGoalAtEnd(mazeData.end, level._goal)
      segments = mazeData.segments

      level.bounds = FW.CreateJS.drawSegments(mazeGraphics, segments)

      craftPhysicsWalls(segments)
      level.walls = segments
      level.mazeGenerated = true

    positionPlayer = (start, player) ->
      [ player.x, player.y ] = start
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
      player.fixture.SetUserData(player)


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
      goal.fixture.SetUserData(goal)

    positionPlayerAtBeginning = (maze) ->
      getPlayer (player) ->
        positionPlayer(maze, player)
        createPhysicsPlayer(player)

    positionGoalAtEnd = (end, goal) ->
      [ goal.x, goal.y ] = end
      createPhysicsGoal(goal)

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

    onMazeDataAvailable(mazeData)

  tick: ->
    player = @_player
    goal = @_goal

    player.tick()
    goal.tick()

    container = @_mazeContainer
    harness = @harness()

    if @mazeGenerated
      @world.Step(1 / 20, 10, 10)

      # Update player graphic to follow physics entity
      if player.fixture
        canvas = container.getStage().canvas
        canvasWidth = canvas.width
        canvasHeight = canvas.height
        halfCanvasWidth = canvasWidth / 2
        halfCanvasHeight = canvasHeight / 2
        xOffset = halfCanvasWidth / pixelsPerMeter - player.x
        yOffset = halfCanvasHeight / pixelsPerMeter - player.y
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

        if @solved
          [minX, minY, maxX, maxY] = @bounds
          width = maxX - minX
          height = maxY - minY
          targetScale = Math.min(canvasWidth / width, canvasHeight / height, canvasWidth / height, canvasHeight / width)
          targetRegX = 0
          targetRegY = 0
        else
          velocity = body.GetLinearVelocity()
          boost = FW.Math.magnitude(velocity.x, velocity.y) * 6
          targetScale = pixelsPerMeter - boost
          targetRegX = player.x
          targetRegY = player.y


        container.scaleX += (targetScale - container.scaleX) / 3
        container.scaleY = container.scaleX
        container.x = halfCanvasWidth
        container.y = halfCanvasHeight
        container.regX += (targetRegX - container.regX) / 5
        container.regY += (targetRegY - container.regY) / 5

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
          graphics = @_mazeShape.graphics
          graphics.setStrokeStyle(0.02, "round", "bevel")
          graphics.beginStroke("rgba(192, 255, 64, 0.2)")
          graphics.moveTo(player.x, player.y)
          # graphics.drawCircle(player.x, player.y, 0.01)
          graphics.lineTo(lastDot.x, lastDot.y)
          graphics.endStroke()
          @_lastPlayerDot.Set(player.x, player.y)

      @world.DrawDebugData()
