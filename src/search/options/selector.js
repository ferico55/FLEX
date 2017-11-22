import fpRaw from 'lodash/fp'
import { createSelector } from 'reselect'

export const separator_type = 'flatlist_separator'

const fp = fpRaw.convert({ cap: false })
const getFirstLetter = string => string.slice(0, 1).toUpperCase()
export default createSelector(
  (_, props) => fp.get('filter', props),
  ({ optionsSearch }) => optionsSearch,
  ({ connectionState }) => connectionState,
  (filter, search, connectionState) => {
    const isBrand = filter.template_name === 'template_brand'
    const filterBySearchString = fp.filter(
      fp.flow([
        fp.get('name'),
        value => {
          if (!value) {
            return ''
          }
          if (fp.isArray(value)) {
            return value.join(' ')
          }
          return value
        },
        fp.invoke('toLowerCase'),
        fp.invokeArgs('includes', [search.toLowerCase()]),
      ]),
    )
    const injectHeaders = fp.flow([
      fp.map((value, index, array) => {
        const prevValue = array[index - 1] || { name: '' }
        if (getFirstLetter(value.name) !== getFirstLetter(prevValue.name)) {
          return [
            {
              key: `${value.key}#${getFirstLetter(value.name)}`,
              input_type: separator_type,
              value: getFirstLetter(value.name),
            },
            value,
          ]
        }
        return value
      }),
      fp.flatten,
    ])

    const optionsMapped = fp.flow([
      // sort must be done for headers to work properly. Headers only used in isBrand
      options =>
        isBrand
          ? fp.sortBy(({ name }) => name.toLowerCase())(options)
          : options,
      filterBySearchString,
      options => (isBrand ? injectHeaders(options) : options),
    ])(filter.options)
    const headersByLetter = fp.flow([
      fp.map(({ value, input_type }, index) => ({ value, input_type, index })),
      fp.filter(({ input_type }) => input_type === separator_type),
    ])(optionsMapped)

    return {
      headersByLetter,
      search,
      connectionState,
      options: optionsMapped,
      popular: isBrand && optionsMapped.filter(({ is_popular }) => is_popular),
    }
  },
)
