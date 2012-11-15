FW = @FW ||= {}

class FW.ContainerProxy
  constructor: () ->
    container = new createjs.Container()
    @_container = container
    instance = @

    parent = undefined
    Object.defineProperty @, 'parent'
      get: -> parent
      set: (value) ->
        if parent
          parent.removeChild(container)
        parent = value
        if parent
          parent.addChild(container)

    FW.ProxyProperties(instance, container, [ 'x', 'y', 'regX', 'regY', 'scaleX', 'scaleY' ])

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