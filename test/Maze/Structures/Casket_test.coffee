Casket = require("../../../source/javascripts/Maze/Structures/Casket.coffee").Maze.Structures.Casket

chai = require("chai")
expect = chai.expect

describe "Maze.Structures.Casket", ->
  describe "translations", ->
    it "should translate as few as four rows", ->
      maze = {}
      for key, value of Casket
        maze[key] = value

      maze.width = 4
      maze.height = 4

      expectedTranslations = [
        [ 4, 2, undefined ]
        [ 4, 3, undefined ]
        [ 4, 4, undefined ]
        [ 6, 2, undefined ]
        [ 8, 4, undefined ]
        [ 12, 0, undefined ]
        [ 12, 1, undefined ]
        [ 15, 0, undefined ]
        [ 15, 1, undefined ]
      ]

      for [from, direction, expectedResult ] in expectedTranslations
        result = maze.translateDirection(from, direction)
        expect(result, "translating from #{from} in direction #{direction} leads to #{expectedResult}").to.eql(expectedResult)

    it "should translate from according to the picture I drew", ->
      # Copy
      maze = {}
      for key, value of Casket
        maze[key] = value

      maze.width = 4
      maze.height = 16

      expectedTranslations = [
        # Non-staggered, pointing up
        [ 33, 0, 24 ]
        [ 33, 1, 21 ]
        [ 0, 2, 8 ]
        [ 0, 3, 12 ]
        [ 0, 4, 4]
        # Staggered, pointing up
        [ 16, 0, 8 ]
        [ 16, 1, 5 ]
        [ 16, 2, 24 ]
        [ 16, 3, 28 ]
        [ 16, 4, 20 ]
        # Non-staggered, pointing right
        [ 4, 0, 0 ]
        [ 4, 1, 12 ]
        [ 5, 2, 16 ]
        [ 5, 3, 8 ]
        [ 37, 4, 28 ]
        # Staggered, pointing right
        [ 20, 0, 16 ]
        [ 20, 1, 28 ]
        [ 20, 2, 32 ]
        [ 21, 3, 24 ]
        [ 21, 4, 13 ]
        # Non-staggered, pointing left
        [ 8, 0, 12 ]
        [ 8, 1, 0 ]
        [ 40, 2, 28 ]
        [ 8, 3, 5 ]
        [ 8, 4, 16 ]
        # Staggered, pointing left
        [ 24, 0, 28 ]
        [ 24, 1, 16 ]
        [ 24, 2, 13 ]
        [ 24, 3, 21 ]
        [ 24, 4, 33 ]
        # Non-staggered, pointing down
        [ 12, 0, 20 ]
        [ 13, 1, 24 ]
        [ 12, 2, 4 ]
        [ 12, 3, 0 ]
        [ 12, 4, 8 ]
        # Staggered pointing down
        [ 28, 0, 37 ]
        [ 28, 1, 40 ]
        [ 28, 2, 20 ]
        [ 28, 3, 16 ]
        [ 28, 4, 24 ]

        # Boundaries
        [ 0, 0, undefined ]
        [ 0, 1, undefined ]
        [ 1, 0, undefined ]
        [ 1, 1, undefined ]
        [ 2, 0, undefined ]
        [ 2, 1, undefined ]
        [ 3, 0, undefined ]
        [ 3, 1, undefined ]
        [ 19, 1, undefined ]
        [ 32, 0, undefined ]
        [ 51, 1, undefined ]

        [ 4, 2, undefined ]
        [ 4, 3, undefined ]
        [ 4, 4, undefined ]
        [ 5, 4, undefined ]
        [ 7, 4, undefined ]
        [ 20, 3, undefined]
        [ 36, 2, undefined ]
        [ 36, 3, undefined ]
        [ 36, 4, undefined ]
        [ 52, 2, undefined ]
        [ 52, 3, undefined ]
        [ 55, 2, undefined ]

        [ 8, 2, undefined ]
        [ 11, 2, undefined ]
        [ 11, 3, undefined ]
        [ 27, 2, undefined ]
        [ 27, 3, undefined ]
        [ 27, 4, undefined ]
        [ 43, 3, undefined ]
        [ 56, 4, undefined ]
        [ 59, 2, undefined ]
        [ 59, 3, undefined ]
        [ 59, 4, undefined ]

        [ 12, 1, undefined ]
        [ 31, 0, undefined ]
        [ 44, 1, undefined ]
        [ 60, 0, undefined ]
        [ 60, 1, undefined ]
        [ 61, 0, undefined ]
        [ 61, 1, undefined ]
        [ 62, 0, undefined ]
        [ 62, 1, undefined ]
        [ 63, 0, undefined ]
        [ 63, 1, undefined ]
      ]

      for [from, direction, expectedResult ] in expectedTranslations
        result = maze.translateDirection(from, direction)
        expect(result, "translating from #{from} in direction #{direction} leads to #{expectedResult}").to.eql(expectedResult)
