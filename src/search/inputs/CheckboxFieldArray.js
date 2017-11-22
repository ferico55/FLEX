// @flow
import React from 'react'
import { View } from 'react-native'
import CheckboxField from './CheckboxField'

export default ({
  fields,
  options,
}: {
  fields: Array<Object>,
  options: Array<Object>,
}) => (
  <View>
    {fields.map((field, index) => (
      <CheckboxField key={field} option={options[index]} />
    ))}
  </View>
)
