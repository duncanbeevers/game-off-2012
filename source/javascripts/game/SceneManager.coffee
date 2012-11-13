class @SceneManager
  constructor: (stage) ->
    @_stage = stage
    @_scenes = {}

  addScene: (sceneName, scene) ->
    @_scenes[sceneName] = scene

  gotoScene: (sceneName) ->
    stage = @_stage
    currentScene = @_currentScene
    newScene = @_scenes[sceneName]

    # A bit abrupt...
    stage.removeChild(currentScene)
    stage.addChild(newScene)

    @_currentScene = newScene