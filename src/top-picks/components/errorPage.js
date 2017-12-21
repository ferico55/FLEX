import React from 'react'
import { Image, View, StyleSheet, Text } from 'react-native'
import TKPTouchable from '../common/TKPTouchable'

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: 'rgba(0, 0, 0, 0.05)',
    justifyContent: 'center',
    alignItems: 'center',
  },
  errorImage: {
    width: 100,
    height: 100,
  },
})

const ErrorPage = ({ onTryAgain }) => (
  <View style={styles.container}>
    <Image
      style={styles.errorImage}
      source={{
        uri: 'https://ecs7.tokopedia.net/img/android_offstore/ic_offline2.png',
      }}
    />
    <View style={{ paddingTop: 10 }}>
      <Text style={{ fontSize: 16, fontWeight: 'bold', textAlign: 'center' }}>
        Terjadi kesalahan. Ulangi beberapa saat lagi
      </Text>
    </View>
    <View style={{ paddingTop: 10 }}>
      <Text style={{ color: 'rgba(0,0,0,.38)' }}>Silakan Coba lagi</Text>
    </View>
    <TKPTouchable onPress={onTryAgain}>
      <View style={{ paddingTop: 10 }}>
        <Text
          style={{
            color: '#42b549',
            fontWeight: 'bold',
          }}
        >
          COBA LAGI
        </Text>
      </View>
    </TKPTouchable>
  </View>
)

export default ErrorPage
