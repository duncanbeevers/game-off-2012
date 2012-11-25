FW = @FW ||= {}

mapToArraySortedByAttribute = (map, attribute) ->
  # Convert map to array
  unsortedResults = for key, value of map
    [ key, value ]

  # Sort the array by the provided attribute
  unsortedResults.sort (a, b) ->
    [ keyA, valueA ] = a
    [ keyB, valueB ] = b
    valA = a[attribute]
    valB = b[attribute]

    # TODO: Generalize
    if valA < valB
      -1
    else if valA > valB
      1
    else
      0

FW.Util =
  mapToArraySortedByAttribute: mapToArraySortedByAttribute
