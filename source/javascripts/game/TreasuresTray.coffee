class @TreasuresTray extends FW.ContainerProxy
  constructor: (originalTreasures) ->
    super()

    treasures = for originalTreasure in originalTreasures
      originalTreasure.clone()

    tray = new createjs.Container()
    tray.scaleX = 1 / numTreasures
    tray.scaleY = tray.scaleX

    numTreasures = treasures.length
    # treasureXOffset = -numTreasures / 2 # Center-aligned
    treasureXOffset = 0 # Left-aligned
    for treasure, i in treasures
      tray.addChild(treasure)
      treasure.x = i + treasureXOffset

    @addChild(tray)

    @_originalTreasures = originalTreasures
    @_treasures = treasures

  onTick: ->
    super()

    originalTreasures = @_originalTreasures
    treasures = @_treasures

    for treasure, i in treasures
      if originalTreasures[i].isCollected()
        targetAlpha = 1
      else
        targetAlpha = 0.2

      treasure.alpha += (targetAlpha - treasure.alpha) / 10

  width: ->
    treasuresTray = @
    treasuresTray._treasures.length
