CountingComparator = (comparator) ->
  count = 0

  comparator ||= (a, b) ->
    count += 1
    if a == b
      0
    else if a < b
      -1
    else
      1

  comparator.getCount = ->
    count

  comparator.resetCount = ->
    count = 0

  return comparator
