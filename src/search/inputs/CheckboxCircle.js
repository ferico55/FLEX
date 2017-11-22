// @flow
import React from 'react'
import { Image, StyleSheet } from 'react-native'

const iconGreen = { uri: 'icon_check_green' }
const iconEmpty = { uri: 'icon_checkmark_1' }
const margin = 15
const size = 18
const iconStyles = {
  width: size,
  height: size,
  marginRight: margin,
  marginLeft: margin,
}
export const width = size + margin * 2
const styles = StyleSheet.create({
  icon: iconStyles,
})

export default ({ value }: { value: boolean }) => (
  <Image source={value ? iconGreen : iconEmpty} style={styles.icon} />
)
