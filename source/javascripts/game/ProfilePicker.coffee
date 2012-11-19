settings =
  color: "#0FFFFA"

# FW.dat.GUI.addSettings(settings)

class @ProfilePicker extends SliderPicker
  constructor: (profilesData, currentIndex) ->
    sliderElements = for profileData, i in profilesData
      text: profileData.name
      displayObject: createProfileDisplayObject(@, profileData, i)

    addNewProfileDisplayObject = createAddNewProfileDisplayObject()
    sliderElements.push(
      text: "Add New Profile"
      displayObject: addNewProfileDisplayObject
    )

    super(sliderElements, currentIndex)

    # Set instance variables
    @_profilesData = profilesData

  getCurrentProfileData: ->
    @_profilesData[@getCurrentIndex()]

  unshiftNewProfile: (profileName) ->
    profileData = { name: profileName }

    sliderElement =
      text: profileName
      displayObject: createProfileDisplayObject(@, profileData)

    @unshiftElement(sliderElement)
    @_currentIndex = 0
    @_profilesData.unshift(profileData)

createProfileDisplayObject = (profilePicker, profileData) ->
  # Draw the preview image of the maze
  shape = new createjs.Shape()
  graphics = shape.graphics

  graphics.setStrokeStyle(0.001, "round", "bevel")
  graphics.beginStroke("rgba(0, 0, 0, 0)")
  graphics.beginFill(settings.color)
  # Head
  graphics.drawCircle(0, -0.5, 0.25)
  # Shoulders
  graphics.drawCircle(-0.25, 0, 0.25)
  graphics.drawCircle(0.25, 0, 0.25)
  # Fill in torso
  graphics.drawRect(-0.25, -0.25, 0.5, 0.25)
  graphics.drawRect(-0.5, 0, 1, 0.5)

  graphics.endStroke()
  graphics.endFill()

  radius = Math.sqrt(2)

  # Scale it down to fit based on drawing boundaries
  shape.scaleX = 1 / (radius * 2)
  shape.scaleY = shape.scaleX

  shape

createAddNewProfileDisplayObject = ->
  shape = new createjs.Shape()
  graphics = shape.graphics

  graphics.setStrokeStyle(0.01, "round", "bevel")
  graphics.beginStroke(settings.color)
  graphics.beginFill(settings.color)

  graphics.drawRect(-0.25, -0.5, 0.5, 1)
  graphics.drawRect(-0.5, -0.25, 1, 0.5)

  graphics.endStroke()
  graphics.endFill()

  radius = 1

  # Scale it down to fit based on drawing boundaries
  shape.scaleX = 1 / (radius * 2)
  shape.scaleY = shape.scaleX

  shape
