import React from 'react'
import { View, Text, StyleSheet } from 'react-native'
import TKPTouchable from './TKPTouchable'

const btnStyle = StyleSheet.create({
  big: {
    height: 50,
    width: 179,
    backgroundColor: '#3cb742',
    alignItems: 'center',
    justifyContent: 'center',
    borderRadius: 3,
    borderWidth: 1,
    borderColor: '#3cb742',
  },
})
const btnTextStyle = StyleSheet.create({
  big: {
    color: '#ffffff',
    fontSize: 14,
    fontWeight: 'bold',
  },
})

const TKPBtn = ({ type, content, onTap }) => (
  <TKPTouchable onPress={onTap}>
    <View style={btnStyle[type]}>
      <Text style={btnTextStyle[type]}>{content}</Text>
    </View>
  </TKPTouchable>
)

export default TKPBtn
