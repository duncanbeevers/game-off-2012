FW = @FW ||= {}

FW.CreateJS ||= {}

drawSegments = (graphics, color, segments) ->
  graphics.setStrokeStyle(0.25, "round", "bevel")
  graphics.beginStroke(color)

  minX = Infinity
  minY = Infinity
  maxX = -Infinity
  maxY = -Infinity
  for [x1, y1, x2, y2] in segments
    graphics.moveTo(x1, y1)
    graphics.lineTo(x2, y2)
    minX = Math.min(minX, x1, x2)
    minY = Math.min(minY, y1, y2)
    maxX = Math.max(maxX, x1, x2)
    maxY = Math.max(maxY, y1, y2)

  graphics.endStroke()

  [ minX, minY, maxX, maxY ]

# Ostensibly, this should operate the same as Flash's
# getColorBoundsRect, but I ended up needing something
# a little more flexible
getColorBoundsRect = (bitmap, mask, color, findColor) ->
  getFullColorBoundsRect bitmap, (r, g, b, a, pixel) ->
    (pixel & mask) == color

getFuzzyColorBoundsRect = (bitmap, red, green, blue, alpha, threshold) ->
  getFullColorBoundsRect bitmap, (_red, _green, _blue, _alpha, pixel) ->
    redDelta   = Math.abs(red - _red)
    greenDelta = Math.abs(green - _green)
    blueDelta  = Math.abs(blue - _blue)
    alphaDelta = Math.abs(alpha - _alpha)
    maxDelta   = Math.max(redDelta, greenDelta, blueDelta, alphaDelta)
    maxDelta < threshold

getFullColorBoundsRect = (bitmap, match) ->
  image = bitmap.image
  width = image.width
  height = image.height

  if !bitmap.cacheCanvas
    bitmap.cache(0, 0, width, height)
    context = bitmap.cacheCanvas.getContext("2d")
    bitmap.cachedImageData = context.getImageData(0, 0, width, height)

  minX = Infinity
  minY = Infinity
  maxX = -Infinity
  maxY = -Infinity

  data = bitmap.cachedImageData.data

  for y in [0...height]
    for x in [0...width]
      i = (x + y * width) * 4
      red   = data[i]
      green = data[i + 1]
      blue  = data[i + 2]
      alpha = data[i + 3]
      pixel = red << 24 + green << 16 + blue << 8 + alpha


      if match(red, green, blue, alpha, pixel)
        minX = Math.min(minX, x)
        minY = Math.min(minY, y)
        maxX = Math.max(maxX, x)
        maxY = Math.max(maxY, y)

  if minX < Infinity
    new createjs.Rectangle(minX, minY, maxX - minX, maxY - minY)
  else
    null

getColorWithinSegments = (segments, bitmap) ->
  xOffset = bitmap.regX
  yOffset = bitmap.regY
  xScale = bitmap.scaleX
  yScale = bitmap.scaleY

  # Naive AABB approach for now, should be decent
  minX = Infinity
  maxX = -Infinity
  minY = Infinity
  maxY = -Infinity
  for [x1, y1, x2, y2] in segments
    minX = Math.min(minX, x1, x2)
    maxX = Math.max(maxX, x1, x2)
    minY = Math.min(minY, y1, y2)
    maxY = Math.max(maxY, y1, y2)

  x1 = Math.floor(minX / xScale) + xOffset
  y1 = Math.floor(minY / yScale) + yOffset
  x2 = Math.floor(maxX / xScale) + xOffset
  y2 = Math.floor(maxY / yScale) + yOffset

  imageData = bitmap.cachedImageData
  data      = imageData.data
  redSum    = 0
  greenSum  = 0
  blueSum   = 0
  alphaSum  = 0

  if segments.length
    for x in [x1..x2]
      for y in [y1..y2]
        i = ((y * imageData.width) + x) * 4
        redSum   += data[i]
        greenSum += data[i + 1]
        blueSum  += data[i + 2]
        alphaSum += data[i + 3]

    denominator = (x2 - x1 + 1) * (y2 - y1 + 1)

    redAverage   = Math.floor(redSum   / denominator)
    greenAverage = Math.floor(greenSum / denominator)
    blueAverage  = Math.floor(blueSum  / denominator)
    alphaAverage = Math.floor(alphaSum / denominator)

    [ redAverage, greenAverage, blueAverage, alphaAverage ]
  else
    [ 0, 0, 0, 0 ]

FW.CreateJS =
  drawSegments: drawSegments
  getColorBoundsRect: getColorBoundsRect
  getFuzzyColorBoundsRect: getFuzzyColorBoundsRect
  getColorWithinSegments: getColorWithinSegments
