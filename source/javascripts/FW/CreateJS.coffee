FW = @FW ||= {}

FW.CreateJS ||= {}

FW.CreateJS.drawSegments = (graphics, color, segments) ->
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