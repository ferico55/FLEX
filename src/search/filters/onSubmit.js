import fpRaw from 'lodash/fp'
import getCheckBoxValuesFromFilters from './getCheckBoxValuesFromFilters'
import pMinMaxFromFilters from './pMinMaxFromFilters'
import normalizeKey from '../normalizeKey'

const fp = fpRaw.convert({
  cap: false,
})

export default ({ filters, form }) => {
  const checkBoxValues = getCheckBoxValuesFromFilters(filters)
  const { pmin, pmax } = pMinMaxFromFilters(filters)

  return fp.flow([
    fp.map((valuesRaw, key) => {
      const valueString = fp.isArray(valuesRaw)
        ? fp.flow([
            fp.map((value, index) => {
              if (value === false) {
                return false
              }
              return fp.getOr(0, [key, index, 'value'], checkBoxValues)
            }),
            fp.compact,
          ])(valuesRaw)
        : valuesRaw.toString()
      return {
        key: normalizeKey(key),
        value: valueString,
      }
    }),
    fp.filter(({ value }) => !(fp.isArray(value) && value.length === 0)),
    fp.filter(({ value, key }) => {
      if (key === 'pmin') {
        return value !== pmin.toString()
      }
      if (key === 'pmax') {
        return value !== pmax.toString()
      }
      if (key === 'sc') {
        return value.length > 0
      }
      return true
    }),
    fp.map(option => ({ ...option, value: option.value.toString() })),
  ])({ ...form, sc: form.sc.join(',') })
}
