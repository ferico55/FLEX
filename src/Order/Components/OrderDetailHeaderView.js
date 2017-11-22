import React from 'react'
import {
  Text,
  View,
  StyleSheet,
  TouchableOpacity,
  Image,
  Clipboard,
} from 'react-native'
import ToolTip from 'react-native-tooltip'
import { imageSourceDetail } from '../Components/LastStatusImageSource'

const mainGreen = 'rgba(66, 181, 73, 1.0)'
const greyTextColor = 'rgba(0, 0, 0, 0.38)'
const greylineColor = 'rgba(0, 0, 0, 0.12)'
const styles = StyleSheet.create({
  container: {
    backgroundColor: 'white',
    marginBottom: 14,
    shadowOffset: {
      width: 0,
      height: 1,
    },
    shadowRadius: 2,
    shadowOpacity: 0.2,
  },
})

const OrderDetailHeaderView = ({
  invoice,
  status,
  detail,
  goToHistory,
  seeInvoice,
  orderStatus,
}) => {
  if (!detail) {
    return null
  }

  let showHistory = true
  if (orderStatus == 220 || orderStatus == 400 || orderStatus == 401) {
    showHistory = false
  }

  return (
    <View style={styles.container}>
      {showHistory ? (
        <View>
          <View style={{ flexDirection: 'row', flex: 1, height: 65 }}>
            <View
              style={{
                alignItems: 'center',
                marginRight: 17,
                flexDirection: 'row-reverse',
              }}
            >
              <Image source={imageSourceDetail(status.state)} />
            </View>
            <TouchableOpacity
              onPress={goToHistory}
              style={{
                flex: 1,
                justifyContent: 'center',
                paddingLeft: 12,
              }}
            >
              <Text style={{ fontSize: 14, marginBottom: 3 }}>Status</Text>
              <Text style={{ fontSize: 14, color: greyTextColor }}>
                {status.detail}
              </Text>
            </TouchableOpacity>
            <View
              style={{
                width: 25,
                justifyContent: 'center',
              }}
            >
              <Image
                style={{ height: 9, width: 7 }}
                source={{ uri: 'icon_arrow_right_grey' }}
              />
            </View>
          </View>
          <View style={{ height: 0.5, backgroundColor: greylineColor }} />
        </View>
      ) : null}
      <View style={{ flexDirection: 'row' }}>
        <View
          style={{
            marginHorizontal: 17,
            marginTop: 18.5,
            marginBottom: 14,
            flex: 1,
          }}
        >
          <View style={{ marginBottom: 13 }}>
            <Text
              style={{ fontSize: 14, marginBottom: 2, color: greyTextColor }}
            >
              Tanggal Pembelian :
            </Text>
            <Text style={{ fontSize: 14 }}>{detail.payment_verified_date}</Text>
          </View>
          <View style={{ marginBottom: 13 }}>
            <Text
              style={{ fontSize: 14, marginBottom: 2, color: greyTextColor }}
            >
              Pembeli :
            </Text>
            <Text style={{ fontSize: 14 }}>{detail.customer.name}</Text>
          </View>
          <View>
            <Text
              style={{ fontSize: 14, marginBottom: 2, color: greyTextColor }}
            >
              Alamat Pengiriman :
            </Text>
            <Text style={{ fontSize: 14 }}>
              {`${detail.receiver.name}\n${detail.receiver.phone}\n${detail
                .receiver.street}\n${detail.receiver.district}\n${detail
                .receiver.city}\n${detail.receiver.postal}\n${detail.receiver
                .province}\n`}
            </Text>
          </View>
        </View>
        <View
          style={{
            marginHorizontal: 17,
            marginTop: 18.5,
            marginBottom: 14,
            flex: 1,
          }}
        >
          {detail.deadline && (
            <View style={{ marginBottom: 12 }}>
              <Text
                style={{ fontSize: 14, marginBottom: 2, color: greyTextColor }}
              >
                Batal Otomatis :
              </Text>
              <View style={{ flexDirection: 'row' }}>
                <View
                  style={{
                    backgroundColor: `${detail.deadline.color}`,
                    borderRadius: 2,
                    paddingHorizontal: 3,
                    paddingVertical: 1,
                  }}
                >
                  <Text style={{ fontSize: 11, color: 'white' }}>
                    {detail.deadline.text}
                  </Text>
                </View>
              </View>
            </View>
          )}
          <View style={{ marginBottom: 13 }}>
            <Text
              style={{ fontSize: 14, marginBottom: 2, color: greyTextColor }}
            >
              Kurir Pengiriman :
            </Text>
            <Text style={{ fontSize: 14 }}>{`${detail.shipment.name} - ${detail
              .shipment.product_name}`}</Text>
          </View>
          <View style={{ marginBottom: 13 }}>
            <Text
              style={{ fontSize: 14, marginBottom: 2, color: greyTextColor }}
            >
              Terima Sebagian :
            </Text>
            <Text style={{ fontSize: 14 }}>
              {detail.partial_order == 0 ? 'Tidak' : 'Iya'}
            </Text>
          </View>
          {detail.preorder && (
            <View style={{ marginBottom: 12 }}>
              <Text
                style={{ fontSize: 14, marginBottom: 2, color: greyTextColor }}
              >
                Preorder :
              </Text>
              <Text style={{ fontSize: 14 }}>{`${detail.preorder
                .process_time} Hari`}</Text>
            </View>
          )}
          <View style={{ marginBottom: 12 }}>
            <Text
              style={{ fontSize: 14, marginBottom: 2, color: greyTextColor }}
            >
              Dropshipper :
            </Text>
            <Text style={{ fontSize: 14 }}>
              {detail.drop_shipper ? 'Iya' : 'Tidak'}
            </Text>
          </View>
          {detail.drop_shipper && (
            <View style={{ marginBottom: 12 }}>
              <Text
                style={{ fontSize: 14, marginBottom: 2, color: greyTextColor }}
              >
                Nama Dropshiper :
              </Text>
              <Text style={{ fontSize: 14 }}>{detail.drop_shipper.name}</Text>
            </View>
          )}
          {detail.drop_shipper && (
            <View style={{ marginBottom: 12 }}>
              <Text
                style={{ fontSize: 14, marginBottom: 2, color: greyTextColor }}
              >
                Telepon :
              </Text>
              <Text style={{ fontSize: 14 }}>{detail.drop_shipper.phone}</Text>
            </View>
          )}
        </View>
      </View>
      <View style={{ height: 0.5, backgroundColor: greylineColor }} />
      <View style={{ flexDirection: 'row', alignItems: 'center' }}>
        <View
          style={{
            flex: 1,
            flexDirection: 'row',
            height: 55,
            alignItems: 'center',
          }}
        >
          <ToolTip
            actions={[
              {
                text: 'Copy',
                onPress: () => {
                  Clipboard.setString(invoice.text)
                },
              },
            ]}
            underlayColor="transparent"
            longPress
            arrowDirection="down"
            style={{
              marginLeft: 19,
            }}
          >
            <Text
              style={{
                fontSize: 15,
              }}
            >
              {invoice.text}
            </Text>
          </ToolTip>
        </View>
        <TouchableOpacity
          onPress={seeInvoice}
          style={{ height: 55, justifyContent: 'center' }}
        >
          <View style={{ flexDirection: 'row' }}>
            <Text style={{ color: mainGreen, fontSize: 14 }}>Lihat</Text>
            <View
              style={{
                width: 25,
                marginLeft: 9,
                justifyContent: 'center',
              }}
            >
              <Image
                style={{ height: 9, width: 7 }}
                source={{ uri: 'icon_arrow_right_grey' }}
              />
            </View>
          </View>
        </TouchableOpacity>
      </View>
      {orderStatus >= 500 ? (
        <View>
          <View style={{ height: 0.5, backgroundColor: greylineColor }} />
          <View style={{ flexDirection: 'row', alignItems: 'center' }}>
            <View style={{ flex: 1, flexDirection: 'row' }}>
              <View
                style={{
                  marginLeft: 19,
                  height: 60,
                  justifyContent: 'center',
                }}
              >
                <Text
                  style={{
                    fontSize: 14,
                    marginBottom: 2,
                    color: greyTextColor,
                  }}
                >
                  Nomor Resi
                </Text>
                <ToolTip
                  actions={[
                    {
                      text: 'Copy',
                      onPress: () => {
                        Clipboard.setString(detail.shipment.awb)
                      },
                    },
                  ]}
                  underlayColor="transparent"
                  longPress
                  arrowDirection="down"
                >
                  <Text style={{ fontSize: 16 }}>{detail.shipment.awb}</Text>
                </ToolTip>
              </View>
            </View>
          </View>
        </View>
      ) : null}
    </View>
  )
}

export default OrderDetailHeaderView
