import fp from 'lodash/fp'
import mapUkuranOptions from './mapUkuranOptions'

let checkboxKeyCounter = {}

const mapKey = ({
  option: { key, input_type, template_name },
  filterIndex,
}) => {
  if (template_name === 'template_category') {
    return key
  }
  if (input_type === 'checkbox') {
    const prefix = `${filterIndex}$${key}`
    if (!checkboxKeyCounter[prefix]) {
      checkboxKeyCounter[prefix] = 0
    }
    const newKey = `${prefix}[${checkboxKeyCounter[prefix]}]`
    checkboxKeyCounter[prefix] += 1
    return newKey
  }
  return `${filterIndex}$${key}`
}

const addExtraFieldsOptionsMapper = filter => options =>
  options.map(option => ({
    ...option,
    originalKey: option.key,
    template_name: filter.template_name,
    filterIndex: filter.filterIndex,
  }))

const addKeyOptionsMapper = filter => options =>
  options.map(option => ({
    ...option,
    key: mapKey({
      option,
      filterIndex: filter.filterIndex,
    }),
  }))

const optionsMappers = {
  template_size: mapUkuranOptions,
}

const templateOptionsMapper = filter =>
  optionsMappers[filter.template_name] || fp.identity

export default result => {
  if (result.status !== 'OK') {
    throw result
  }
  checkboxKeyCounter = {}

  // add `template_name` key to each `option` object under result.data.filter[].options[]
  // and change keys into `${filterIndex}$${option.key}` i.e. '4$variants'

  return {
    ...result.data,
    filter: result.data.filter
      .map((filter, filterIndex) => ({
        ...filter,
        filterIndex,
      }))
      .map(filter =>
        fp.flow([
          fp.get('options'),
          addExtraFieldsOptionsMapper(filter),
          templateOptionsMapper(filter),
          addKeyOptionsMapper(filter),
          options => ({ ...filter, options }),
        ])(filter),
      ),
  }
}
