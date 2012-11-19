class @ProfilePickerScreen extends FW.ContainerProxy
  constructor: (game, hci, sceneManager) ->
    super()

    screen = @

    titleBox = new TitleBox()
    profilePicker = setupProfilePicker(screen)
    addNewProfileInput = setupAddNewProfileInput(hci, sceneManager)

    screen.addChild(profilePicker)
    screen.addChild(titleBox)

    sceneManager.addScene("newProfileInput", addNewProfileInput)

    @_game = game
    @_hci = hci
    @_sceneManager = sceneManager
    @_profilePicker = profilePicker
    @_addNewProfileInput = addNewProfileInput

  onEnterScene: ->
    profilePicker = @_profilePicker
    sceneManager = @_sceneManager
    addNewProfileInput = @_addNewProfileInput

    @_hciSet = @_hci.on(
      [ "keyDown:#{FW.HCI.KeyMap.ENTER}", -> onPressedEnter(sceneManager, profilePicker, addNewProfileInput) ]
      [ "keyDown:#{FW.HCI.KeyMap.LEFT}",  -> profilePicker.selectPrevious() ]
      [ "keyDown:#{FW.HCI.KeyMap.RIGHT}", -> profilePicker.selectNext() ]
    )

  onLeaveScene: ->
    @_hciSet.off()

onPressedEnter = (sceneManager, profilePicker, addNewProfileInput) ->
  index = profilePicker.getCurrentIndex()
  length = profilePicker.getLength()

  if index == length - 1
    # Last item is Add New Profile
    sceneManager.pushScene("newProfileInput")
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

setupAddNewProfileInput = (hci, sceneManager) ->
  createNewProfile = (profileName) ->
    sceneManager.popScene()

    inputOverlay.setValue("")

  cancelAddNewProfile = ->
    sceneManager.popScene()

  inputOverlay = new InputOverlay(hci, "Profile Name", "", createNewProfile, cancelAddNewProfile)

  inputOverlay
