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

    levelsDisplayObjects = for levelData, i in levelsData
      levelsContainer.addChild(@createLevelDisplayObject(levelData, i))

    # Set instance variables
    @_screen = screen
    @_levelsData = levelsData
    @_levelsContainer = levelsContainer
    @_levelsDisplayObjects = levelsDisplayObjects
    @_currentIndex = currentIndex

  tick: ->
    # Move the camera around over the levels container
    targetRegX = @_currentIndex
    @_levelsContainer.regX += (targetRegX - @_levelsContainer.regX) / 10
    # Update each child
    for levelDisplayObject, i in @_levelsDisplayObjects
      levelDisplayObject.tick()

  createLevelDisplayObject: (levelData, i) ->
    levelPicker = @
    container = new createjs.Container()
    container.x = i
    shape = new createjs.Shape()
    graphics = shape.graphics

    [ minX, minY, maxX, maxY ] = FW.CreateJS.drawSegments(graphics, "#FF5E24", levelData.segments)

    radius = Math.max((maxX - minX) / 2, (maxY - minY) / 2, Math.abs(minX), Math.abs(maxX), Math.abs(minY), Math.abs(maxY))
    shape.scaleX = intraSliderScale / (radius * 2)
    shape.scaleY = shape.scaleX

    container.addChild(shape)
    container._levelShape = shape

    new createjs.Text(levelData.name)

    container.tick = ->
      if i == levelPicker._currentIndex
        shape.rotation += 0.02
        targetScale = 2.2
        targetAlpha = 1
      else
        targetScale = 1
        targetAlpha = 0.2

      container.scaleX += (targetScale - container.scaleX) / 10
      container.scaleY = container.scaleX
      container.alpha += (targetAlpha - container.alpha) / 10

      shape.rotation += 0.3

    container

  focusOnNextLevel: ->
    @_currentIndex += 1
    if @_currentIndex >= @_levelsDisplayObjects.length
        @_currentIndex = @_levelsDisplayObjects.length - 1

  focusOnPreviousLevel: ->
    @_currentIndex -= 1
    if @_currentIndex < 0
        @_currentIndex = 0
