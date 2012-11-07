Maze = @Maze ||= {}

# Structures
Maze.Structures = {}
Maze.Structures.GraphPaper =
  directions: (i) ->
    [
      0 # NORTH
      1 # EAST
      2 # SOUTH
      3 # WEST
    ]

  # Perimeter is enforced as invalid translation result
  translateDirection: (i, direction) ->
    [x, y] = indexToCoords(@, i)
    width = @width
    height = @height

    switch direction
      when 0 # NORTH
        if y > 0
          i - width
      when 1 # EAST
        if x < width - 1
          i + 1
      when 2 # SOUTH
        if y < height - 1
          i + width
      when 3 # WEST
        if x > 0
          i - 1

Maze.Structures.SawTooth =
  directions: (i) ->
    [ 0, 1, 2 ]

  translateDirection: (i, direction) ->
    width = @width
    height = @height

    mazeCol = i % width
    mazeRow = Math.floor(i / width)
    pointDown = (mazeRow % 2 == 0)

    switch direction
      when 0
        if pointDown
          if mazeRow > 0
            i - width
        else
          if mazeRow < height - 1
            i + width
      when 1
        if pointDown
          i + width
        else
          i - width
      when 2
        if pointDown
          if mazeCol > 0
            i + (width - 1)
        else
          if mazeCol < width - 1
            i - (width - 1)

Maze.Structures.FoldedHexagon = $.extend {}, Maze.Structures.GraphPaper,
  translateDirection: (i, direction) ->
    [x, y] = indexToCoords(@, i)
    width = @width
    height = @height

    halfWidth = width / 2
    halfHeight = height / 2
    startingNorthWarpIndex = halfHeight * width
    endingNorthWarpIndex = startingNorthWarpIndex + halfWidth - 1

    mirror = false
    switch direction
      when 0
        if (y == halfHeight && i >= startingNorthWarpIndex && i <= endingNorthWarpIndex)
          mirror = true
      when 3
        if x == halfWidth && y < halfHeight
          mirror = true

    if mirror
      x * width + y
    else
      # Rely on the GraphPaper template translation
      return Maze.Structures.GraphPaper.translateDirection.call(@, i, direction)

  initialIndex: () ->
    (@height - 1) * @width + 1

indexToCoords = (maze, i) ->
  width = maze.width
  height = maze.height
  x = i % width
  y = Math.floor(i / width)
  [ x, y ]

Maze.Structures.Substrate = $.extend {},
  initialize: ->
    # Okay, let's have some fun with this image
    substratePixelsPerMeter = @substratePixelsPerMeter ||= 1

    bitmap = @substrateBitmap

    image = bitmap.image
    # Underlying grid width and height
    imageWidth = image.width
    imageHeight = image.height
    width = Math.ceil(imageWidth / substratePixelsPerMeter) * @projection.columnWidth
    height = Math.ceil(imageHeight / substratePixelsPerMeter) * @projection.rowHeight
    @width = width
    @height = height

    # Blue dot is the start
    rect = FW.CreateJS.getFuzzyColorBoundsRect(bitmap, 0, 0, 255, 255, 32)
    if rect
      [x, y] = FW.Math.centroidOfRectangle(rect)
      x - imageWidth / 2
      y - imageHeight / 2
      @_initialIndex = @projection.infer(@, (x - imageWidth / 2) / substratePixelsPerMeter, (y - imageHeight / 2) / substratePixelsPerMeter)

  initialIndex: ->
    @_initialIndex

  avoid: (maze, i) ->
    cache = @_substrateAvoidCache ||= []
    if cache[i] == undefined
      segments = maze.projection.project(maze, i, true)
      [ red, green, blue, alpha ] = FW.CreateJS.getColorWithinSegments(segments, @substrateBitmap)

      # Avoid transparent cells
      if alpha >= 128
        cache[i] = false
      else
        cache[i] = true

    cache[i]
