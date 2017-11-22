import React from 'react'
import { View, Text, StyleSheet } from 'react-native'

const styles = StyleSheet.create({
  container: {
    backgroundColor: 'red',
    height: 54,
    justifyContent: 'center',
    alignItems: 'center',
    paddingLeft: 15,
  },
  text: {
    fontSize: 16,
    color: 'white',
  },
})

export default () => (
  <View style={styles.container}>
    <Text style={styles.text}>Tidak ada koneksi internet</Text>
  </View>
)
