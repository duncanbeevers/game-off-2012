class @ProfilePickerScreen extends FW.ContainerProxy
  constructor: (game, hci) ->
    super()

    screen = @

    titleBox = new TitleBox()
    profilePicker = setupProfilePicker(screen)

    screen.addChild(profilePicker)
    screen.addChild(titleBox)

    @_game = game
    @_hci = hci
    @_profilePicker = profilePicker

setupProfilePicker = (screen) ->
  profilePicker = new ProfilePicker([], 0)
  profilePicker.addEventListener "tick", ->
    profilesVisibleOnScreen = 3.5

    canvas = screen.getStage().canvas
    profilePicker.scaleX = canvas.width / profilesVisibleOnScreen
    profilePicker.scaleY = profilePicker.scaleX

    profilePicker.x = canvas.width / 2
    profilePicker.y = canvas.width / 20 + 150

  profilePicker
