SortedArray = require("../../source/javascripts/FW/SortedArray").FW.SortedArray
SortedSet = require("../../source/javascripts/FW/SortedSet").FW.SortedSet

chai = require("chai")
expect = chai.expect

describe "FW.SortedSet", ->
  describe "#insert", ->
    it "should add add new element to collection", ->
      set = new SortedSet(SortedArray.OrdinalComparator)
      set.insert(1)
      expect(set.collection()).to.eql([1])

    it "should not add the same element twice", ->
      set = new SortedSet(SortedArray.OrdinalComparator)
      set.insert(1)
      set.insert(1)
      expect(set.collection()).to.eql([1])

    it "should use comparator for equivalence checking", ->
      comparator = (a, b) ->
        if Math.abs(a - b) < 5
          0
        else if a < b
          -1
        else
          1

      set = new SortedSet(comparator)
      set.insert(1)
      set.insert(5)
      set.insert(6)
      expect(set.collection()).to.eql([1,6])