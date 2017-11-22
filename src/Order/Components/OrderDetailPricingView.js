import React from 'react'
import { Text, View, StyleSheet } from 'react-native'

const greylineColor = 'rgba(0, 0, 0, 0.12)'
const greyTextColor = 'rgba(0, 0, 0, 0.38)'
const styles = StyleSheet.create({
  container: {
    marginTop: 6,
    paddingTop: 16,
    backgroundColor: 'white',
    shadowOffset: {
      width: 0,
      height: 1,
    },
    shadowRadius: 2,
    shadowOpacity: 0.2,
  },
})

const OrderDetailPricingView = ({ summary }) => {
  if (!summary) {
    return null
  }
  const pricingData = [
    {
      title: 'Jumlah Barang',
      value: `${summary.total_item} Barang (${summary.total_weight})`,
    },
    { title: 'Total Belanja', value: summary.items_price },
    { title: 'Ongkos Kirim', value: summary.shipping_price },
    { title: 'Biaya Asuransi', value: summary.insurance_price },
    { title: 'Biaya Tambahan', value: summary.additional_price },
  ]
  return (
    <View style={styles.container}>
      <View style={{ paddingHorizontal: 16 }}>
        {pricingData.map((data, index) => (
          <View key={index} style={{ flexDirection: 'row', marginBottom: 18 }}>
            <View style={{ flex: 1 }}>
              <Text style={{ fontSize: 14 }}>{data.title}</Text>
            </View>
            <View style={{ flex: 1, flexDirection: 'row-reverse' }}>
              <Text style={{ fontSize: 14, color: greyTextColor }}>
                {data.value}
              </Text>
            </View>
          </View>
        ))}
      </View>
      <View style={{ height: 0.5, backgroundColor: greylineColor }} />
      <View
        style={{
          height: 46,
          flexDirection: 'row',
          alignItems: 'center',
          paddingHorizontal: 16,
        }}
      >
        <View style={{ flex: 1, flexDirection: 'row' }}>
          <Text style={{ fontSize: 14, fontWeight: '600' }}>
            Total Pembayaran
          </Text>
        </View>
        <View style={{ flex: 1, flexDirection: 'row-reverse' }}>
          <Text style={{ fontSize: 14, fontWeight: 'bold', color: '#ff5722' }}>
            {summary.total_price}
          </Text>
        </View>
      </View>
    </View>
  )
}

export default OrderDetailPricingView
