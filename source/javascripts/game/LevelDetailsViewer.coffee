class @LevelDetailsViewer extends FW.ContainerProxy
  constructor: ->
    super()

    bestText                 = TextFactory.create("")
    bestCompletionTimeText   = TextFactory.create("")
    bestWallImpactsCountText = TextFactory.create("")

    bestText.y                 = -36
    bestCompletionTimeText.y   = 0
    bestWallImpactsCountText.y = 36

    @addChild(bestText)
    @addChild(bestCompletionTimeText)
    @addChild(bestWallImpactsCountText)

    @_bestText                 = bestText
    @_bestCompletionTimeText   = bestCompletionTimeText
    @_bestWallImpactsCountText = bestWallImpactsCountText

  setLevelData: (levelData) ->
    @_levelData = levelData
    @updateDisplay()

  setProfileData: (profileData) ->
    @_profileData = profileData
    @updateDisplay()

  updateDisplay: ->
    levelData   = @_levelData
    profileData = @_profileData

    if levelData && profileData
      bestText                 = @_bestText
      bestCompletionTimeText   = @_bestCompletionTimeText
      bestWallImpactsCountText = @_bestWallImpactsCountText
      profileLevelsData        = profileData.levels || {}
      profileLevelData         = profileLevelsData[levelData.name]
      if profileLevelData
        bestCompletionTime            = profileLevelData.bestCompletionTime
        bestWallImpactsCount          = profileLevelData.bestWallImpactsCount
        if bestWallImpactsCount == 1
          hitText = "hit"
        else
          hitText = "hits"

        bestText.text                 = "Best"
        bestCompletionTimeText.text   = FW.Time.clockFormat(bestCompletionTime)
        bestWallImpactsCountText.text = bestWallImpactsCount + " " + hitText
      else
        bestText.text                 = "Begin"
        bestCompletionTimeText.text   = ""
        bestWallImpactsCountText.text = ""
