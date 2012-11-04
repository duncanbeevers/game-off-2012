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
  call: (maze, i, cache) ->
    cell = mazeCell(maze, i, cache)
    width = maze.width
    halfWidth = width / 2
    halfHeight = maze.height / 2

    x = i % width - halfWidth
    y = Math.floor(i / width) - halfHeight

    segments = @segmentsForCellCircuit(i, cell, [
      [ x, y ]
      [ x + 1, y ]
      [ x + 1, y + 1 ]
      [ x, y + 1 ]
    ], cache)

class Maze.Projections.FoldedHexagonCell extends BaseProjection
  call: (maze, i, cache) ->
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