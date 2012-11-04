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
      # y * width + x
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
