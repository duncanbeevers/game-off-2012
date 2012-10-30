maxViewportMeters = 4

class @Level extends FW.ContainerProxy
  constructor: (mazeData) ->
    super()

    mazeContainer = new createjs.Container()
    player = new Player()
    goal = new Goal()
    mazeContainer.addChild(player)
    mazeContainer.addChild(goal)
    @_container.addChild(mazeContainer)

    countDown = new CountDown ->
      Ticker.addListener level

    @_countDown = countDown
    @_container.addChild(countDown)

    @_player = player
    @_mazeContainer = mazeContainer
    @_goal = goal

    timerText = new createjs.Text()
    timerText.color = "#FF4522"
    timerText.font = "24px Upheaval"
    timerText.textAlign = "center"
    timerText.textBaseline = "middle"

    @_timerText = timerText
    @_container.addChild(timerText)

    @setupPhysics()


    level = @
    @setupMaze mazeData, -> level.onReady()

  onReady: ->
    createjs.Ticker.addListener(@_countDown)

  setupPhysics: ->
    level = @

    contactListener = new FW.NamedContactListener()
    @_contactListener = contactListener

    world = new Box2D.Dynamics.b2World(
      new Box2D.Common.Math.b2Vec2(0, 0), # no gravity
      true                                # allow sleep
    )
    @world = world
    world.SetContactListener(contactListener)
    contactListener.registerContactListener "Wall", "Player", ->
      src = FW.Math.sample([
        "sounds/plink1.mp3"
        "sounds/plink2.mp3"
        "sounds/plink3.mp3"
        "sounds/plink4.mp3"
        "sounds/plink5.mp3"
      ])
      createjs.SoundJS.play(src, createjs.SoundJS.INTERRUPT_NONE, 0, 0, 0, 1, 0)

    debugCanvas = document.getElementById("debugCanvas")
    if debugCanvas
      b2DebugDraw = Box2D.Dynamics.b2DebugDraw
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
      debugDraw.SetDrawScale(computePixelsPerMeter(level))
      world.SetDebugDraw(debugDraw)

    contactListener.registerContactListener "Player", "Goal", ->
      level.solved = true
      level.completionTime ||= Ticker.getTime()


  onAddedAsChild: (parent) ->
    @harness = FW.MouseHarness.outfit(@_mazeContainer)

  setupMaze: (mazeData, onComplete) ->
    mazeShape = new createjs.Shape()
    mazeGraphics = mazeShape.graphics
    @_mazeShape = mazeShape
    @_mazeContainer.addChild(mazeShape)

    pathShape = new createjs.Shape()
    pathGlowShape = new createjs.Shape()
    pathGraphics = pathShape.graphics
    pathGlowGraphics = pathGlowShape.graphics
    @_pathShape = pathShape
    @_pathGlowShape = pathGlowShape
    @_mazeContainer.addChild(pathGlowShape)
    @_mazeContainer.addChild(pathShape)

    world = @world
    level = @
    getPlayer = (fn) ->
      # TODO: Deal with this race condition,
      fn(level._player)

    onMazeDataAvailable = (mazeData) ->
      positionPlayerAtBeginning(mazeData.start)
      positionGoalAtEnd(mazeData.end, level._goal)
      segments = mazeData.segments

      level.bounds = FW.CreateJS.drawSegments(mazeGraphics, "rgba(87, 21, 183, 0.3)", segments)

      createPhysicsWalls(segments)
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

    createPhysicsWalls = (segments) ->
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
        fixture = world.CreateBody(bodyDef).CreateFixture(fixtureDef)
        fixture.SetUserData name: "Wall"

    onMazeDataAvailable(mazeData)
    # Invoke synchronously
    onComplete()

  tick: ->
    @world.Step(1 / Ticker.getMeasuredFPS(), 10, 10)

    player = @_player
    goal = @_goal

    player.tick()
    goal.tick()

    harness = @harness()

    cameraTrackPlayer(player, @)
    playerTrackMouse(player, harness)
    playerTrackGoal(player, @_goal)
    playerLeaveTrack(player, @)
    updateTimer(@_timerText, @)

    @world.DrawDebugData()

