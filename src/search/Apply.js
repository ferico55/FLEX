// @flow
import React from 'react'
import { View, Text, StyleSheet, TouchableOpacity } from 'react-native'

const styles = StyleSheet.create({
  container: {
    backgroundColor: 'rgb(66,181,73)',
    alignItems: 'center',
    justifyContent: 'center',
    height: 60,
  },
  text: {
    fontSize: 16,
    color: 'white',
  },
})

export default ({ onPress, label }: { onPress: Function }) => (
  <TouchableOpacity onPress={onPress}>
    <View style={styles.container}>
      <Text style={styles.text}>{label}</Text>
    </View>
  </TouchableOpacity>
)
