class @LevelPicker extends FW.ContainerProxy
  constructor: (screen, levels, currentIndex) ->
    super()

    # This container holds the horizontally-arranged set of levels
    # We slide it back and forth to pan all the levels together
    levelsContainer = new createjs.Container()
    @addChild(levelsContainer)

    # Scale the slider to focus on a fixed range of levels
    levelsVisibleOnScreen = 3.5
    levelsContainer.scaleX = levelsVisibleOnScreen
    levelsContainer.scaleY = levelsContainer.scaleX

    for levelData, i in levels

      levelContainer = @createLevelDisplayObject(levelData)
      levelContainer.x = i
      levelsContainer.addChild(levelContainer)

    # Set instance variables
    @_screen = screen
    @_levels = levels
    @_levelsContainer = levelsContainer
    @_currentIndex = currentIndex

  tick: ->
    # Move the level container around...
    @_levelsContainer.x += (@_currentIndex - @_levelsContainer.x) / 10

  createLevelDisplayObject: (levelData) ->
    # container = new createjs.Container()
    shape = new createjs.Shape()
    graphics = shape.graphics

    [ minX, minY, maxX, maxY ] = FW.CreateJS.drawSegments(graphics, "#FF5E24", levelData.segments)

    radius = Math.max((maxX - minX) / 2, (maxY - minY) / 2, Math.abs(minX), Math.abs(maxX), Math.abs(minY), Math.abs(maxY))
    intraSliderScale = 0.5
    shape.scaleX = intraSliderScale / (radius * 2)
    shape.scaleY = shape.scaleX

    # shape.scaleX = 1 / 100
    # shape.scaleY = shape.scaleX

    shape
