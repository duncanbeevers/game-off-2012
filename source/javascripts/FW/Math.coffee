FW = @FW ||= {}

PI = Math.PI
TWO_PI = PI * 2

# Returns random numbers
# Given no arguments, it returns a random number between 0 and 1
# Given one argument, it returns a random number between 0 and the provided number
# Given two arguments, it returns a random number between the two provided numbers
random = (args...) ->
  switch args.length
    when 0
      range = 1
      min = 0
    when 1
      range = args[0]
      min = 0
    when 2
      range = args[1] - args[0]
      min = args[0]

  return (Math.random() * range) + min

rand = (args...) ->
  Math.floor(random.apply(@, args))

# Locks a value within a range.
# If the value is less than min, returns min
# If the value is greater than max, returns max
# If the value is between min and max, returns value
clamp = (value, min, max) ->
  return Math.min(Math.max(min, value), max)

# Normalizes the provided value to a 0 to 2pi radian range
# This means original orientation is preserved
normalizeToCircle = (value) ->
  normalizeToCap(value, TWO_PI)

normalizeToHalfCircle = (value) ->
  normalizeToCap(value, PI)

normalizeToCap = (value, cap) ->
  value % cap
  if value < 0
    value += cap

  return value

# Does a linear interpolation between one range and another
# The first two arguments indicate the target range
# The second two arguments indicate the source range
# The final argument indicates the source value
linearInterpolate = (targetMin, targetMax, sourceMin, sourceMax, sourceProgress) ->
  sourceRange = sourceMax - sourceMin
  targetRange = targetMax - targetMin
  progress = (sourceProgress - sourceMin) / sourceRange
  progress * targetRange + targetMin

sample = (collection) ->
  collection[rand(collection.length)]

centroidOfSegments = (segments) ->
  xSum = 0
  ySum = 0
  for [x1, y1, x2, y2] in segments
    xSum += x1 + x2
    ySum += y1 + y2
  [ xSum / 2 / segments.length, ySum / 2 / segments.length ]

radiansDiff = (radians1, radians2) ->
  diff = radians2 - radians1
  sign = 1
  if diff < 0
    sign = -1
  size = Math.abs(diff)
  if size > PI
    size = TWO_PI - size
    sign = sign * -1

  size * sign

FW.Math =
  PI_AND_A_HALF: PI + PI / 2
  TWO_PI: TWO_PI
  RAD_TO_DEG: 180 / PI
  DEG_TO_RAD: PI / 180
  random: random
  rand: rand
  clamp: clamp
  normalizeToCircle: normalizeToCircle
  linearInterpolate: linearInterpolate
  sample: sample
  centroidOfSegments: centroidOfSegments
  radiansDiff: radiansDiff