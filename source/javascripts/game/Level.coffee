maxViewportMeters = 4

class @Level extends FW.ContainerProxy
  constructor: (game, mazeData) ->
    super()
    @_game = game

    mazeContainer = new createjs.Container()
    player = new Player()
    goal = new Goal()
    mazeContainer.addChild(player)
    mazeContainer.addChild(goal)
    @_container.addChild(mazeContainer)

    countDown = new CountDown

    @_countDown = countDown
    @_container.addChild(countDown)

    @_player = player
    @_mazeContainer = mazeContainer
    @_goal = goal

    timerText = new createjs.Text()
    timerText.color = "#B500FF"
    timerText.font = "24px Upheaval"
    timerText.textAlign = "center"
    timerText.textBaseline = "middle"

    @_timerText = timerText
    @_container.addChild(timerText)

    @setupPhysics()


    level = @
    @setupMaze mazeData, -> level.onReady()

  onReady: ->
    # @_countDown.begin()
    # createjs.Ticker.addListener(@_countDown)

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
        "sounds/plonk1.mp3"
        "sounds/plonk2.mp3"
        "sounds/plonk3.mp3"
        "sounds/plonk4.mp3"
        "sounds/plonk5.mp3"
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
        # b2DebugDraw.e_jointBit        |
        # b2DebugDraw.e_aabbBit         |
        b2DebugDraw.e_centerOfMassBit |
        # b2DebugDraw.e_coreShapeBit    |
        # b2DebugDraw.e_jointBit        |
        # b2DebugDraw.e_obbBit          |
        # b2DebugDraw.e_pairBit         |
        0
      )
      world.SetDebugDraw(debugDraw)

    contactListener.registerContactListener "Player", "Goal", ->
      level.solved = true
      createjs.SoundJS.play("sounds/Goal1.mp3", createjs.SoundJS.INTERRUPT_NONE, 0, 0, 0, 1, 0)
      level._game.setBgmTracks(["sounds/GoalBGM1.mp3"])
      level.completionTime ||= createjs.Ticker.getTime(true)


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

      createPhysicsWalls(world, segments)
      level.walls = segments
      level.mazeGenerated = true

    positionPlayer = (start, player) ->
      [ player.x, player.y ] = start
      level._lastPlayerDot = new Box2D.Common.Math.b2Vec2(player.x, player.y)

    # Create physics entity

    positionPlayerAtBeginning = (maze) ->
      getPlayer (player) ->
        positionPlayer(maze, player)
        createPhysicsPlayer(world, player)

    positionGoalAtEnd = (end, goal) ->
      [ goal.x, goal.y ] = end
      createPhysicsGoal(world, goal)

    onMazeDataAvailable(mazeData)
    # Invoke synchronously
    onComplete()

  tick: ->
    runSimulation = !@solved && @_countDown.getCompleted() && !@_backtracking
    if runSimulation
      @_everRanSimulation = true
      @world.Step(1 / createjs.Ticker.getMeasuredFPS(), 10, 10)

    player = @_player
    goal = @_goal

    if @_backtracking
      if @_playerPositionStack.length
        [ player.x, player.y ] = @_playerPositionStack.pop()
      else
        @endBacktrack()


    harness = @harness()

    levelTrackPlayer(@, player)
    playerReticleTrackMouse(player, harness)
    playerReticleTrackGoal(player, goal)

    if runSimulation
      playerTrackFixture(player)
      playerLeaveTrack(player, @)
      playerAccelerateTowardsTarget(player)

    if @_everRanSimulation
      updateTimer(@_timerText, @)

    @world.DrawDebugData()

  releasePups: () ->
    mazeContainer = @_mazeContainer
    player = @_player
    pup = new Pup()
    mazeContainer.addChild(pup)
    createPhysicsPup(@world, pup, player)

  beginBacktrack: () ->
    @_backtracking = true

  endBacktrack: () ->
    @_backtracking = false
    @_drewAnyDots = false
    player = @_player
    body = player.fixture.GetBody()
    body.SetPosition(new Box2D.Common.Math.b2Vec2(player.x, player.y))
    @_lastPlayerDot.Set(player.x, player.y)

playerTrackFixture = (player) ->
  body = player.fixture.GetBody()
  position = body.GetPosition()

  playerPositionEase = easers('playerPosition')
  player.x += (position.x - player.x) / playerPositionEase
  player.y += (position.y - player.y) / playerPositionEase


levelTrackPlayer = (level, player) ->
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
  debugDraw = level.debugDraw

  body = player.fixture.GetBody()

  bodyAngle = body.GetAngle()
  currentRotation = FW.Math.wrapToCircle(container.rotation * FW.Math.DEG_TO_RAD)

  diff = FW.Math.radiansDiff(currentRotation, bodyAngle)
  diff /= easers('mazeRotation')

  if !debugDraw
    container.rotation += diff * FW.Math.RAD_TO_DEG

  if solved
    [_, _, _, _, maxMagnitude] = level.bounds
    targetScale = Math.min(
      canvasWidth / (maxMagnitude * 2),
      canvasHeight / (maxMagnitude * 2)
    )
    targetRegX = 0
    targetRegY = 0
  else
    velocity = body.GetLinearVelocity()
    velocityBoost = FW.Math.magnitude(velocity.x, velocity.y) * 6
    targetScale = pixelsPerMeter - velocityBoost
    targetRegX = player.x
    targetRegY = player.y


  if targetScale > container.scaleX
    zoomEase = easers('mazeZoomIn')
  else
    zoomEase = easers('mazeZoomOut')

  container.scaleX += (targetScale - container.scaleX) / zoomEase
  container.scaleY = container.scaleX
  container.x = halfCanvasWidth
  container.y = halfCanvasHeight
  mazePan = easers('mazePan')
  container.regX += (targetRegX - container.regX) / mazePan
  container.regY += (targetRegY - container.regY) / mazePan

  if debugDraw
    scale = Math.max(container.scaleX, 0)
    debugDraw.SetDrawScale(scale)
    debugDraw.SetDrawTranslate(new Box2D.Common.Math.b2Vec2(
      halfCanvasWidth / scale - container.regX
      halfCanvasHeight / scale - container.regY
    ))
    # debugDraw.SetDrawTranslate(new Box2D.Common.Math.b2Vec2(player.x, player.y))