cameraTrackPlayer = (player, level) ->
  solved = level.solved
  container = level._mazeContainer
  canvas = container.getStage().canvas
  canvasWidth = canvas.width
  canvasHeight = canvas.height
  halfCanvasWidth = canvasWidth / 2
  halfCanvasHeight = canvasHeight / 2
  pixelsPerMeter = computePixelsPerMeter(level)
  xOffset = halfCanvasWidth / pixelsPerMeter - player.x
  yOffset = halfCanvasHeight / pixelsPerMeter - player.y
  level.debugDraw?.SetDrawTranslate(new Box2D.Common.Math.b2Vec2(xOffset, yOffset))
  body = player.fixture.GetBody()
  position = body.GetPosition()

  playerPositionEase = easers('playerPosition')
  player.x += (position.x - player.x) / playerPositionEase
  player.y += (position.y - player.y) / playerPositionEase

  bodyAngle = body.GetAngle()
  currentRotation = FW.Math.normalizeToCircle(container.rotation * FW.Math.DEG_TO_RAD)

  diff = FW.Math.radiansDiff(currentRotation, bodyAngle)
  diff /= easers('mazeRotation')
  container.rotation += diff * FW.Math.RAD_TO_DEG

  if solved
    [minX, minY, maxX, maxY] = level.bounds
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


  container.scaleX += (targetScale - container.scaleX) / easers('mazeZoom')
  container.scaleY = container.scaleX
  container.x = halfCanvasWidth
  container.y = halfCanvasHeight
  mazePan = easers('mazePan')
  container.regX += (targetRegX - container.regX) / mazePan
  container.regY += (targetRegY - container.regY) / mazePan

playerTrackMouse = (player, harness) ->
  body = player.fixture.GetBody()

  # Align the thrust reticle graphic toward the mouse
  angleToMouse = Math.atan2(player.y - harness.y, player.x - harness.x)
  player.setThrustAngle(angleToMouse)

  # Clear existing forces, then accelerate towards the mouse
  forceVector = new Box2D.Common.Math.b2Vec2(-Math.cos(angleToMouse) / 2, -Math.sin(angleToMouse) / 2)
  body.ClearForces()
  body.m_angularVelocity /= easers('playerRotation')
  body.ApplyForce(forceVector, body.GetWorldCenter())

playerTrackGoal = (player, goal) ->
  # Align the goal reticle graphic towards the goal
  angleToGoal = Math.atan2(player.y - goal.y, player.x - goal.x)
  player.setGoalAngle(angleToGoal)

playerLeaveTrack = (player, level) ->
  # Leave a trail of dots!
  lastDot = level._lastPlayerDot
  lastDotDistance = FW.Math.distance(lastDot.x, lastDot.y, player.x, player.y)

  body = player.fixture.GetBody()
  velocity = body.GetLinearVelocity()
  magnitude = FW.Math.magnitude(velocity.x, velocity.y)
  moveDistance = Math.max(magnitude / 20, 0.01)

  if lastDotDistance > moveDistance
    pathGraphics = level._pathShape.graphics
    pathGlowGraphics = level._pathGlowShape.graphics
    if !level._drewAnyDots
      pathGraphics.endStroke()
      pathGraphics.beginStroke("rgba(0, 255, 255, 1)")
      pathGraphics.setStrokeStyle(0.02, "round", "round")
      pathGraphics.moveTo(lastDot.x, lastDot.y)

      pathGlowGraphics.endStroke()
      pathGlowGraphics.beginStroke("rgba(0, 255, 255, 0.4)")
      pathGlowGraphics.setStrokeStyle(0.08, "round", "round")
      pathGlowGraphics.moveTo(lastDot.x, lastDot.y)
      level._drewAnyDots = true

    pathGraphics.lineTo(player.x, player.y)
    pathGlowGraphics.lineTo(player.x, player.y)
    lastDot.Set(player.x, player.y)

easers = (key) ->
  fps = Ticker.getMeasuredFPS()
  divisor = switch key
    when 'mazeRotation'   then 2
    when 'mazeZoom'       then 6.5
    when 'mazePan'        then 4
    when 'playerPosition' then 4
    when 'playerRotation' then 2
    when 'timerText'      then 4

  fps / divisor

computePixelsPerMeter = (level) ->
  container = level._mazeContainer
  canvas = container.getStage().canvas
  canvasWidth = canvas.width
  canvasHeight = canvas.height

  Math.min(canvasWidth / maxViewportMeters, canvasHeight / maxViewportMeters)

updateTimer = (timer, level) ->
  now = Ticker.getTime()
  if !level.startTime
    level.startTime = now
  elapsed = (level.completionTime || now) - level.startTime
  canvas = timer.getStage().canvas

  timer.text = FW.Time.clockFormat(elapsed)
  if level.solved
    targetX = canvas.width / 2
    targetY = canvas.height / 2
    targetScale = canvas.width / 105
  else
    targetX = canvas.width / 2
    targetY = 12
    targetScale = 1

  ease = easers('timerText')
  timer.x += (targetX - timer.x) / ease
  timer.y += (targetY - timer.y) / ease
  timer.scaleX += (targetScale - timer.scaleX) / ease
  timer.scaleY = timer.scaleX