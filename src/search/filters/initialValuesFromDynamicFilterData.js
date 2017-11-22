import fp from 'lodash/fp'
import getCheckBoxValuesFromFilters from './getCheckBoxValuesFromFilters'
import pMinMaxFromFilters from './pMinMaxFromFilters'

export default dynamicFilterData => {
  const filters = fp.get('filter', dynamicFilterData)
  if (!fp.isArray(filters)) {
    return {}
  }

  const initialCheckBoxValues = fp.flow([
    getCheckBoxValuesFromFilters,
    fp.mapValues(
      fp.map(() => false), // default checkbox value is false
    ),
  ])(filters)

  return {
    sc: [],
    ...pMinMaxFromFilters(filters),
    ...initialCheckBoxValues,
  }
}
