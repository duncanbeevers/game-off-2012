settings =
  polyStarPointCountOffset: 2.2
  polyStarPointCountScalar: 1.1
  polyStarPointSize: 0.06

FW.dat.GUI.addSettings(settings)

class @Treasure extends FW.ContainerProxy
  constructor: (index, numTreasures) ->
    super()

    shape = new createjs.Shape()

    @addChild(shape)

    @_numTreasures = numTreasures
    @_index        = index
    @_shape        = shape

  # For collisions
  name: "Treasure"

  onTick: ->
    super()

    body     = @fixture.GetBody()
    position = body.GetPosition()

    @x = position.x
    @y = position.y

    numTreasures = @_numTreasures
    index        = @_index
    shape        = @_shape

    graphics = shape.graphics
    points1  = index * settings.polyStarPointCountScalar + settings.polyStarPointCountOffset
    points2  = index + settings.polyStarPointCountOffset
    hsv1 = {
      h: i * numTreasures / 360
      s: 1
      v: 0.7
    }
    hsv2 = {
      h: (i + 0.3) * numTreasures / 360
      s: 1
      v: 0.6
    }
    rgb1 = FW.Util.hsv2rgb(hsv1)
    rgb2 = FW.Util.hsv2rgb(hsv2)
    color1 = "rgba(#{Math.floor(rgb1.r)},#{Math.floor(rgb1.g)},#{Math.floor(rgb1.b)},0.8)"
    color2 = "rgba(#{Math.floor(rgb2.r)},#{Math.floor(rgb2.g)},#{Math.floor(rgb2.b)},0.3)"

    graphics.clear()

    graphics.beginFill(color1)
    graphics.drawPolyStar(0, 0, 0.3, points1, settings.polyStarPointSize)
    graphics.endFill()

    graphics.beginFill(color2)
    graphics.drawPolyStar(0, 0, 0.3, points2, settings.polyStarPointSize)
    graphics.endFill()

    @angle = FW.Math.wrapToCircleDegrees(@angle + 2)
