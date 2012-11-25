class @ProfilePickerScreen extends FW.ContainerProxy
  constructor: (game, hci) ->
    super()

    screen = @
    profilesData = hci.loadProfilesData()

    sceneManager = game.getSceneManager()
    titleBox = new TitleBox()
    profilesData = hci.loadProfilesData()
    profilePicker = setupProfilePicker(screen, profilesData)
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
      [ "keyDown:#{FW.HCI.KeyMap.ENTER}",  -> onPressedEnter(screen) ]
      [ "keyDown:#{FW.HCI.KeyMap.ESCAPE}", -> onPressedEscape(screen) ]
      [ "keyDown:#{FW.HCI.KeyMap.LEFT}",   -> profilePicker.selectPrevious() ]
      [ "keyDown:#{FW.HCI.KeyMap.RIGHT}",  -> profilePicker.selectNext() ]
    )

  onLeaveScene: ->
    @_hciSet.off()

  setProfileData: (profileName, profileData) ->
    @_game.setProfileData(profileName, profileData)

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
    [ profileName, profileData ] = profilePicker.getCurrentProfileData()
    screen.setProfileData(profileName, profileData)

onPressedEscape = (screen) ->
  # Something?

setupProfilePicker = (screen, profilesData) ->
  profilesDataByCreatedAt = FW.Util.mapToArraySortedByAttribute(profilesData, 'created_at', true)
  profilePicker = new ProfilePicker(profilesDataByCreatedAt, 0)
  profilePicker.addEventListener "tick", ->
    profilesVisibleOnScreen = 2

    canvas = screen.getStage().canvas
    profilePicker.scaleX = Math.min(canvas.width, canvas.height) / profilesVisibleOnScreen
    profilePicker.scaleY = profilePicker.scaleX

    profilePicker.x = canvas.width / 2
    profilePicker.y = canvas.width / 20 + canvas.height / 10

  profilePicker

setupAddNewProfileInput = (hci, sceneManager, profilePicker) ->
  createNewProfile = (profileName) ->
    profileData = {
      name: profileName
      created_at: FW.Time.now()
    }
    hci.saveProfile(profileName, profileData)

    profilePicker.unshiftNewProfile(profileName, profileData)
    sceneManager.popScene()

    inputOverlay.setValue("")

  cancelAddNewProfile = ->
    sceneManager.popScene()

  inputOverlay = new InputOverlay(hci, "What's your name?", "", createNewProfile, cancelAddNewProfile)

  inputOverlay
