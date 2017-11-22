// @flow
import React from 'react'
import CheckboxField from '../inputs/CheckboxField'
import LetterHeader from './LetterHeader'
import styles from './styles'
import { separator_type } from './selector'

export default ({ item }: { item: { input_type: string } }) => {
  switch (item.input_type) {
    case 'checkbox':
      return <CheckboxField option={item} checkboxTemplate="circle" />
    case separator_type:
      return <LetterHeader letter={item.value} style={styles.separator} />
    default:
      return null
  }
}
