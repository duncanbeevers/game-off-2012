settings =
  mazeRotationEase   : 100
  mazeZoomOutEase    : 6
  mazeZoomInEase     : 5
  mazePanEase        : 4
  playerPositionEase : 3
  playerRotationEase : 2
  timerTextEase      : 4
  motion:
    amplification: 7
    clamp: 0.5

# FW.dat.GUI.addSettings(settings)

maxViewportMeters = 6

setupTimerText = ->
  timerText = TextFactory.create("", "#B500FF")

  timerText

setupLampOilIndicator = ->
  container = new createjs.Container()
  meterShape = new createjs.Shape()
  graphics = meterShape.graphics

  graphics.beginStroke("rgba(0, 0, 0, 0)")
  graphics.beginFill("rgba(255, 248, 62, 0.5)")
  graphics.drawRect(-0.5, -0.5, 1, 1)
  graphics.endFill()
  graphics.endStroke()

  container.addChild(meterShape)

  container._oilLevel = 5000
  container

class @Level extends FW.ContainerProxy
  constructor: (game, hci, mazeData, onMazeSolved) ->
    super()

    pauseMenu = new PauseMenu(game, hci)
    game.getSceneManager().addScene("pauseMenu", pauseMenu)

    levelContainer = @_container
    mazeContainer = new createjs.Container()
    player  = new Player()
    goal    = new Goal()
    mazeContainer.addChild(player)
    mazeContainer.addChild(goal)

    countDown = new CountDown()
    timerText = setupTimerText()
    lampOilIndicator = setupLampOilIndicator()

    @setupPhysics()

    levelContainer.addChild(mazeContainer)
    levelContainer.addChild(countDown)
    levelContainer.addChild(timerText)
    levelContainer.addChild(lampOilIndicator)

    level = @
    @setupMaze mazeData, mazeContainer, player, goal, -> level.onReady()

    @_game             = game
    @_hci              = hci
    @_onMazeSolved     = onMazeSolved
    @_mazeContainer    = mazeContainer
    @_player           = player
    @_goal             = goal
    @_countDown        = countDown
    @_timerText        = timerText
    @_lampOilIndicator = lampOilIndicator
    @_wallImpactsCount = 0

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

    @_world = world

    world.SetContactListener(contactListener)
    # TODO: Make a directory, dynamically-loaded plinkplonk sounds
    # TODO: Differentiate sounds based on impact severity, plinks and PLONKS
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
      level.incrementWallImpacts()

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
      level._onMazeSolved()
      level.solved = true
      createjs.SoundJS.play("sounds/Goal1.mp3", createjs.SoundJS.INTERRUPT_NONE, 0, 0, 0, 1, 0)
      level._game.setBgmTracks(["sounds/GoalBGM1.mp3"])
      level.completionTime ||= createjs.Ticker.getTime(true)


  onEnterScene: ->
    hci = @_hci
    level = @

    beginBacktrack = ->
      level.beginBacktrack()

    endBacktrack = ->
      level.endBacktrack()

    releaseLamp = ->
      level.releaseLamp()

    onUtilityKey = ->
      onActivatedPauseMenu(level)

    @_hciSet = hci.on(
      [ "keyDown:#{FW.HCI.KeyMap.SPACE}", beginBacktrack ]
      [ "keyUp:#{FW.HCI.KeyMap.SPACE}",   endBacktrack ]
      [ "keyDown:#{FW.HCI.KeyMap.ENTER}", onUtilityKey ]
      [ "keyDown:#{FW.HCI.KeyMap.ESCAPE}", onUtilityKey ]
    )
    @_harness = FW.MouseHarness.outfit(@_mazeContainer)

  onLeaveScene: ->
    @_hciSet.off()

  setupMaze: (mazeData, mazeContainer, player, goal, onComplete) ->
    mazeShape = new createjs.Shape()
    mazeGraphics = mazeShape.graphics

    pathShape        = new createjs.Shape()
    pathGlowShape    = new createjs.Shape()
    pathGraphics     = pathShape.graphics
    pathGlowGraphics = pathGlowShape.graphics

    onMazeDataAvailable = (mazeData, player, goal) ->
      positionPlayerAtBeginning(mazeData.start, player)
      positionGoalAtEnd(mazeData.end, goal)
      segments = mazeData.segments
      passages = mazeData.passages

      createPhysicsWalls(world, segments)
      createPhysicsPassages(world, passages)

      level.bounds = FW.CreateJS.drawSegments(mazeGraphics, "rgba(87, 21, 183, 0.3)", segments)
      level.walls = segments
      level.mazeGenerated = true

    positionPlayer = (start, player) ->
      [ player.x, player.y ] = start
      level._lastPlayerDot = new Box2D.Common.Math.b2Vec2(player.x, player.y)

    # Create physics entity

    positionPlayerAtBeginning = (maze, player) ->
      positionPlayer(maze, player)
      createPhysicsPlayer(world, player)

    positionGoalAtEnd = (end, goal) ->
      [ goal.x, goal.y ] = end
      createPhysicsGoal(world, goal)

    mazeContainer.addChild(mazeShape)
    mazeContainer.addChild(pathGlowShape)
    mazeContainer.addChild(pathShape)

    world = @_world
    level = @
    @_pathShape      = pathShape
    @_pathGlowShape  = pathGlowShape

    onMazeDataAvailable(mazeData, player, goal)
    # Invoke synchronously
    onComplete()

  onTick: ->
    stage = @getStage()
    return unless stage

    runSimulation = !@solved && @_countDown.getCompleted() && !@_backtracking
    lampOilIndicator = @_lampOilIndicator
    if runSimulation
      @_everRanSimulation = true
      fps = createjs.Ticker.getFPS()
      @_world.Step(1 / fps, 10, 10)
      lampOilIndicator._oilLevel = Math.max(0, lampOilIndicator._oilLevel - 1)

    player = @_player
    goal = @_goal

    if @_backtracking
      if @_playerPositionStack.length
        [ player.x, player.y ] = @_playerPositionStack.pop()
      else
        @endBacktrack()


    if @_harness
      harness = @_harness()
      playerReticleTrackMouse(player, harness)

    levelTrackPlayer(@, player)
    playerReticleTrackGoal(player, goal)

    if runSimulation
      playerTrackFixture(player)
      playerLeaveTrack(player, @)
      playerAccelerateTowardsTarget(player)

    lampOilIndicatorTrackStage(lampOilIndicator)

    if @_everRanSimulation
      updateTimer(@_timerText, @)

    @_world.DrawDebugData()

  incrementWallImpacts: ->
    @_wallImpactsCount += 1

  releaseLamp: () ->
    mazeContainer = @_mazeContainer
    player = @_player
    lamp = new Lamp()
    mazeContainer.addChild(lamp)
    createPhysicsLamp(@_world, lamp, player)

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

  player.x += (position.x - player.x) / settings.playerPositionEase
  player.y += (position.y - player.y) / settings.playerPositionEase


