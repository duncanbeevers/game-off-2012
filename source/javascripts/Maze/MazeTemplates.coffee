Maze = @Maze ||= {}

# Templates
Maze.Templates = {}
Maze.Templates.GraphPaper = $.extend Maze.Structures.GraphPaper,
  project: new Maze.Projections.GraphPaper()

Maze.Templates.FoldedHexagon = $.extend Maze.Structures.FoldedHexagon,
  project: new Maze.Projections.FoldedHexagonCell()