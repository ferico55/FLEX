import React from 'react'
import { TouchableOpacity, Text, View, Image, Dimensions } from 'react-native'
import DeviceInfo from 'react-native-device-info'

import Icon from 'react-native-vector-icons/Ionicons'
import { ReactTPRoutes } from 'NativeModules'
import WishlistCategoryButton from './WishlistCategoryButton'
import { Stars, ProductLabels, Badges } from './CellHelper'
import { ProductCellViewModel } from './ProductCellViewModel'

const styles = require('./CellStylesheet')

const screenWidth = Dimensions.get('window').width

export default class ListProductCell extends React.PureComponent {
  render() {
    const viewModel = ProductCellViewModel(
      this.props.cellData,
      this.props.isTopAds,
    )
    const cellWidth = DeviceInfo.isTablet() ? screenWidth / 2 : screenWidth

    return (
      <TouchableOpacity
        key={viewModel.productId}
        onPress={() => {
          this.props.tracker()
          ReactTPRoutes.navigate(`tokopedia://product/${viewModel.productId}`)
        }}
        style={{
          height: DeviceInfo.isTablet() ? 160 : undefined,
          backgroundColor: 'white',
          width: cellWidth,
          overflow: 'hidden',
          borderLeftWidth: 1,
          borderLeftColor: 'rgba(224,224,224,1)',
        }}
        activeOpacity={1}
      >
        <View
          style={{
            flex: 1,
            flexDirection: 'row',
            borderBottomWidth: 1,
            borderColor: 'rgba(224,224,224,1)',
          }}
        >
          <Image
            key={`${viewModel.productImage}list`}
            source={{ uri: viewModel.productImage }}
            style={styles.thumbnailImageList}
          />
          <View style={{ marginTop: 10, flex: 1 }}>
            <Text
              style={[
                styles.productName,
                {
                  marginRight: 35,
                  height: DeviceInfo.isTablet() ? 50 : undefined,
                },
              ]}
            >
              {viewModel.productName}
            </Text>
            <Text style={styles.productPrice}>{viewModel.productPrice}</Text>
            <Stars
              rate={viewModel.productRate}
              totalReview={viewModel.productReviewCount}
            />
            <ProductLabels labels={viewModel.productLabels} />
            <Text style={styles.shopName}>{viewModel.shopName}</Text>
            <View
              style={{
                flexDirection: 'row',
                justifyContent: 'space-between',
                alignItems: 'center',
                marginBottom: 10,
                marginRight: 10,
              }}
            >
              <View style={{ flexDirection: 'row', alignItems: 'center' }}>
                <Icon
                  style={{ marginLeft: 10 }}
                  name="ios-pin-outline"
                  size={10}
                />
                <Text style={styles.shopLocation}>
                  {viewModel.shopLocation}
                </Text>
              </View>
              <View style={{ flexDirection: 'row', alignItems: 'center' }}>
                <Badges
                  badges={viewModel.badges}
                  productId={viewModel.productId}
                />
              </View>
            </View>
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
