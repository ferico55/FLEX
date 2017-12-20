import React, { Component } from 'react'
import {
    StyleSheet,
    Image,
    View,
    Button,
    Clipboard,
    TouchableOpacity,
    Text,
    ScrollView,
} from 'react-native'
import { NetworkModule, NavigationModule } from 'NativeModules'
import { icons } from '../../lib/icons'
import Countdown from '../../components/Countdown'
import Count from '../../components/Count'
import moment from 'moment'
import { id } from 'moment/locale/id'
import Navigator from 'native-navigation'
import { ReactTPRoutes } from 'NativeModules'

class DigitalTransferPage extends Component {
    state = { 
        isShowDetail: false
    }

    render() {
        const { 
            containerTxtBelowUnderline,
            underLine,
            txtCopyNoRek,
            txtTitle,
            txtInsideBtn,
            txtCopyJumlah,
            txtDetailPembayaran,
            containerView,
            titleTxt,
            secureIcon,
            sisaTxt,
            sebelumTglContainer,
            deadlineTxt,
            txtLabelContainer,
            bankIcon,
            bankNum,
            txtBtn,
            notifContainer,
            txtNotifContainer,
            txtNotifContainer_2,
            txtBank,
            txtLabel,
            borderLineFull,
            bigBtnGreen,
            txtRedAmount,
            borderLine,
        } = styles
        const {
            amount,
            unique_code,
            total_amount,
            bank_holder,
            bank_info,
            bank_logo,
            order_link,
            deadline_delta,
            bank_num,
        } = this.props.data
        const order_link_decode = decodeURIComponent(order_link)
        const bank_img = decodeURIComponent(bank_logo)
        const timestamp = parseInt(deadline_delta)
        // const datetimeID = moment().set('second', moment().second() + timestamp).format('D MMMM YYYY hh:mm [WIB]')
        const datetimeID = moment().set('second', moment().second() + timestamp).format("LLL")
        const total_amount_without_rp = total_amount.substring('Rp '.length)
        
        return (
            <Navigator.Config title='Pembayaran'>
            <ScrollView style={containerView}>
                <Text style={txtTitle}>Checkout Berhasil</Text>
                <View style={{ alignItems: 'center', marginLeft: 15, marginRight: 15, marginTop: 15 }}>
                    <Text style={titleTxt}>MOHON SEGERA SELESAIKAN PEMBAYARAN</Text>
                    <Text style={sisaTxt}>Sisa waktu pembayaran Anda</Text>
                    <Count timestamp={timestamp} />
                    <View style={sebelumTglContainer}>
                        <Text style={deadlineTxt}>{datetimeID} WIB</Text>
                    </View>
                </View>

                <View style={borderLine} />
                <View style={{marginLeft: 15, marginRight: 15}}>
                    <View style={[txtLabelContainer, { marginTop: 10 }]}>
                        <Text style={[txtLabel, { fontWeight: '600', textAlign: 'center', color: 'rgba(0, 0, 0, 0.7)' }]}>Jumlah yang harus dibayar</Text>
                        <Text style={[txtRedAmount, { textAlign: 'center', marginTop: 5, fontSize: 20 }]}>{total_amount}</Text>
                    </View>
                    <View style={notifContainer}>
                        <Text style={txtNotifContainer}>Transfer tepat sampai 3 digit terakhir</Text>
                        <Text style={txtNotifContainer_2}>Perbedaan jumlah pembayaran akan menghambat proses verifikasi</Text>
                    </View>

                    <TouchableOpacity onPress={() => Clipboard.setString(total_amount_without_rp)}>
                        <Text style={txtCopyJumlah}>Salin Jumlah</Text>
                    </TouchableOpacity>
                    <TouchableOpacity onPress={
                        () => Navigator.present('ThankYouDetailPage', { data: this.props.data })
                        }>
                        <Text style={txtDetailPembayaran}>Lihat detail pembayaran</Text>
                    </TouchableOpacity>
                </View>
                

                <View style={borderLine} />
                <View style={{ alignItems: 'center', marginTop: 10, marginLeft: 15, marginRight: 15 }}>
                    <Image source={{ uri: bank_img }} style={bankIcon} />
                    <Text style={bankNum}>{bank_num}</Text>
                    <Text style={txtBank}>a/n {bank_holder} Cabang {bank_info}</Text>
                    <TouchableOpacity onPress={() => Clipboard.setString(bank_num)} >
                        <Text style={txtCopyNoRek}>Salin No. Rekening</Text>
                    </TouchableOpacity>
                    <Text style={{ marginTop: 20, fontWeight: '600', textAlign: 'center', color: 'rgba(0, 0, 0, 0.7)' }}>Tidak disarankan transfer melalui LLG/Kliring/SKBNI</Text>
                </View>

                <View style={[underLine, { width: '90%', alignSelf: 'center' }]} />
                <View style={[containerTxtBelowUnderline,{ marginLeft: 15, marginRight: 15 }]}>
                    <Text style={{ textAlign: 'center', color: 'rgba(0, 0, 0, 0.7)' }}>Demi keamanan transaksi Anda, pastikan <Text style={{ fontWeight: '600' }}>untuk tidak menginformasikan bukti dan data pembayaran kepada 
                    pihak manapun kecuali Tokopedia</Text></Text>
                </View>

                <View style={underLine} />

                <View style={[containerTxtBelowUnderline]}>
                    <TouchableOpacity 
                        onPress={() => ReactTPRoutes.navigate(this.props.data.order_link)}
                        style={bigBtnGreen}>
                        <Text style={txtInsideBtn}>Cek Status Pembayaran</Text>
                    </TouchableOpacity>
                </View>

                <Image 
                    source={{ uri: `https://ecs7.tokopedia.net/img/react_native/icon_payment_secure.png` }} 
                    style={secureIcon} />
            </ScrollView>
            </Navigator.Config>
        )
    }
}


