generateMaze = (maze, done) ->
  recurse(maze, maze.initialIndex(), false)

recurse = (maze, i, didBacktrack) ->
  # Track whether we are back at the beginning
  # (ie, stack is empty and no direction to turn)
  bottomedOut = false
  if !didBacktrack
    markTraversed(maze, i)

  # From where we are, pick at random, a valid direction to travel in
  direction = pickDirection(maze, i)

  # If a valid direction was found, continue on our merry way
  if direction != undefined
    didBacktrack = false
    # Remember where we were, cause we're outta here
    maze.stack ||= []
    maze.stack.push(i)

    newI = translateDirection(maze, i, direction)

    addTunnel(maze, i, newI)
  else
    projectAndDrawMazeCell(maze, i)
    # Oh no! Nowhere to turn!
    # Backtrack until we find a spot to branch off again
    if maze.stack && maze.stack.length
      if !didBacktrack
        didBacktrack = true
        maze.terminations ||= []
        pathLength = maze.stack.length
        indexLengthPair = [ i, pathLength ]
        maze.terminations.push indexLengthPair

        if !maze.maxTermination || maze.maxTermination[1] < pathLength
          maze.maxTermination = indexLengthPair

      newI = maze.stack.pop()
    else
      # Nowhere to go! At all! I guess this is it.
      bottomedOut = true

  if bottomedOut
    # Well, let's tell everyone about it
    maze.done(maze)
  else
    # We must continue on, so we hand the keys off to the
    # step call, confident our work will be continued, somehow...
    maze.step ->
      recurse(maze, newI, didBacktrack)

addTunnel = (maze, i1, i2) ->
  maze.tunnels ||= {}
  maze.tunnels[normalizeTunnelName(i1, i2)] = true

hasTunnel = (maze, i1, i2) ->
  tunnels = maze.tunnels
  if tunnels
    tunnels[normalizeTunnelName(i1, i2)]

normalizeTunnelName = (i1, i2) ->
  [ i1, i2 ].sort().join(":")

markTraversed = (maze, i) ->
  traversed = maze.traversed ||= {}
  traversed[i] = true

translateDirection = (maze, i, direction) ->
  maze.translateDirection(i, direction)

hasBeenTraversed = (maze, i) ->
  traversed = maze.traversed
  traversed && traversed[i]

validDirection = (maze, currentIndex, direction) ->
  i = translateDirection(maze, currentIndex, direction)

  return false if i == undefined
  return false if maze.avoid(maze, i)
  return false if hasBeenTraversed(maze, i)
  true

validTranslateDirections = (maze, currentIndex) ->
  for direction in maze.directions(currentIndex) when validDirection(maze, currentIndex, direction)
    direction

pickDirection = (maze, currentIndex) ->
  directions = validTranslateDirections(maze, currentIndex)
  # Pick one at random
  return directions[Math.floor(Math.random() * directions.length)]

projectAndDrawMazeCell = (maze, i) ->
  cell = for direction in maze.directions(i)
    destination = translateDirection(maze, i, direction)
    [ destination, hasTunnel(maze, i, destination) ]

  if maze.project
    projectedSegments = maze.projectedSegments || []
    cellSegments = maze.project.call(maze, i, cell)
    if maze.draw
      maze.draw(cellSegments)

    maze.projectedSegments = projectedSegments.concat(cellSegments)

class @Maze
  constructor: (options) ->
    defaultOptions =
      unicursal: false
      width: 4
      height: 4
      initialIndex: -> 0
      done: ->
      avoid: ->
      step: (fn) ->
        setTimeout fn, 10
        # try
        #   fn()
        # catch error
        #   if error instanceof RangeError
        #     setTimeout fn

    $.extend(@, defaultOptions, options)

    if @initialize
      @initialize()

    undefined

Maze.createInteractive = (options) ->
  extendedOptions = $.extend({}, options)
  maze = new Maze(extendedOptions)
  generateMaze(maze)
  maze

Maze.createInstantaneous = (options) ->
  extendedOptions = $.extend({}, options, step: (fn) -> fn())
  maze = new Maze(extendedOptions)
  generateMaze(maze)
  maze