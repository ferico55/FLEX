import React from 'react'
import { StyleSheet, Text, TouchableOpacity } from 'react-native'
import color from '../Helper/Color'

const styles = StyleSheet.create({
  promoTokoAddButton: {
    height: 40,
    alignItems: 'center',
    justifyContent: 'center',
    marginHorizontal: 17,
    paddingHorizontal: 10,
    marginBottom: 10,
    borderRadius: 3,
  },
  promoTokoAddButtonLabel: {
    color: 'white',
  },
})
const BigGreenButton = ({ disabled, buttonAction, title }) => (
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

export default BigGreenButton
