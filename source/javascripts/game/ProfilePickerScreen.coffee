class @ProfilePickerScreen extends FW.ContainerProxy
  constructor: (game, hci) ->
    super()

    screen = @

    sceneManager = game.getSceneManager()
    titleBox = new TitleBox()
    profilePicker = setupProfilePicker(screen)
    addNewProfileInput = setupAddNewProfileInput(hci, sceneManager, profilePicker)

    screen.addChild(profilePicker)
    screen.addChild(titleBox)

    sceneManager.addScene("newProfileInput", addNewProfileInput)

    @_game               = game
    @_hci                = hci
    @_sceneManager       = sceneManager
    @_profilePicker      = profilePicker
    @_addNewProfileInput = addNewProfileInput

  onEnterScene: ->
    screen = @
    profilePicker = @_profilePicker

    @_hciSet = @_hci.on(
      [ "keyDown:#{FW.HCI.KeyMap.ENTER}", -> onPressedEnter(screen) ]
      [ "keyDown:#{FW.HCI.KeyMap.LEFT}",  -> profilePicker.selectPrevious() ]
      [ "keyDown:#{FW.HCI.KeyMap.RIGHT}", -> profilePicker.selectNext() ]
    )

  onLeaveScene: ->
    @_hciSet.off()

  loadProfile: (profileData) ->
    @_game.loadProfile(profileData)

onPressedEnter = (screen) ->
  profilePicker      = screen._profilePicker
  sceneManager       = screen._sceneManager
  addNewProfileInput = screen._addNewProfileInput

  index  = profilePicker.getCurrentIndex()
  length = profilePicker.getLength()

  if index == length - 1
    # Last item is Add New Profile
    sceneManager.pushScene("newProfileInput")
  else
    # Otherwise we're loading an existing profile
    profileData = profilePicker.getCurrentProfileData()
    screen.loadProfile(profileData)

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

setupAddNewProfileInput = (hci, sceneManager, profilePicker) ->
  createNewProfile = (profileName) ->
    profilePicker.unshiftNewProfile(profileName)
    sceneManager.popScene()

    inputOverlay.setValue("")

  cancelAddNewProfile = ->
    sceneManager.popScene()

  inputOverlay = new InputOverlay(hci, "What's your name?", "", createNewProfile, cancelAddNewProfile)

  inputOverlay
