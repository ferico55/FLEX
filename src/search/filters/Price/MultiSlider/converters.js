/* eslint-disable */

export function valueToPosition(value, valuesArray, sliderLength) {
  let arrLength
  const index = valuesArray.indexOf(value)

  if (index === -1) {
    return null
  }
  arrLength = valuesArray.length - 1
  return sliderLength * index / arrLength
}

export function positionToValue(position, valuesArray, sliderLength) {
  let arrLength
  let index

  if (position < 0 || sliderLength < position) {    
    return null
  }
  arrLength = valuesArray.length - 1
  index = arrLength * position / sliderLength
  return valuesArray[Math.round(index)]
}

export function createArray(start, end, step) {
  let i
  let length
  const direction = start - end > 0 ? -1 : 1
  const result = []
  if (!step) {
    return result
  }
  length = Math.abs((start - end) / step) + 1
  for (i = 0; i < length; i++) {
    result.push(start + i * Math.abs(step) * direction)
  }
  return result
}
