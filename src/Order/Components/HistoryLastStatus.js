import React from 'react'
import { Text, View, StyleSheet, Image, Dimensions } from 'react-native'
import { imageSource } from '../Components/LastStatusImageSource'

const window = Dimensions.get('window')
const styles = StyleSheet.create({
  container: {
    height: 133,
    backgroundColor: 'white',
    flex: 1,
    flexDirection: 'column',
    marginBottom: 16,
  },
  image: {
    height: 87,
    width: window.width,
    resizeMode: 'contain',
  },
  statusView: {
    justifyContent: 'center',
    height: 46,
  },
  status: {
    textAlign: 'center',
    fontSize: 14,
    fontWeight: '500',
  },
  line: {
    height: 1,
    backgroundColor: 'rgba(0, 0, 0, 0.12)',
  },
})

const LastStatusView = ({ lastStatus, title, color }) => (
  <View style={styles.container}>
    <Image style={styles.image} source={imageSource(lastStatus)} />
    <View style={styles.statusView}>
      <Text style={[styles.status, { color }]}>{title}</Text>
    </View>
    <View style={styles.line} />
  </View>
)

export default LastStatusView