levelTrackPlayer = (level, player) ->
  solved = level.solved
  mazeContainer = level._mazeContainer
  canvas = mazeContainer.getStage().canvas
  canvasWidth = canvas.width
  canvasHeight = canvas.height
  halfCanvasWidth = canvasWidth / 2
  halfCanvasHeight = canvasHeight / 2
  pixelsPerMeter = computePixelsPerMeter(level)
  xOffset = halfCanvasWidth / pixelsPerMeter - player.x
  yOffset = halfCanvasHeight / pixelsPerMeter - player.y
  debugDraw = level.debugDraw

  body = player.fixture.GetBody()
  position = body.GetPosition()

  targetRotation = Math.atan2(position.y, position.x)
  currentRotation = FW.Math.wrapToCircle(mazeContainer.rotation * FW.Math.DEG_TO_RAD)

  diff = FW.Math.radiansDiff(currentRotation, targetRotation)
  diff /= settings.mazeRotationEase

  if !debugDraw
    mazeContainer.rotation += diff * FW.Math.RAD_TO_DEG

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


  if targetScale > mazeContainer.scaleX
    zoomEase = settings.mazeZoomInEase
  else
    zoomEase = settings.mazeZoomOutEase

  mazeContainer.scaleX += (targetScale - mazeContainer.scaleX) / zoomEase
  mazeContainer.scaleY = mazeContainer.scaleX
  mazeContainer.x = halfCanvasWidth
  mazeContainer.y = halfCanvasHeight
  mazePan = settings.mazePanEase
  mazeContainer.regX += (targetRegX - mazeContainer.regX) / mazePan
  mazeContainer.regY += (targetRegY - mazeContainer.regY) / mazePan

  if debugDraw
    scale = Math.max(mazeContainer.scaleX, 0)
    debugDraw.SetDrawScale(scale)
    debugDraw.SetDrawTranslate(new Box2D.Common.Math.b2Vec2(
      halfCanvasWidth / scale - mazeContainer.regX
      halfCanvasHeight / scale - mazeContainer.regY
    ))
    # debugDraw.SetDrawTranslate(new Box2D.Common.Math.b2Vec2(player.x, player.y))

playerReticleTrackMouse = (player, harness) ->
  # Align the thrust reticle graphic toward the mouse
  targetX = player.x - harness.x
  targetY = player.y - harness.y

  angleToMouse = Math.atan2(targetY, targetX)
  player.setThrustReticleAngle(angleToMouse)
  player.thrustTarget = [ targetX, targetY ]

