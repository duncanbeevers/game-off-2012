window = @
localStorage = window.localStorage
localStorageProfilesKey = "mazeoid:profiles"

# Generate an HCI instance bound to DOM events by jQuery
$.FW_HCI = ->
  hci = new FW.HCI.HCI()

  onVisibilityChange = (event) ->
    documentHidden = document.hidden || document.webkitHidden

    if documentHidden
      hci.windowBecameVisible()
    else
      hci.windowBecameInvisible()

  $document = $(document)
  $document.on "visibilitychange",       onVisibilityChange
  $document.on "webkitvisibilitychange", onVisibilityChange

  $document.on "keydown", (event) ->
    keyCode = event.keyCode

    hci.triggerKeyDown(event.keyCode)
    if keyCode != 91
      event.preventDefault()

  $document.on "keyup",   (event) ->
    keyCode = event.keyCode

    hci.triggerKeyUp(event.keyCode)
    if keyCode != 91
      event.preventDefault()

  $document.on "touchmove", (event) -> event.preventDefault()

  hci.saveProfile = (profileName, profileData) ->
    # Get the current profiles
    profilesData = loadProfilesData()
    profilesData[profileName] = profileData
    localStorage.setItem(localStorageProfilesKey, JSON.stringify(profilesData))

  hci.loadProfilesData = loadProfilesData

  return hci

loadProfilesData = () ->
  try
    JSON.parse(localStorage.getItem(localStorageProfilesKey)) || {}
  catch _
    {}

