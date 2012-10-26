FW = @FW ||= {}

class FW.ContainerProxy
  constructor: () ->
    container = new createjs.Container()
    @_container = container

    parent = undefined
    Object.defineProperty @, 'parent'
      get: -> parent
      set: (value) ->
        if parent
          parent.removeChild(container)
        parent = value
        if parent
          parent.addChild(container)

    FW.ProxyProperties(@, container, [ 'regX', 'regY' ])

  isVisible: ->
    @_container?.isVisible()

  addChild: (child) ->
    @_container?.addChild(child)

  removeChild: (child) ->
    @_container?.removeChild(child)


  updateContext: ->

  draw: ->