intraSliderScale = 0.8
levelsVisibleOnScreen = 2

class @LevelPicker extends FW.ContainerProxy
  constructor: (screen, levelsData, currentIndex) ->
    super()

    # This container holds the horizontally-arranged set of levels
    # We slide it back and forth to pan all the levels together
    levelsContainer = new createjs.Container()
    @addChild(levelsContainer)

    # Scale the slider to focus on a fixed range of levels
    levelsContainer.scaleX = 1 / levelsVisibleOnScreen
    levelsContainer.scaleY = levelsContainer.scaleX

    levelsContainers = for levelData, i in levelsData
      levelContainer = @createLevelDisplayObject(levelData)
      levelContainer.x = i
      levelsContainer.addChild(levelContainer)

    # Set instance variables
    @_screen = screen
    @_levelsData = levelsData
    @_levelsContainer = levelsContainer
    @_levelsContainers = levelsContainers
    @_currentIndex = currentIndex

  tick: ->
    # Move the level container around...
    targetRegX = @_currentIndex
    @_levelsContainer.regX += (targetRegX - @_levelsContainer.regX) / 10
    for levelContainer, i in @_levelsContainers
      if i == @_currentIndex
        targetScale = 2.2
        targetAlpha = 1
      else
        targetScale = 1
        targetAlpha = 0.2

      levelContainer.scaleX += (targetScale - levelContainer.scaleX) / 10
      levelContainer.scaleY = levelContainer.scaleX
      levelContainer.alpha += (targetAlpha - levelContainer.alpha) / 10

  createLevelDisplayObject: (levelData) ->
    container = new createjs.Container()
    shape = new createjs.Shape()
    graphics = shape.graphics

    [ minX, minY, maxX, maxY ] = FW.CreateJS.drawSegments(graphics, "#FF5E24", levelData.segments)

    radius = Math.max((maxX - minX) / 2, (maxY - minY) / 2, Math.abs(minX), Math.abs(maxX), Math.abs(minY), Math.abs(maxY))
    shape.scaleX = intraSliderScale / (radius * 2)
    shape.scaleY = shape.scaleX

    container.addChild(shape)
    container

  focusOnNextLevel: ->
    @_currentIndex += 1
    if @_currentIndex >= @_levelsContainers.length
        @_currentIndex = @_levelsContainers.length - 1

  focusOnPreviousLevel: ->
    @_currentIndex -= 1
    if @_currentIndex < 0
        @_currentIndex = 0
