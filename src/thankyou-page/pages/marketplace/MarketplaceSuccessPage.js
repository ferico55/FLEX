import React from 'react'
import {
  StyleSheet,
  Image,
  View,
  Button,
  TouchableOpacity,
  Text,
} from 'react-native'
import { NavigationModule, ReactTPRoutes } from 'NativeModules'
import Navigator from 'native-navigation'


class MarketplaceSuccessScreen extends React.Component {
  render() {
    const {
      payment_logo,
      amount,
      total_amount
    } = this.props.data
    const {
      viewContainer,
      txtSubtitle,
      txtLink,
      methodStyle,
      grey_line,
      amountStyle,
      copyright,
      buttonHolder,
      txtInsideBtn,
      mascot,
      secureIcon,
      txtTitle
    } = styles

    this.props.data.amount = amount !== '0' ? 'Rp ' + amount : amount
    this.props.data.total_amount = total_amount !== '0' ? 'Rp ' + total_amount : total_amount

    return (
      <Navigator.Config title='Pembayaran'>
      <View style={viewContainer}>
        <Text style={txtTitle}>Pembayaran Berhasil</Text>
        <Text style={txtSubtitle}>Terimakasih telah bertransaksi</Text>
        <Text style={methodStyle}>Pembayaran berhasil dengan menggunakan TokoCash</Text>
        <Image source={{ uri: payment_logo }} style={mascot} />
        <Text style={amountStyle}>Rp {total_amount}</Text>
        
        <TouchableOpacity onPress={
          () => Navigator.present('ThankYouDetailPage', { data: this.props.data })
        }>
          <Text style={txtLink}>Lihat detail pembayaran</Text>
        </TouchableOpacity>

        <View style={grey_line} />

        <TouchableOpacity 
          onPress={() => ReactTPRoutes.navigate(`tokopedia://buyer/order`)}
          style={buttonHolder}>
          <Text style={txtInsideBtn}>Cek Status Pemesanan</Text>
        </TouchableOpacity>

        <Image 
          source={{ uri: `https://ecs7.tokopedia.net/img/react_native/icon_payment_secure.png` }} 
          style={secureIcon} />

      </View>
      </Navigator.Config>
    )
  }
}

const styles = StyleSheet.create({
  txtTitle: { fontSize: 17, marginTop: 30, fontWeight: 'bold', color: 'rgba(0,0,0,0.7)' },  
  viewContainer: { flex: 1, alignItems: 'center', backgroundColor: 'white' },
  txtSubtitle: { fontSize: 14, color: 'rgba(0,0,0,0.7)', marginTop: 12, fontWeight: 'bold' },
  amountStyle: { fontSize: 14, marginTop: 15, color: 'red', fontWeight: 'bold' },
  txtLink: { fontWeight: '600', fontSize: 14, marginTop: 5, color: 'green', textDecorationLine: 'underline' },
  methodStyle: { textAlign: 'center', fontSize: 14, marginTop: 10, marginLeft: 5, marginRight: 5, color: 'rgba(0,0,0,0.7)' },
  txtInsideBtn: { color: 'white', fontSize: 16, textAlign: 'center' },
  copyright: { textAlign: 'center', marginLeft: 15, marginRight: 15, fontSize: 12, marginTop: 17, color: 'rgba(0,0,0,0.7)'  },
  grey_line: { borderBottomColor: '#f1f1f1', borderBottomWidth: 1, width: '90%', marginTop: 25 },
  mascot: { width: 35, height: 35, marginTop: 15 },
  secureIcon: { width: '100%', height: '10%', marginTop: 25, resizeMode: 'contain' },
  buttonHolder: { borderRadius: 3, backgroundColor: '#42b549', marginTop: 25, paddingVertical: 12, paddingHorizontal: 20, width: '90%' },
})

export default MarketplaceSuccessScreen