const styles = StyleSheet.create({
    secureIcon: { width: '100%', height: '10%', resizeMode: 'contain', marginBottom: 100 },
    containerTxtBelowUnderline: { alignItems: 'center', marginTop: 15 },
    underLine: { borderBottomColor: '#f1f1f1', borderBottomWidth: 1, marginTop: 15 },
    txtCopyNoRek: { fontWeight: '600', fontSize: 12, marginTop: 13, textDecorationLine: 'underline', color: '#42b549' },
    txtDetailPembayaran: { fontWeight: '600', fontSize: 12, marginTop: 10, marginBottom: 20, textDecorationLine: 'underline', color: '#42b549', textAlign: 'center' },
    txtCopyJumlah: { fontWeight: '600', fontSize: 12, marginTop: 13, textDecorationLine: 'underline', color: '#42b549', textAlign: 'center' },
    txtTitle: { textAlign: 'center', color: 'rgba(0, 0, 0, 0.7)', fontSize: 18, fontWeight: '500', marginBottom: 15, marginTop: 30 },
    bankNum: { fontWeight: '600', color: '#42b549', fontSize: 15},
    txtBtn: { fontSize: 12, fontWeight: '300', color: '#42b549', textAlign: 'center', marginRight: 5 },
    txtNotifContainer_2: { textAlign: 'center', color: '#FFF', marginBottom: 11, fontSize: 13 },
    txtNotifContainer: { textAlign: 'center', color: '#FFF', marginTop: 10, fontWeight: '500' },
    notifContainer: { backgroundColor: '#4C4C4C', width: '90%', alignSelf: 'center', marginTop: 10, borderColor: '#42b549' },
    txtRedAmount: { fontSize: 18, color: 'red', fontWeight: 'bold', marginTop: -5 },
    txtLabelContainer: { alignSelf: 'center', marginLeft: '5%', marginRight: '5%' },
    txtLabel: { fontSize: 14 },
    borderLineFull: { alignSelf: 'center', borderBottomColor: '#f1f1f1', borderBottomWidth: 1, width: '100%' },
    borderLine: { alignSelf: 'center', borderBottomColor: '#f1f1f1', borderBottomWidth: 1, width: '90%' },
    bankIcon: { width: 100, height: 50, resizeMode: 'contain' },
    txtBank: { color: 'rgba(0, 0, 0, 0.7)', fontSize: 14, textAlign: 'center' },
    txtInsideBtn: { fontSize: 14, fontWeight: '300', color: '#ffffff', margin: 15, textAlign: 'center' },
    containerView: { flex: 1, backgroundColor: '#ffffff' },
    titleTxt: { textAlign: 'center', fontSize: 14, color: 'rgba(0, 0, 0, 0.7)', fontWeight: '600' },
    sisaTxt: { fontSize: 13, marginTop: 10, color: 'rgba(0,0,0,0.54)' },
    sebelumTglContainer: { flexDirection: 'row', marginTop: 10, marginBottom: 15 },
    deadlineTxt: { fontSize: 14, color: 'rgba(0,0,0,0.54)', fontWeight: '400' },
    bigBtnGreen: { backgroundColor: '#42b549', borderRadius: 3, width: '95%' },
})


export default DigitalTransferPage