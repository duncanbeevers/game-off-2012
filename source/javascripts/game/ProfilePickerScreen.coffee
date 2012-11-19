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

  onEnterScene: ->
    profilePicker = @_profilePicker

    @_hciSet = @_hci.on(
      [ "keyDown:#{FW.HCI.KeyMap.ENTER}", -> onPressedEnter(profilePicker) ]
      [ "keyDown:#{FW.HCI.KeyMap.LEFT}",  -> profilePicker.selectPrevious() ]
      [ "keyDown:#{FW.HCI.KeyMap.RIGHT}", -> profilePicker.selectNext() ]
    )

  onLeaveScene: ->
    @_hciSet.off()

onPressedEnter = (profilePicker) ->
  index = profilePicker.getCurrentIndex()
  length = profilePicker.getLength()

  if index == length - 1
    # Last item is Add New Profile
  else
    # Otherwise we're loading an existing profile


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
