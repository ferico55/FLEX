import React, { Component } from 'react'
import {
  Button,
  StyleSheet,
  TouchableNativeFeedback,
  TouchableOpacity,
  Text,
  View,
  Image,
  Dimensions
} from 'react-native'

import {
  TKPReactAnalytics
} from 'NativeModules'

import Icon from 'react-native-vector-icons/Ionicons'
import WishlistCategoryButton from './WishlistCategoryButton'
import CellHelper from './CellHelper'
import DeviceInfo from 'react-native-device-info';

const screenWidth = Dimensions.get('window').width;

export default class ListProductCell extends React.PureComponent {

  render() {
    let viewModel = {}

    viewModel.productId = this.props.isTopAds ? this.props.cellData.product.id : this.props.cellData.product_id
    viewModel.productImage = this.props.isTopAds ? this.props.cellData.product.image.s_ecs : this.props.cellData.product_image
    viewModel.productName = this.props.isTopAds ? this.props.cellData.product.name : this.props.cellData.product_name
    viewModel.productPrice = this.props.isTopAds ? this.props.cellData.product.price_format : this.props.cellData.product_price
    viewModel.productRate = this.props.isTopAds ? this.props.cellData.product.product_rating : this.props.cellData.rate
    viewModel.productReviewCount = this.props.isTopAds ? this.props.cellData.product.count_review_format : this.props.cellData.product_review_count
    viewModel.productLabels = this.props.isTopAds ? this.props.cellData.product.labels : this.props.cellData.labels
    viewModel.shopName = this.props.isTopAds ? this.props.cellData.shop.name : this.props.cellData.shop_name
    viewModel.shopLocation = this.props.isTopAds ? this.props.cellData.shop.location : this.props.cellData.shop_location
    viewModel.badges = this.props.isTopAds ? this.props.cellData.shop.badges : this.props.cellData.badges
    viewModel.isOnWishlist = this.props.isTopAds ? false : this.props.cellData.isOnWishlist

    const cellWidth = DeviceInfo.isTablet() ? screenWidth / 2 : screenWidth

    return(
      <TouchableOpacity
        key={viewModel.productId}
        onPress={() => {

          this.props.navigation.navigate('tproutes', { url: 'tokopedia://product/' + viewModel.productId });
        }}
        style={{height: DeviceInfo.isTablet() ? 160 : undefined ,backgroundColor: 'white', width: cellWidth, overflow: 'hidden', borderLeftWidth: 1, borderLeftColor: 'rgba(224,224,224,1)'}}
        activeOpacity={1}>
        <View style={{flex: 1, flexDirection: 'row', borderBottomWidth: 1, borderColor:'rgba(224,224,224,1)'}}>
          <Image source={{ uri: viewModel.productImage }} style={styles.thumbnailImageList}/>
          <View style={{marginTop:10, flex: 1}}>
            <Text style={[styles.productName, {marginRight: 35, height: DeviceInfo.isTablet() ? 50 : undefined }]}>{viewModel.productName}</Text>
            <Text style={styles.productPrice}>{viewModel.productPrice}</Text>
              {viewModel.productRate == null || viewModel.productRate == 0 ? <View/> : (
                <View style={{flexDirection: 'row', alignItems:'center', marginLeft: 10, marginBottom: 6}}>
                {CellHelper.renderStar(viewModel.productRate, viewModel.productReviewCount)}
              </View>
            )}

              <View style={{marginLeft: 10, marginBottom: 4, flexDirection: 'row'}}>
                {CellHelper.renderLabels(viewModel.productLabels)}
              </View>
            <Text style={styles.shopName}>{viewModel.shopName}</Text>
              <View style={{flexDirection: 'row', justifyContent: 'space-between', alignItems: 'center', marginBottom: 10, marginRight: 10}}>
                  <View style={{flexDirection: 'row', alignItems: 'center'}}>
                    <Icon style={{marginLeft: 10}} name='ios-pin-outline' size={10}/>
                    <Text style={styles.shopLocation}>{viewModel.shopLocation}</Text>
                  </View>
                  <View style={{flexDirection: 'row', alignItems: 'center'}}>
                    {viewModel.badges != null  ?
                      viewModel.badges.map((badge) =>
                        <Image key={badge.image_url} style={{width: 15, height: 15}} source={{uri: badge.image_url}}/>
                      ):(
                      <View/>
                    )}
                  </View>

              </View>
          </View>
        </View>

        {this.props.isTopAds ? <View/> : (
          <WishlistCategoryButton
          isWishlist={viewModel.isOnWishlist || false}
          productId={viewModel.productId}
          didTapWishlist={(isOnWishlist) =>
            this.props.didTapWishlist(isOnWishlist)
          }/>
        )}

      </TouchableOpacity>
    )
  }
}

const styles = require('./CellStylesheet');
