FW = @FW ||= {}

mapToArraySortedByAttribute = (map, attribute, reverse) ->
  # Convert map to array
  unsortedResults = for key, value of map
    [ key, value ]

  # Sort the array by the provided attribute
  unsortedResults.sort (a, b) ->
    [ keyA, valueA ] = a
    [ keyB, valueB ] = b
    valA = a[attribute]
    valB = b[attribute]

    if reverse
      reverseScalar = -1
    else
      reverseScalar = 1

    # TODO: Generalize
    if valA < valB
      -1 * reverseScalar
    else if valA > valB
      1 * reverseScalar
    else
      0

indexOf = (collection, comparator) ->
  length = collection.length
  result = -1

  i = 0
  while i < length
    if comparator(collection[i])
      # Found it, break
      result = i
      i = length
    i += 1

  result

FW.Util =
  mapToArraySortedByAttribute: mapToArraySortedByAttribute
  indexOf: indexOf
