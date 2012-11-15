settings =
  slider:
    intraSliderScale: 0.8
    levelsVisibleOnScreen: 2
    panningEase: 10
  levelContainer:
    selected:
      rotation: 0.32
      targetScale: 4.4
      targetAlpha: 1
      targetY: 1
    unselected:
      rotation: 0.3
      targetScale: 1
      targetAlpha: 0.06
      targetY: 0
    zoomEase: 10
    verticalMoveEase: 10
    alphaEase: 10
    mazeColor: "#0FFFFA"
  nameContainer:
    scale: 150
    alpha: 0.8
    wordVerticalSpacing: 25
    wordVerticalOffset: 10
    wordColor: "#FFFFFF"

# FW.dat.GUI.addSettings(settings)

class @LevelPicker extends FW.ContainerProxy
  constructor: (screen, levelsData, currentIndex) ->
    super()

    # This container holds the horizontally-arranged set of levels
    # We slide it back and forth to pan all the levels together
    levelsContainer = new createjs.Container()
    @addChild(levelsContainer)

    # Scale the slider to focus on a fixed range of levels
    levelsContainer.scaleX = 1 / settings.slider.levelsVisibleOnScreen
    levelsContainer.scaleY = levelsContainer.scaleX

    levelsDisplayObjects = for levelData, i in levelsData
      levelsContainer.addChild(@createLevelDisplayObject(levelData, i))

    # Set instance variables
    @_screen = screen
    @_levelsData = levelsData
    @_levelsContainer = levelsContainer
    @_levelsDisplayObjects = levelsDisplayObjects
    @_currentIndex = currentIndex

  onTick: ->
    # Move the camera around over the levels container
    targetRegX = @_currentIndex
    @_levelsContainer.regX += (targetRegX - @_levelsContainer.regX) / settings.slider.panningEase

  createLevelDisplayObject: (levelData, levelI) ->
    levelPicker = @
    # This container holds the maze preview image and the maze name
    container = new createjs.Container()
    container.x = levelI

    # Draw the preview image of the maze
    shape = new createjs.Shape()
    graphics = shape.graphics
    [ _, _, _, _, radius ] = FW.CreateJS.drawSegments(graphics, settings.levelContainer.mazeColor, levelData.segments)

    # Scale it down to fit based on drawing boundaries
    shape.scaleX = settings.slider.intraSliderScale / (radius * 2)
    shape.scaleY = shape.scaleX

    # TODO: Cache bitmap here? It acts funny,
    # not drawing the cached representation in the right place
    # shape.cache(-radius, -radius, 2 * radius, 2 * radius, 16)

    # Add the level name
    nameContainer = new createjs.Container()
    words = levelData.name.split(/\s+/)
    texts = for word, i in words
      text = new createjs.Text(word)
      text.font = "48px Upheaval"
      text.textAlign = "center"
      text.textBaseline = "middle"
      nameContainer.addChild(text)

    container.addChild(shape)
    container.addChild(nameContainer)

    container.onTick = ->
      if levelI == levelPicker._currentIndex
        shape.rotation += settings.levelContainer.selected.rotation
        targetScale = settings.levelContainer.selected.targetScale
        targetAlpha = settings.levelContainer.selected.targetAlpha
        targetY = settings.levelContainer.selected.targetY
      else
        shape.rotation += settings.levelContainer.unselected.rotation
        targetScale = settings.levelContainer.unselected.targetScale
        targetAlpha = settings.levelContainer.unselected.targetAlpha
        targetY = settings.levelContainer.unselected.targetY

      container.scaleX += (targetScale - container.scaleX) / settings.levelContainer.zoomEase
      container.scaleY = container.scaleX
      container.y += (targetY - container.y) / settings.levelContainer.verticalMoveEase
      container.alpha += (targetAlpha - container.alpha) / settings.levelContainer.alphaEase

      nameContainer.scaleX = 1 / settings.nameContainer.scale
      nameContainer.scaleY = nameContainer.scaleX
      nameContainer.regY = (words.length * settings.nameContainer.wordVerticalSpacing) / 2
      nameContainer.alpha = settings.nameContainer.alpha

      for text, i in texts
        text.y = i * settings.nameContainer.wordVerticalSpacing + settings.nameContainer.wordVerticalOffset
        text.color = settings.nameContainer.wordColor

    container

  currentLevelData: ->
    @_levelsData[@_currentIndex]

  focusOnNextLevel: ->
    @_currentIndex += 1
    if @_currentIndex >= @_levelsDisplayObjects.length
        @_currentIndex = @_levelsDisplayObjects.length - 1

  focusOnPreviousLevel: ->
    @_currentIndex -= 1
    if @_currentIndex < 0
        @_currentIndex = 0
