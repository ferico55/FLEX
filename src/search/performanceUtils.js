import fpRaw from 'lodash/fp'

const fp = fpRaw.convert({
  cap: false,
})

export const isEqualOrWhyNot = (a, b, depth = 1) => {
  if (a === b) {
    return true
  }
  if (typeof a !== typeof b) {
    return ['types are different', typeof a, typeof b]
  }

  if (['number', 'string', 'boolean', 'function'].includes(typeof a)) {
    return [`notEqual:`, a, b]
  }

  if (typeof a === 'object') {
    const aKeys = fp.keys(a)
    const bKeys = fp.keys(b)
    if (aKeys.length !== bKeys.length) {
      return ['key length is different', a, b]
    }
    if (!fp.isEqual(aKeys, bKeys)) {
      return ['keys not equal', a, b]
    }
    const differentKeys = fp.flow([
      fp.mapValues((aValue, key) => {
        const bValue = b[key]
        if (aValue !== bValue) {
          if (depth > 0) {
            return isEqualOrWhyNot(aValue, bValue, depth - 1)
          }
          return [`notEqual key:${key}`, aValue, bValue]
        }
        return false
      }),
      fp.pickBy(value => value),
    ])(a)
    if (fp.keys(differentKeys).length === 0) {
      return 'Objects are different, but keys are not, OPTIMIZE IT!'
    }
    return differentKeys
  }
  return ['something is different but hell knows what', a, b, typeof a]
}

export const shouldComponentUpdateCreator = message =>
  function shouldComponentUpdate(nextProps, nextState) {
    const propsCompare = isEqualOrWhyNot(nextProps, this.props)
    const stateCompare = isEqualOrWhyNot(nextState, this.state)

    if (propsCompare === true && stateCompare === true) {
      return false
    }

    console.log( // eslint-disable-line
      message,
      fp.pickBy(value => value !== true, { propsCompare, stateCompare }),
    )
    return true
  }
