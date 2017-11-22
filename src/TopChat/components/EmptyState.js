import React from 'react'
import { Text, Image, View, Dimensions, StyleSheet } from 'react-native'
import noChat from '@img/noChat.png'

const styles = StyleSheet.create({
  container: {
    flex: 1,
    flexDirection: 'column',
    alignItems: 'center',
    justifyContent: 'center',
    maxWidth: 400,
    alignSelf: 'center',
  },
  image: {
    marginBottom: 32,
  },
  title: {
    fontSize: 16,
    fontWeight: 'bold',
    marginBottom: 8,
    color: 'rgba(0, 0, 0, 0.54)',
  },
  subtitle: {
    fontSize: 14,
    color: 'rgba(0, 0, 0, 0.38)',
    textAlign: 'center',
  },
  timeMachineText: {
    fontSize: 11,
    color: 'rgba(0, 0, 0, 0.54)',
    lineHeight: 16,
    textAlign: 'center',
  },
  timeMachineButton: {
    fontWeight: '500',
    color: '#42b549',
  },
})

const { height } = Dimensions.get('window')
const message = `Untuk melihat percakapan sebelumnya,\nkunjungi `

const EmptyState = ({ handleOpenTimeMachine, navigationBarHeight }) => (
  <View
    style={[
      styles.container,
      {
        height: height - navigationBarHeight - 32,
      },
    ]}
  >
    <Image source={noChat} style={styles.image} />
    <Text style={styles.title}>Tidak Ada Chat</Text>
    <Text style={styles.timeMachineText}>
      {message}
      <Text style={styles.timeMachineButton} onPress={handleOpenTimeMachine}>
        Riwayat Pesan
      </Text>
    </Text>
  </View>
)

export default EmptyState
