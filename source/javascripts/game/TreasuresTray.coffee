class @TreasuresTray extends FW.ContainerProxy
  constructor: (originalTreasures) ->
    super()

    treasures = for originalTreasure in originalTreasures
      originalTreasure.clone()

    tray = new createjs.Container()
    tray.scaleX = 1 / numTreasures
    tray.scaleY = tray.scaleX

    numTreasures = treasures.length
    treasureXOffset = -numTreasures / 2
    for treasure, i in treasures
      tray.addChild(treasure)
      treasure.x = i + treasureXOffset

    @addChild(tray)

    @_originalTreasures = originalTreasures
