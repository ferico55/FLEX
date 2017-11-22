import React from 'react'
import { Image, StyleSheet, View, TouchableOpacity, Text } from 'react-native'
import entities from 'entities'
import { ReactTPRoutes } from 'NativeModules'

const styles = StyleSheet.create({
  deletedProductContainer: {
    width: 52,
    height: 52,
    padding: 8,
    backgroundColor: 'rgb(242,242,242)',
    borderWidth: 1,
    borderColor: 'rgb(224,224,224)',
  },
  itemContainer: {
    flexDirection: 'row',
    alignItems: 'center',
    paddingHorizontal: 8,
  },
  productName: {
    color: 'rgba(0,0,0,0.7)',
    fontSize: 15,
    lineHeight: 18,
    fontWeight: '500',
  },
  separator: {
    height: 1,
    flex: 1,
    borderTopWidth: 1,
    borderColor: '#rgb(224,224,224)',
  },
  actionButton: {
    paddingHorizontal: 8,
    flexDirection: 'row',
    justifyContent: 'flex-end',
    alignItems: 'center',
    marginTop: 16,
    marginBottom: 16,
  },
  actionText: {
    fontSize: 15,
    lineHeight: 21,
    color: 'rgb(66, 181, 73)',
  },
})

const ReviewCardHeader = ({ item, shopID, isHeaderHidden }) => {
  if (isHeaderHidden) {
    return null
  }
  let subtitle
  let title = entities.decodeHTML(item.product_data.product_name)
  let image = (
    <Image
      source={{ uri: item.product_data.product_image_url }}
      style={{
        width: 52,
        height: 52,
        borderRadius: 3,
      }}
    />
  )

  if (item.product_data.product_status === 0) {
    title = 'Produk telah dihapus'
    image = (
      <View style={styles.deletedProductContainer}>
        <Image
          source={{ uri: 'icon_product_deleted' }}
          style={{
            width: 32,
            height: 32,
            borderRadius: 3,
          }}
        />
      </View>
    )
    if (!item.review_has_reviewed) {
      subtitle = (
        <Text style={{ fontSize: 11, color: 'rgba(0,0,0,0.38)' }}>
          {'Belum diulas'}
        </Text>
      )
    } else if (item.review_is_skipped) {
      subtitle = (
        <Text style={{ fontSize: 11, color: 'rgba(0,0,0,0.38)' }}>
          {'Ulasan telah dilewati'}
        </Text>
      )
    }
  } else if (
    !item.review_has_reviewed &&
    item.product_data.shop_id === shopID
  ) {
    subtitle = (
      <Text style={{ fontSize: 11, color: 'rgba(0,0,0,0.38)' }}>
        {'Belum diulas'}
      </Text>
    )
  } else if (item.review_is_skipped) {
    subtitle = (
      <Text style={{ fontSize: 11, color: 'rgba(0,0,0,0.38)' }}>
        {'Ulasan telah dilewati'}
      </Text>
    )
  }
  return (
    <View>
      <TouchableOpacity
        onPress={() => {
          if (item.product_data.product_status !== 0) {
            ReactTPRoutes.navigate(
              `tokopedia://product/${item.product_data.product_id}`,
            )
          }
        }}
      >
        <View style={styles.itemContainer}>
          {image}
          <View
            style={{
              flexDirection: 'column',
              marginLeft: 8,
              alignContent: 'center',
              flex: 1,
            }}
          >
            <Text style={styles.productName} numberOfLines={0}>
              {title}
            </Text>
            {subtitle}
          </View>
        </View>
      </TouchableOpacity>
      <View style={[styles.separator, { marginTop: 16 }]} />
      {!item.review_has_reviewed &&
      item.product_data.shop_id !== shopID && (
        <View style={styles.actionButton}>
          <Text style={styles.actionText}>{'Beri Ulasan'}</Text>
          <Image
            source={{ uri: 'icon_caret_next_green' }}
            style={{ width: 9, height: 14, marginLeft: 8 }}
          />
        </View>
      )}
    </View>
  )
}

export default ReviewCardHeader
