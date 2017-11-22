// @flow
import React from 'react'
import { Field } from 'redux-form'
import Checkbox from './Checkbox'

// to avoid rebinding onChange, we just use normalizer to toggle checkbox regardless of the given value
const checkboxNormalizerHack = (_, previousValue) => !previousValue

export default ({
  option,
  checkboxTemplate,
}: {
  option: Array<Object>,
  checkboxTemplate: string,
}) => (
  <Field
    name={option.key}
    component={Checkbox}
    option={option}
    normalize={checkboxNormalizerHack}
    checkboxTemplate={checkboxTemplate}
  />
)
