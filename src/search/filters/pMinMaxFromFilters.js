import fp from 'lodash/fp'
import normalizeKey from '../normalizeKey'

const getNumberOrUndefined = string => {
  if (typeof string === 'number') {
    return string
  }
  if (typeof string === 'string') {
    const parsed = parseInt(string, 10)
    if (!isNaN(parsed)) {
      return parsed
    }
  }
  return undefined
}

const f = fp.flow([
  fp.find(({ template_name }) => template_name === 'template_price'),
  fp.get('options'),
  fp.find(({ key }) => normalizeKey(key) === 'pmin-pmax'),
  priceInfo => ({
    pmin: fp.get('val_min', priceInfo),
    pmax: fp.get('val_max', priceInfo),
  }),
  fp.mapValues(getNumberOrUndefined),
  fp.pickBy(value => value !== undefined),
])

export default data => f(data)
