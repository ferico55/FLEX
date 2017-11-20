import React from 'react'
import { View, Text, StyleSheet } from 'react-native'
import TKPTouchable from './TKPTouchable'

const btnStyle = StyleSheet.create({
  small: {
    width: 150,
    height: 40,
    alignItems: 'center',
    justifyContent: 'center',
    borderWidth: 1,
    borderRadius: 3,
    borderColor: '#42b549',
    backgroundColor: '#42b549',
  },
  medium: {
    height: 40,
    backgroundColor: '#ff5722',
    alignItems: 'center',
    justifyContent: 'center',
    borderRadius: 3,
    borderWidth: 1,
    borderColor: '#ff5722',
  },
  big: {
    height: 52,
    backgroundColor: '#ff5722',
    alignItems: 'center',
    justifyContent: 'center',
    borderRadius: 3,
    borderWidth: 1,
    borderColor: '#ff5722',
  },

})
const btnTextStyle = StyleSheet.create({
  small: {
    color: '#FFF',
    fontSize: 13,
    fontWeight: '600',
  },
  medium: {
    color: '#f1f1f1',
    fontSize: 13,
    fontWeight: '600',
  },
  big: {
    color: '#f1f1f1',
    fontSize: 14,
    fontWeight: '600',
  },
})

const TKPPrimaryBtn = ({ type, content, onTap }) => (
  <TKPTouchable
    onPress={onTap}
  >
    <View style={btnStyle[type]}>
      <Text style={btnTextStyle[type]}>{content}</Text>
    </View>
  </TKPTouchable>
)

export default TKPPrimaryBtn