playerReticleTrackMouse = (player, harness) ->
  # Align the thrust reticle graphic toward the mouse
  targetX = player.x - harness.x
  targetY = player.y - harness.y

  angleToMouse = Math.atan2(targetY, targetX)
  player.setThrustAngle(angleToMouse)
  player.thrustTarget = [ targetX, targetY ]

playerAccelerateTowardsTarget = (player) ->
  body = player.fixture.GetBody()

  # Clear existing forces, then accelerate towards the target
  [ thrustX, thrustY ] = FW.Math.normalizeVector(player.thrustTarget)
  forceVectorScalar = -0.5
  forceVector = new Box2D.Common.Math.b2Vec2(thrustX * forceVectorScalar, thrustY * forceVectorScalar)
  body.ClearForces()
  body.m_angularVelocity /= easers('playerRotation')
  body.ApplyForce(forceVector, body.GetWorldCenter())

playerReticleTrackGoal = (player, goal) ->
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
    position = body.GetPosition()
    level._playerPositionStack ||= [ ]
    level._playerPositionStack.push([ position.x, player.y ])

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
  fps = createjs.Ticker.getMeasuredFPS()
  divisor = switch key
    when 'mazeRotation'   then 2
    when 'mazeZoomOut'    then 6
    when 'mazeZoomIn'     then 5
    when 'mazePan'        then 4
    when 'playerPosition' then 5
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
  now = createjs.Ticker.getTime(true)
  if !level.startTime
    level.startTime = now
  elapsed = (level.completionTime || now) - level.startTime
  canvas = timer.getStage().canvas

  timer.text = FW.Time.clockFormat(elapsed)
  if level.solved
    targetX = canvas.width / 2
    targetY = canvas.height / 2 - 25
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

createPhysicsPlayer = (world, player) ->
  fixtureDef = new Box2D.Dynamics.b2FixtureDef()
  fixtureDef.density = 1
  fixtureDef.friction = 0.3
  fixtureDef.restitution = 0.1
  diameter = 0.2
  fixtureDef.shape = new Box2D.Collision.Shapes.b2CircleShape(diameter / 2)
  bodyDef = new Box2D.Dynamics.b2BodyDef()
  bodyDef.type = Box2D.Dynamics.b2Body.b2_dynamicBody
  bodyDef.position.x = player.x
  bodyDef.position.y = player.y
  player.radius = diameter / 2
  player.fixture = world.CreateBody(bodyDef).CreateFixture(fixtureDef)
  player.fixture.SetUserData(player)

createPhysicsGoal = (world, goal) ->
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

createPhysicsWalls = (world, segments) ->
  fixtureDef = new Box2D.Dynamics.b2FixtureDef
  fixtureDef.density     = 1
  fixtureDef.friction    = 0.1
  fixtureDef.restitution = 0.2

  bodyDef = new Box2D.Dynamics.b2BodyDef()

  bodyDef.type = Box2D.Dynamics.b2Body.b2_staticBody
  fixtureDef.shape = new Box2D.Collision.Shapes.b2PolygonShape()
  wallThickness = 0.1
  for [x1, y1, x2, y2] in segments
    length = FW.Math.distance(x1, y1, x2, y2)
    fixtureDef.shape.SetAsBox(length / 2, wallThickness)
    bodyDef.position.Set((x2 - x1) / 2 + x1, (y2 - y1) / 2 + y1)
    bodyDef.angle = Math.atan2(y2 - y1, x2 - x1)
    fixture = world.CreateBody(bodyDef).CreateFixture(fixtureDef)
    fixture.SetUserData name: "Wall"

createPhysicsPup = (world, pup, player) ->
  fixtureDef = new Box2D.Dynamics.b2FixtureDef()
  fixtureDef.density = 1
  fixtureDef.friction = 0.1
  fixtureDef.restitution = 0.1
  diameter = 0.1
  fixtureDef.shape = new Box2D.Collision.Shapes.b2CircleShape(diameter / 2)
  bodyDef = new Box2D.Dynamics.b2BodyDef()
  bodyDef.type = Box2D.Dynamics.b2Body.b2_dynamicBody

  # TODO : Distribute multiple pups about the player
  distanceFromPlayer = (player.radius - diameter)
  bodyDef.position.x = player.x - distanceFromPlayer
  bodyDef.position.y = player.y

  pup.fixture = world.CreateBody(bodyDef).CreateFixture(fixtureDef)
  pup.fixture.SetUserData(player)