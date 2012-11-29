class @TreasuresTray extends FW.ContainerProxy
  constructor: (originalTreasures) ->
    super()

    treasures = for originalTreasure in originalTreasures
      treasure = originalTreasure.clone()

    tray = @
    numTreasures = treasures.length
    treasureXOffset = -numTreasures / 2
    for treasure, i in treasures
      tray.addChild(treasure)
      treasure.x = i + treasureXOffset

    @_originalTreasures = originalTreasures
