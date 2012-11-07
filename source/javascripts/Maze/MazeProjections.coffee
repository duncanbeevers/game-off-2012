Maze = @Maze ||= {}
Maze.Projections = Maze.Projections ||= {}

mazeCell = (maze, i, cache) ->
  if cache
    forceEnclose = false
  else
    forceEnclose = true

  maze.cell(i, forceEnclose)


class BaseProjection
  segmentsForCellCircuit: (i, cell, points, cache) ->
    segments = []

    for direction, _i in cell
      [x, y] = points[_i]
      [_x, _y] = points[(_i + 1) % points.length]

      [destination, open] = cell[_i]

      if !open
        if destination == undefined
          drawWall = true
        else if cache
          key = [ i, destination ].sort().join(":")
          drawWall = !cache[key]
          cache[key] = true
        else
          drawWall = true

        if drawWall
          segments.push([ x, y, _x, _y ])

      [_x, _y] = [x, y]

    segments

class Maze.Projections.GraphPaper extends BaseProjection
  project: (maze, i, cache) ->
    cell = mazeCell(maze, i, cache)
    width = maze.width
    height = maze.height
    halfWidth = width / 2
    halfHeight = height / 2

    x = i % width - halfWidth
    y = Math.floor(i / width) - halfHeight

    @segmentsForCellCircuit(i, cell, [
      [ x, y ]
      [ x + 1, y ]
      [ x + 1, y + 1 ]
      [ x, y + 1 ]
    ], cache)

  infer: (maze, x, y) ->
    Math.floor(y + maze.height / 2) * maze.width + Math.floor(x + maze.width / 2)

class Maze.Projections.SawTooth extends BaseProjection
  project: (maze, i, cache) ->
    cell = mazeCell(maze, i, cache)
    mazeCol = i % maze.width
    mazeRow = Math.floor(i / maze.width)

    pointUp = mazeRow % 2

    x = mazeCol - maze.width / 2
    y = Math.floor(mazeRow / 2) - maze.height / 4

    if pointUp
      @segmentsForCellCircuit(i, cell, [
        [ x + 1, y + 1 ]
        [ x, y + 1 ]
        [ x + 1, y ]
      ], cache)
    else
      @segmentsForCellCircuit(i, cell, [
        [ x, y ]
        [ x + 1, y ]
        [ x, y + 1 ]
      ], cache)

class Maze.Projections.SlantedSawTooth extends BaseProjection
  constructor: (options) ->
    options ||= {}
    @peakAngle = FW.Math.clamp(options.peakAngle || 60, 15, 175)
    halfBaseWidth = Math.sin(@peakAngle / 2 * FW.Math.DEG_TO_RAD)
    @_baseWidth = halfBaseWidth * 2
    @_rowHeight = 1 - halfBaseWidth

  project: (maze, i, cache) ->
    baseWidth = @_baseWidth
    rowHeight = @_rowHeight
    cell = mazeCell(maze, i, cache)
    mazeCol = i % maze.width
    mazeRow = Math.floor(i / maze.width)
    mazeWidth = (Math.floor(maze.height / 2) + maze.width) * baseWidth
    mazeHeight = maze.height * rowHeight / 2

    pointUp = mazeRow % 2

    x = (mazeCol * baseWidth) +
        Math.floor((mazeRow + 1) / 2) * (baseWidth / 2) -
        mazeWidth / 2

    y = Math.floor(mazeRow / 2) * rowHeight - mazeHeight / 2

    if pointUp
      @segmentsForCellCircuit(i, cell, [
        [ x + baseWidth, y + rowHeight ]
        [ x, y + rowHeight ]
        [ x + baseWidth / 2, y ]
      ], cache)
    else
      @segmentsForCellCircuit(i, cell, [
        [ x, y ]
        [ x + baseWidth, y ]
        [ x + baseWidth / 2, y + rowHeight ]
      ], cache)



class Maze.Projections.FoldedHexagonCell extends BaseProjection
  project: (maze, i, cache) ->
    cell = mazeCell(maze, i, cache)
    mazeX = i % maze.width
    mazeY = Math.floor(i / maze.width)

    # Determine which quadrant we're drawing in
    height = maze.height
    width = maze.width
    halfHeight = height / 2
    halfWidth = width / 2

    if mazeY < halfHeight
      if mazeX < halfWidth
        quadrant = 0 # NW Quadrant, should never happen
      else
        quadrant = 1 # NE Quadrant
    else
      if mazeX < halfWidth
        quadrant = 2 # SW Quadrant
      else
        quadrant = 3 # SE Quadrant

    sixtyDegrees = (Math.PI / 180) * 60
    smallSkew = Math.cos(sixtyDegrees)
    bigSkew = Math.sin(sixtyDegrees)

    reflectionX = bigSkew * halfWidth

    switch quadrant
      when 1 # NE
        x = mazeX * bigSkew - (bigSkew * halfWidth)
        y = smallSkew * (mazeX - halfWidth) + mazeY - halfWidth
        @segmentsForCellCircuit(i, cell, [
          [ x, y ]
          [ x + bigSkew, y + smallSkew ]
          [ x + bigSkew, y + smallSkew + 1 ]
          [ x, y + 1]
        ], cache)

      when 2 # SW
        x = (height - mazeY) * bigSkew - (bigSkew * halfWidth)
        y = mazeX + (mazeY - halfHeight) * smallSkew - halfWidth
        @segmentsForCellCircuit(i, cell, [
          [ x, y ]
          [ x, y + 1 ]
          [ x - bigSkew, y + 1 + smallSkew ]
          [ x - bigSkew, y + smallSkew ]
        ], cache)

      when 3 # SE
        x = (mazeX - halfWidth) * bigSkew + reflectionX - (mazeY - halfHeight) * bigSkew - (bigSkew * halfWidth)
        y = (mazeX - halfWidth) * smallSkew + (mazeY - halfHeight) * smallSkew + halfWidth - halfWidth

        @segmentsForCellCircuit(i, cell, [
          [ x, y ]
          [ x + bigSkew, y + smallSkew ]
          [ x, y + smallSkew * 2 ]
          [ x - bigSkew, y + smallSkew ]
        ], cache)
  infer: ->
    # Not implemented