playerAccelerateTowardsTarget = (player) ->
  body = player.fixture.GetBody()

  # Clear existing forces, then accelerate towards the target
  [ thrustX, thrustY ] = player.thrustTarget
  length = FW.Math.clamp(FW.Math.magnitude(thrustX, thrustY), 0, settings.motion.clamp) * settings.motion.amplification
  [ forceVectorX, forceVectorY ] = FW.Math.normalizeCoordinates(thrustX, thrustY, -length)

  forceVector = new Box2D.Common.Math.b2Vec2(forceVectorX, forceVectorY)
  body.SetLinearVelocity(forceVector)

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

lampOilIndicatorTrackStage = (lampOilIndicator) ->
  oil = lampOilIndicator._oilLevel
  maxOil = Math.max(lampOilIndicator._maxOilLevel || 0, oil)

  indicatorHeight = 24
  canvas = lampOilIndicator.getStage().canvas

  lampOilIndicator.x = (canvas.width / 2)
  lampOilIndicator.y = canvas.height - indicatorHeight

  lampOilIndicator.scaleX = canvas.width * (oil / maxOil)
  lampOilIndicator.scaleY = indicatorHeight

  lampOilIndicator._oilLevel = oil
  lampOilIndicator._maxOilLevel = maxOil

computePixelsPerMeter = (level) ->
  mazeContainer = level._mazeContainer
  canvas = mazeContainer.getStage().canvas
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
    targetScale = canvas.width / 210
  else
    targetX = canvas.width / 2
    targetY = 12
    targetScale = 0.5

  ease = settings.timerTextEase
  timer.x += (targetX - timer.x) / ease
  timer.y += (targetY - timer.y) / ease
  timer.scaleX += (targetScale - timer.scaleX) / ease
  timer.scaleY = timer.scaleX

createPhysicsPlayer = (world, player) ->
  fixtureDef = new Box2D.Dynamics.b2FixtureDef()
  fixtureDef.density = 1
  fixtureDef.friction = 0.1
  fixtureDef.restitution = 0.1
  diameter = 0.4
  fixtureDef.shape = new Box2D.Collision.Shapes.b2CircleShape(diameter / 4)
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

createPhysicsPassages = (word, passages) ->

createPhysicsWalls = (world, segments) ->
  fixtureDef = new Box2D.Dynamics.b2FixtureDef
  fixtureDef.density     = 1
  fixtureDef.friction    = 0.1
  fixtureDef.restitution = 0.2

  wallThickness = 0.1

  bodyDef      = new Box2D.Dynamics.b2BodyDef()
  bodyDef.type = Box2D.Dynamics.b2Body.b2_staticBody
  rectangle    = new Box2D.Collision.Shapes.b2PolygonShape()
  circle       = new Box2D.Collision.Shapes.b2CircleShape(wallThickness)

  for [x1, y1, x2, y2] in segments
    length = FW.Math.distance(x1, y1, x2, y2)
    rectangle.SetAsBox(length / 2, wallThickness)
    fixtureDef.shape = rectangle
    # Center rectangle
    bodyDef.position.Set((x2 - x1) / 2 + x1, (y2 - y1) / 2 + y1)
    bodyDef.angle = Math.atan2(y2 - y1, x2 - x1)
    fixture = world.CreateBody(bodyDef).CreateFixture(fixtureDef)
    fixture.SetUserData name: "Wall"

    # Round caps
    bodyDef.position.Set(x1, y1)
    bodyDef.angle = 0
    fixtureDef.shape = circle
    fixture = world.CreateBody(bodyDef).CreateFixture(fixtureDef)
    fixture.SetUserData name: "Wall"

    bodyDef.position.Set(x2, y2)
    fixture = world.CreateBody(bodyDef).CreateFixture(fixtureDef)
    fixture.SetUserData name: "Wall"


createPhysicsLamp = (world, lamp, player) ->
  fixtureDef = new Box2D.Dynamics.b2FixtureDef()
  fixtureDef.density = 1
  fixtureDef.friction = 0.1
  fixtureDef.restitution = 0.1
  diameter = 0.1
  fixtureDef.shape = new Box2D.Collision.Shapes.b2CircleShape(diameter / 2)
  bodyDef = new Box2D.Dynamics.b2BodyDef()
  bodyDef.type = Box2D.Dynamics.b2Body.b2_dynamicBody

  distanceFromPlayer = (player.radius - diameter)
  bodyDef.position.x = player.x - distanceFromPlayer
  bodyDef.position.y = player.y

  lamp.fixture = world.CreateBody(bodyDef).CreateFixture(fixtureDef)
  lamp.fixture.SetUserData(player)

onActivatedPauseMenu = (level) ->
  level._game.getSceneManager().pushScene("pauseMenu")
