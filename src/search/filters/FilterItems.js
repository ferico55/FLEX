import React from 'react'
import { View } from 'react-native'
import fpRaw from 'lodash/fp'
import { createStructuredSelector } from 'reselect'
import SelectMore from './SelectMore'
import Separator from './Separator'
import Price from './Price'
import { connect } from '../redux'
import CheckboxFieldOrFields from '../inputs/CheckboxFieldOrFields'

const fp = fpRaw.convert({
  cap: false,
})

const templates = {
  template_separator: Separator,
  template_price: Price,
}

const EmptyClass = () => null

const getFilterClass = filter => {
  // this filter has a template and must be rendered using special conmponent
  const template = templates[filter.template_name]
  if (template) {
    return template
  }
  const { options } = filter
  if (!options || !options.length) {
    // somthing must be wrong
    return EmptyClass
  }

  if (
    fp.get('length', options) === 1 &&
    fp.get('[0].input_type', options) === 'checkbox' &&
    fp.get('template_name', filter) === '' &&
    fp.get('search.searchable', filter) !== 1
  ) {
    // this is top level checkbox
    return CheckboxFieldOrFields
  }

  // this has many options and they will be shown one level deeper
  return SelectMore
}

const selector = createStructuredSelector({
  dynamicFilterData: ({ dynamicFilterData, uniqueIdAndSource }) =>
    dynamicFilterData[uniqueIdAndSource],
})

export default connect(
  selector,
)(
  ({
    dynamicFilterData: { filter: filters },
    disableScroll,
    enableScroll,
    priceRef,
  }) => (
    <View>
      {filters.map(filter => {
        const ItemClass = getFilterClass(filter)
        if (ItemClass === Price) {
          return (
            <ItemClass
              key={filter.filterIndex}
              filter={filter}
              priceRef={priceRef}
              handleDisableScroll={disableScroll}
              handleEnableScroll={enableScroll}
            />
          )
        }
        return <ItemClass key={filter.filterIndex} filter={filter} />
      })}
    </View>
  ),
)
