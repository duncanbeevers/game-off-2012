FW = @FW ||= {}

class FW.ContainerProxy
  constructor: () ->
    container = new createjs.Container()
    @_container = container
    instance = @

    onAddedAsChild = (parent) ->
      createjs.Ticker.addListener(instance)
      instance.onAddedAsChild?(parent)

    onRemovedAsChild = (parent) ->
      createjs.Ticker.removeListener(instance)
      instance.onRemovedAsChild?(parent)

    parent = undefined
    Object.defineProperty @, 'parent'
      get: -> parent
      set: (value) ->
        if parent
          parent.removeChild(container)
          onRemovedAsChild(parent)
        parent = value
        if parent
          parent.addChild(container)
          onAddedAsChild(parent)

    FW.ProxyProperties(instance, container, [ 'x', 'y', 'regX', 'regY' ])

  getStage: ->
    @_container?.getStage()

  isVisible: ->
    @_container?.isVisible()

  addChild: (child) ->
    @_container?.addChild(child)

  removeChild: (child) ->
    @_container?.removeChild(child)

  updateContext: ->

  draw: ->