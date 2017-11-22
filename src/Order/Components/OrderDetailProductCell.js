import React from 'react'
import { Text, View, StyleSheet, Image, TouchableOpacity } from 'react-native'

const greylineColor = 'rgba(0, 0, 0, 0.12)'
const greyTextColor = 'rgba(0, 0, 0, 0.38)'
const styles = StyleSheet.create({
  container: {
    backgroundColor: 'white',
    shadowOffset: {
      width: 0,
      height: 1,
    },
    shadowRadius: 2,
    shadowOpacity: 0.2,
    marginBottom: 10,
  },
})

const OrderDetailProductCell = ({ product, action }) => (
  <TouchableOpacity style={styles.container} onPress={() => action(product.id)}>
    <View
      style={{
        flexDirection: 'row',
        paddingTop: 10,
        paddingBottom: 16,
        paddingHorizontal: 10,
      }}
    >
      <Image
        source={{ uri: product.thumbnail }}
        style={{ width: 52, height: 52 }}
      />
      <View
        style={{
          marginLeft: 10,
          marginRight: 30,
          flex: 1,
        }}
      >
        <Text
          numberOfLines={0}
          style={{ marginBottom: 1, fontSize: 14, fontWeight: '600' }}
        >
          {product.name}
        </Text>
        <Text style={{ fontSize: 14, fontWeight: '600', color: '#ff5722' }}>
          {product.price}
        </Text>
      </View>
      <View>
        <Text
          style={{
            marginBottom: 1.5,
            fontSize: 11,
            fontWeight: '200',
            textAlign: 'right',
          }}
        >
          Jumlah :
        </Text>
        <Text
          style={{
            fontSize: 11,
            fontWeight: '200',
            color: greyTextColor,
            textAlign: 'right',
          }}
        >
          {`${product.quantity} Barang`}
        </Text>
      </View>
    </View>
    <View style={{ height: 0.5, backgroundColor: greylineColor }} />
    <View
      style={{
        flexDirection: 'row',
        paddingHorizontal: 10,
        paddingVertical: 15,
      }}
    >
      <Text
        numberOfLines={0}
        style={{
          fontSize: 14,
          color: product.note == '' ? greyTextColor : 'black',
        }}
      >
        {product.note == '' ? 'Tidak ada keterangan' : product.note}
      </Text>
    </View>
  </TouchableOpacity>
)

export default OrderDetailProductCell
