class @PauseMenu extends FW.ContainerProxy
  constructor: (game, hci) ->
    super()

    pausedTitle = setupPausedTitle()

    @addChild(pausedTitle)

    @_game = game
    @_hci = hci
    @_pausedTitle = pausedTitle

  onEnterScene: ->
    pauseMenu = @

    @_hciSet = @_hci.on(
      # [ "keyDown:#{FW.HCI.KeyMap.ENTER}",  -> onPressedEnter(screen) ]
      [ "keyDown:#{FW.HCI.KeyMap.ESCAPE}", -> onPressedEscape(pauseMenu) ]
      # [ "keyDown:#{FW.HCI.KeyMap.LEFT}",   -> profilePicker.selectPrevious() ]
      # [ "keyDown:#{FW.HCI.KeyMap.RIGHT}",  -> profilePicker.selectNext() ]
    )

  onLeaveScene: ->
    @_hciSet.off()

  onTick: ->
    super()

    stage = @getStage()
    return unless stage

    canvas = stage.canvas

    pausedTitle = @_pausedTitle

    pausedTitle.x = canvas.width / 2
    pausedTitle.y = 48

setupPausedTitle = ->
  text = TextFactory.create("Paused")
  text

onPressedEscape = (pauseMenu) ->
  sceneManager = pauseMenu._game.getSceneManager()
  sceneManager.popScene()
