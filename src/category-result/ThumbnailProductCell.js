import React from 'react'
import { TouchableOpacity, Text, View, Image } from 'react-native'
import HTMLView from 'react-native-htmlview'

import Icon from 'react-native-vector-icons/Ionicons'
import { ReactTPRoutes } from 'NativeModules'
import WishlistCategoryButton from './WishlistCategoryButton'
import { ProductLabels, Badges } from './CellHelper'

import { ProductCellThumbnailViewModel } from './ProductCellViewModel'

const styles = require('./CellStylesheet')

export default class ThumbnailProductCell extends React.PureComponent {
  render() {
    const viewModel = ProductCellThumbnailViewModel(this.props.cellData)

    return (
      <TouchableOpacity
        key={viewModel.productId}
        onPress={() => {
          this.props.tracker()
          ReactTPRoutes.navigate(`tokopedia://product/${viewModel.productId}`)
        }}
        style={{
          backgroundColor: 'white',
          flex: 1,
          borderLeftWidth: 1,
          borderBottomWidth: 1,
          borderColor: 'rgba(224,224,224,1)',
          overflow: 'hidden',
        }}
        activeOpacity={1}
      >
        <Image
          key={viewModel.productImage}
          source={{ uri: viewModel.productImage }}
          style={styles.thumbnailImageGrid}
        />
        <Text numberOfLines={1} style={styles.productName}>
          {viewModel.productName}
        </Text>
        <View
          style={{
            flexDirection: 'row',
            justifyContent: 'space-between',
            alignItems: 'center',
            marginBottom: 5,
          }}
        >
          <Text style={[styles.productPrice, { marginBottom: 0 }]}>
            {viewModel.productPrice}
          </Text>
          <ProductLabels labels={viewModel.productLabels} />
        </View>
        <Text style={styles.discussion}>
          {viewModel.productTalkCount} Diskusi - {viewModel.productReviewCount}{' '}
          Ulasan
        </Text>
        <HTMLView
          RootComponent={Text}
          style={styles.shopName}
          value={viewModel.shopName}
        />
        <View
          style={{
            flexDirection: 'row',
            justifyContent: 'space-between',
            alignItems: 'center',
            marginBottom: 10,
            marginRight: 10,
          }}
        >
          <View
            style={{
              flex: 2,
              flexDirection: 'row',
              alignItems: 'center',
              marginRight: 2,
            }}
          >
            <Icon style={{ marginLeft: 10 }} name="ios-pin-outline" size={10} />
            <Text numberOfLines={1} style={styles.shopLocation}>
              {viewModel.shopLocation}
            </Text>
          </View>
          <View
            style={{
              flex: 1,
              flexDirection: 'row',
              justifyContent: 'flex-end',
              alignItems: 'center',
            }}
          >
            <Badges badges={viewModel.badges} productId={viewModel.productId} />
          </View>
        </View>

        {!this.props.isTopAds && (
          <WishlistCategoryButton
            isWishlist={viewModel.isOnWishlist || false}
            productId={viewModel.productId}
            didTapWishlist={isOnWishlist =>
              this.props.didTapWishlist(isOnWishlist)}
          />
        )}
      </TouchableOpacity>
    )
  }
}
