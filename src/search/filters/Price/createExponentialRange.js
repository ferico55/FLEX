/* eslint-disable no-restricted-properties */
import fpRaw from 'lodash/fp'

const fp = fpRaw.convert({ cap: false })

export const levels = 100
export default ({ min, max }) => {
  const interval = Math.sqrt(max - min)
  return fp.flow([
    fp.times(index =>
      Math.round(min + Math.pow(interval * (index / (levels - 1)), 2)),
    ),
    fp.map((value, index, array) => {
      if (index === 0 || index === array.length - 1) {
        return value
      }

      const diff = (array[index - 1] || value) - value
      const howManyDigitsToRound = diff.toString().length - 2
      return fp.round.convert({ fixed: false })(
        value,
        howManyDigitsToRound * -1,
      )
    }),
  ])(levels)
}
