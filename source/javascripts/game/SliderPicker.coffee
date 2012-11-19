settings =
  slider:
    intraSliderScale: 0.8
    itemsVisibleOnScreen: 2
    panningEase: 10
  sliderContainer:
    selected:
      targetScale: 4.4
      targetAlpha: 1
      targetY: 1
    unselected:
      targetScale: 1
      targetAlpha: 0.06
      targetY: 0
    zoomEase: 10
    verticalMoveEase: 10
    alphaEase: 10
  nameContainer:
    scale: 150
    alpha: 0.8
    wordVerticalSpacing: 25
    wordVerticalOffset: 10
    wordColor: "#FFFFFF"

# FW.dat.GUI.addSettings(settings)

class @SliderPicker extends FW.ContainerProxy
  constructor: (sliderElements, currentIndex) ->
    super()

    # This container holds the horizontally-arranged set of levels
    # We slide it back and forth to pan all the levels together
    sliderContainer = new createjs.Container()

    # Scale the slider to focus on a fixed range of levels
    sliderContainer.scaleX = 1 / settings.slider.itemsVisibleOnScreen
    sliderContainer.scaleY = sliderContainer.scaleX

    for sliderElement, i in sliderElements
      displayObject = sliderElementDisplayObject(@, sliderContainer, sliderElement, i)
      sliderContainer.addChild(displayObject)

    # Set instance variables
    @_sliderContainer = sliderContainer
    @_currentIndex = currentIndex
    @_length = sliderElements.length

    @addChild(sliderContainer)

  onTick: ->
    # Move the camera around over the levels container
    targetRegX = @_currentIndex
    sliderContainer = @_sliderContainer
    sliderContainer.regX += (targetRegX - sliderContainer.regX) / settings.slider.panningEase

  getCurrentIndex: () ->
    @_currentIndex

  getLength: () ->
    @_length

  selectNext: ->
    @select(@_currentIndex + 1)

  selectPrevious: ->
    @select(@_currentIndex - 1)

  select: (i) ->
    @_currentIndex = FW.Math.clamp(i, 0, @_length - 1)

sliderElementDisplayObject = (sliderPicker, sliderContainer, sliderElement, index) ->
  text = sliderElement.text
  displayObject = sliderElement.displayObject

  # Make a new container for this slider element
  container = new createjs.Container()
  container.x = index
  container.scaleX = settings.slider.intraSliderScale
  container.scaleY = container.scaleX

  # Create the text label
  nameContainer = new createjs.Container()
  words = text.split(/\s+/)
  texts = for word, i in words
    text = new createjs.Text(word)
    text.font = "48px Upheaval"
    text.textAlign = "center"
    text.textBaseline = "middle"
    nameContainer.addChild(text)

  # Setup the transition animations
  container.addEventListener "tick", ->
    for text, i in texts
      text.y     = i * settings.nameContainer.wordVerticalSpacing + settings.nameContainer.wordVerticalOffset
      text.color = settings.nameContainer.wordColor

    # TODO: Make this more robust, deal with dynamic inserted and removed elements
    if sliderPicker.getCurrentIndex() == index
      targetScale = settings.sliderContainer.selected.targetScale
      targetAlpha = settings.sliderContainer.selected.targetAlpha
      targetY     = settings.sliderContainer.selected.targetY
    else
      targetScale = settings.sliderContainer.unselected.targetScale
      targetAlpha = settings.sliderContainer.unselected.targetAlpha
      targetY     = settings.sliderContainer.unselected.targetY

    container.scaleX += (targetScale - container.scaleX) / settings.sliderContainer.zoomEase
    container.scaleY = container.scaleX
    container.y      += (targetY - container.y) / settings.sliderContainer.verticalMoveEase
    container.alpha  += (targetAlpha - container.alpha) / settings.sliderContainer.alphaEase

    nameContainer.scaleX = 1 / settings.nameContainer.scale
    nameContainer.scaleY = nameContainer.scaleX
    nameContainer.regY   = (words.length * settings.nameContainer.wordVerticalSpacing) / 2
    nameContainer.alpha  = settings.nameContainer.alpha

  # Add the display object and label to a single container
  container.addChild(displayObject)
  container.addChild(nameContainer)

  # Hand the assembled container back
  container
