import React, { Component } from 'react'
import { View, Text, StyleSheet, Image, TouchableOpacity } from 'react-native'
import Navigator from 'native-navigation'

class DetailPage extends Component {
    render(){
        const {
            lblKeyContent,
            lblValueContent,
            lblContainer,
            iconClose,
            totalTagihanContainer,
            lblTitle,
            lblTotal,
        } = styles
        const data = this.props.data
        const {
            deposit_amount,
            tokocash_amount,
            total_amount,
            amount,
            unique_code,
            voucher_amount           
        } = data

        return (
        <Navigator.Config 
            title='Detail Tagihan'
            onLeftPress={() => Navigator.dismiss()}
            leftImage={{
                uri: 'icon_close',
                scale: 2,}}>
            <View style={{ backgroundColor: '#FFF', flex: 1 }}>
                <View style={[lblContainer, { marginTop: 20 }]}>
                    <Text style={lblKeyContent}>Tagihan</Text>
                    <Text style={lblValueContent}>{amount}</Text>
                </View>
                {tokocash_amount !== '0' && tokocash_amount !== undefined && <View style={[lblContainer, { marginTop: 10 }]}>
                    <Text style={lblKeyContent}>TokoCash Terpakai</Text>
                    <Text style={[lblValueContent]}>{tokocash_amount}</Text>
                </View>}
                {deposit_amount !== '0' && deposit_amount !== undefined && <View style={[lblContainer, { marginTop: 10 }]}>
                    <Text style={lblKeyContent}>Saldo Terpakai</Text>
                    <Text style={[lblValueContent]}>{deposit_amount}</Text>
                </View>}
                {unique_code !== '0' && unique_code !== undefined && <View style={[lblContainer, { marginTop: 10 }]}>
                    <Text style={lblKeyContent}>Kode Unik</Text>
                    <Text style={[lblValueContent]}>{unique_code}</Text>
                </View>}
                {voucher_amount !== '0' && voucher_amount !== undefined && <View style={[lblContainer, { marginTop: 20 }]}>
                    <Text style={lblKeyContent}>Penggunaan Voucher</Text>
                    <Text style={[lblValueContent]}>{voucher_amount}</Text>
                </View>}
                <View style={styles.borderLine90} />

                <View style={totalTagihanContainer}>
                    <Text style={lblTotal}>Total Tagihan</Text>
                    <Text style={[lblTotal, { marginRight: 15 }]}>{total_amount}</Text>
                </View>
            </View>
        </Navigator.Config>
        )
    }
}

const styles = StyleSheet.create({
    totalTagihanContainer: { flexDirection: 'row', marginTop: 20, justifyContent: 'space-between' },
    lblTitle: { marginLeft: 17, fontWeight: '400' },
    iconClose: { marginTop: 3, width: 13, height: 13, resizeMode: 'contain' },
    lblTotal: { marginLeft: 15, fontSize: 15, fontWeight: 'bold' },
    lblContainer: { flexDirection: 'row', justifyContent: 'space-between' },
    lblValueContent: { marginRight: 15, fontSize: 15, fontWeight: '300' },
    lblKeyContent: { marginLeft: 15, fontSize: 15, fontWeight: '300' },
    borderLine90: { alignSelf: 'center', borderBottomColor: '#f1f1f1', borderBottomWidth: 1, width: '90%', marginTop: 25 },
    borderLine: { alignSelf: 'center', borderBottomColor: '#f1f1f1', borderBottomWidth: 1, width: '100%' },
})

export default DetailPage