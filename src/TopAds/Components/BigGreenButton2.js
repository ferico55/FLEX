import React from 'react'
import { StyleSheet, Text, TouchableOpacity } from 'react-native'
import color from '../Helper/Color'

const styles = StyleSheet.create({
  promoTokoAddButton: {
    height: 52,
    alignItems: 'center',
    justifyContent: 'center',
  },
  promoTokoAddButtonLabel: {
    color: 'white',
  },
})
const BigGreenButton2 = ({ disabled, buttonAction, title }) => (
  <TouchableOpacity
    style={[
      styles.promoTokoAddButton,
      {
        backgroundColor: disabled ? color.lineGrey : color.mainGreen,
      },
    ]}
    onPress={() => buttonAction()}
    disabled={disabled}
  >
    <Text style={styles.promoTokoAddButtonLabel}>{title}</Text>
  </TouchableOpacity>
)

export default BigGreenButton2
