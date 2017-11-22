// @flow
import React from 'react'
import { Text, View } from 'react-native'
import styles from './styles'

export default ({ letter, style }: { letter: string, style: Object }) => (
  <View style={style || styles.separator}>
    <Text style={styles.separatorText}>{letter}</Text>
  </View>
)
