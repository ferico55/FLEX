import React from 'react'
import find from 'lodash/find'
import filter from 'lodash/filter'
import indexOf from 'lodash/indexOf'
import { Text, View, StyleSheet, TouchableOpacity } from 'react-native'

const mainGreen = 'rgba(66, 181, 73, 1.0)'
const styles = StyleSheet.create({
  container: {
    marginTop: 18,
    backgroundColor: 'white',
    shadowOffset: {
      width: 0,
      height: 1,
    },
    shadowRadius: 2,
    shadowOpacity: 0.2,
    paddingHorizontal: 16,
    paddingTop: 14,
  },
})

const buttons = [
  { id: 'accept_order', title: 'Terima Pesanan' }, // seller
  // { id: 'change_courier', title: 'Ganti Kurir' }, // seller && HIDE FOR NOW
  { id: 'request_pickup', title: 'Request Pickup' }, // seller
  { id: 'confirm_shipping', title: 'Konfirmasi' }, // seller
  // { id: 'finish_order', title: 'Selesai' }, // buyer
  { id: 'change_awb', title: 'Ubah Resi' }, // seller
  { id: 'view_complaint', title: 'Lihat Komplain' }, // BOTH
  // { id: 'receive_confirmation', title: 'Sudah Diterima' }, // buyer
  { id: 'track', title: 'Lacak', status: 1 }, // BOTH
  // { id: 'ask_seller', title: 'Tanya Penjual' }, // buyer
  { id: 'ask_buyer', title: 'Tanya Pembeli' }, // seller
  { id: 'reject_order', title: 'Tolak Pesanan' }, // seller
  { id: 'reject_order', title: 'Batalkan Pengiriman' }, // seler
  // { id: 'request_cancel', title: 'Ajukan Pembatalan' }, // buyer
  // { id: 'complaint', title: 'Komplain' }, // buyer
  // { id: 'cancel_peluang', title: 'Batalkan Pencarian' }, // buyer
]

const OrderDetailButtonView = ({ actionButtons, doAction }) => {
  const showedButtons = filter(
    buttons,
    button => actionButtons[`${button.id}`] > 0,
  )

  if (showedButtons.length < 1) {
    return null
  }

  const isNewOrder =
    actionButtons.accept_order > 0 && actionButtons.reject_order > 0
  if (actionButtons.reject_order > 0) {
    const titleToBeRemoved = isNewOrder
      ? 'Batalkan Pengiriman'
      : 'Tolak Pesanan'
    const soonWillBeDeleted = find(
      showedButtons,
      button => button.title === titleToBeRemoved,
    )
    const index = indexOf(showedButtons, soonWillBeDeleted)
    showedButtons.splice(index, 1)
  }

  return (
    <View style={styles.container}>
      {showedButtons.map(button => (
        <TouchableOpacity
          onPress={() =>
            doAction(
              isNewOrder && button.id === 'reject_order'
                ? 'reject_new_order'
                : button.id,
            )}
          key={`${button.id}${button.title}`}
          style={{
            height: 52,
            alignItems: 'center',
            justifyContent: 'center',
            borderColor: '#e0e0e0',
            borderWidth: actionButtons[`${button.id}`] > 1 ? 0 : 1,
            backgroundColor:
              actionButtons[`${button.id}`] > 1 ? mainGreen : 'white',
            marginBottom: 13,
          }}
        >
          <Text
            style={{
              color: actionButtons[`${button.id}`] > 1 ? 'white' : 'black',
              fontWeight: '500',
              fontSize: 13,
            }}
          >
            {button.title}
          </Text>
        </TouchableOpacity>
      ))}
    </View>
  )
}

export default OrderDetailButtonView
