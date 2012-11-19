settings =
  selected:
    rotation: 0.32
  unselected:
    rotation: 0.3
  mazeColor: "#0FFFFA"
# FW.dat.GUI.addSettings(settings)

class @LevelPicker extends SliderPicker
  constructor: (levelsData, currentIndex) ->
    sliderElements = for levelData, i in levelsData
      text: levelData.name
      displayObject: createLevelDisplayObject(@, levelData, i)

    super(sliderElements, currentIndex)

    # Set instance variables
    @_levelsData = levelsData

  currentLevelData: ->
    @_levelsData[@getCurrentIndex()]

createLevelDisplayObject = (levelPicker, levelData, index) ->
  # Draw the preview image of the maze
  shape = new createjs.Shape()
  graphics = shape.graphics
  [ _, _, _, _, radius ] = FW.CreateJS.drawSegments(graphics, settings.mazeColor, levelData.segments)

  # Scale it down to fit based on drawing boundaries
  shape.scaleX = 1 / (radius * 2)
  shape.scaleY = shape.scaleX

  # TODO: Cache bitmap here? It acts funny,
  # not drawing the cached representation in the right place
  # shape.cache(-radius, -radius, 2 * radius, 2 * radius, 16)

  # Specific SliderPicker changes for child display objects
  shape.addEventListener "tick", ->
    if levelPicker.getCurrentIndex() == index
      shape.rotation += settings.selected.rotation
    else
      shape.rotation += settings.unselected.rotation

  shape
