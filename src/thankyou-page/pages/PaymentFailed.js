import React, { Component } from 'react'
import {
  StyleSheet,
  Image,
  View,
  Button,
  TouchableOpacity,
  Text,
} from 'react-native'
const sad_face = 'http://ecs7.tokopedia.net/img/react_native/sadface.png'

class PaymentFailed extends Component {
  render() {
    return (
      <View style={styles.viewContainer}>
        <Text style={styles.txtTitle}>Maaf</Text>
        <Text style={[ styles.txtSubtitle, { marginTop: 10 } ]}>Pembayaran Anda gagal kami proses</Text>
        <Image source={{ uri: sad_face }} style={styles.mascot} />
        <Text style={styles.copyright}>
          Jangan khawatir. Jika dana Anda terpotong, akan{"\n"}dikembalikan ke TokoCash/ Saldo Tokopedia{"\n"}
          dalam waktu 1x24 Jam.
        </Text>
      </View>
    )
  }
}

const styles = StyleSheet.create({
  viewContainer: { flex: 1, alignItems: 'center', backgroundColor: 'white' },
  txtTitle: { fontSize: 35, marginTop: 60, color: 'rgba(0,0,0,0.54)' },
  txtSubtitle: { fontSize: 14, color: 'rgba(0,0,0,0.54)' },
  copyright: { textAlign: 'center', marginLeft: 5, marginRight: 5, fontSize: 13, marginTop: 40 },
  mascot: { width: 250, height: 150, marginTop: 15, resizeMode: 'contain' },
})

export default PaymentFailed