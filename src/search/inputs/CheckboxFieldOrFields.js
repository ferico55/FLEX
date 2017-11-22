// @flow
import React from 'react'
import { FieldArray } from 'redux-form'
import fp from 'lodash/fp'
import CheckboxField from './CheckboxField'
import CheckboxFieldArray from './CheckboxFieldArray'

// give it any one of filter, options or option
// and it will render one or more checkboxes

export default ({
  filter,
  options,
  option,
}: {
  filter: ?Object,
  options: ?Object,
  option: ?Object,
}) => {
  if (!filter && !options && !option) {
    throw new Error(
      'At least one of "filter", "options", "option" props has to be provided ',
    )
  }
  if (
    option ||
    (options && options.length === 1) ||
    (filter && filter.options.length === 1)
  ) {
    const localOption =
      option || fp.get('0', options) || fp.get('options[0]', filter)
    return <CheckboxField option={localOption} />
  }

  const localOptions = options || filter.options
  const key = fp.first(localOptions[0].key.split('['))
  if (!key) {
    throw new Error('Key must be present on "option" object')
  }
  return (
    <FieldArray
      {...{
        name: key,
        component: CheckboxFieldArray,
        props: { options: localOptions },
      }}
    />
  )
}
