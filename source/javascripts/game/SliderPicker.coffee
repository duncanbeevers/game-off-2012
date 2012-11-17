settings =
  slider:
    intraSliderScale: 0.8
    itemsVisibleOnScreen: 2
    panningEase: 10

# FW.dat.GUI.addSettings(settings)

class @SliderPicker extends FW.ContainerProxy
  constructor: (screen, displayObjects, currentIndex) ->
    super()

    # This container holds the horizontally-arranged set of levels
    # We slide it back and forth to pan all the levels together
    sliderContainer = new createjs.Container()
    @addChild(sliderContainer)

    # Scale the slider to focus on a fixed range of levels
    sliderContainer.scaleX = 1 / settings.slider.itemsVisibleOnScreen
    sliderContainer.scaleY = sliderContainer.scaleX

    for displayObject in displayObjects
      sliderContainer.addChild(displayObject)

    # Set instance variables
    @_screen = screen
    @_sliderContainer = sliderContainer
    @_displayObjects = displayObjects
    @_currentIndex = currentIndex

  onTick: ->
    # Move the camera around over the levels container
    targetRegX = @_currentIndex
    sliderContainer = @_sliderContainer
    sliderContainer.regX += (targetRegX - sliderContainer.regX) / settings.slider.panningEase

  currentIndex: () ->
    @_currentIndex

  selectNext: ->
    @select(@_currentIndex + 1)

  selectPrevious: ->
    @select(@_currentIndex - 1)

  select: (i) ->
    @_currentIndex = FW.Math.clamp(i, 0, @_displayObjects.length - 1)

  checkSelected: (displayObject) ->
    @_currentIndex == @_displayObjects.indexOf(displayObject)
