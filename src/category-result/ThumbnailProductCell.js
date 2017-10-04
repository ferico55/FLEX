import React, { Component } from 'react'
import {
  Button,
  StyleSheet,
  TouchableNativeFeedback,
  TouchableOpacity,
  Text,
  View,
  Image,
} from 'react-native'

import {
  TKPReactAnalytics
} from 'NativeModules'

import Icon from 'react-native-vector-icons/Ionicons'
import WishlistCategoryButton from './WishlistCategoryButton'
import CellHelper from './CellHelper'
import HTMLView from 'react-native-htmlview';

export default class ThumbnailProductCell extends React.PureComponent {

  render() {
    let viewModel = {}

    viewModel.productId =  this.props.cellData.product_id
    viewModel.productImage =  this.props.cellData.product_image
    viewModel.productName =  this.props.cellData.product_name
    viewModel.productPrice = this.props.cellData.product_price
    viewModel.productReviewCount = this.props.cellData.product_review_count
    viewModel.productLabels = this.props.cellData.labels
    viewModel.shopName = this.props.cellData.shop_name
    viewModel.shopLocation = this.props.cellData.shop_location
    viewModel.badges = this.props.cellData.badges
    viewModel.isOnWishlist = this.props.cellData.isOnWishlist
    viewModel.productReviewCount = this.props.cellData.product_review_count
    viewModel.productTalkCount = this.props.cellData.product_talk_count

    return(
      <TouchableOpacity
        key={viewModel.productId}
        onPress={() => {
          this.props.tracker()
          this.props.navigation.navigate('tproutes', { url: 'tokopedia://product/' + viewModel.productId});
        }}
        style={{backgroundColor: 'white', flex:1, borderLeftWidth: 1, borderBottomWidth: 1, borderColor:'rgba(224,224,224,1)', overflow: 'hidden'}}
        activeOpacity={1}>
        <Image key={viewModel.productImage} source={{ uri: viewModel.productImage }} style={styles.thumbnailImageGrid}/>
        <Text
          numberOfLines={1}
          style={styles.productName}
          >
          {viewModel.productName}
        </Text>
        <View style={{flexDirection:'row', justifyContent:'space-between', alignItems:'center', marginBottom: 5}}>
          <Text style={[styles.productPrice,{marginBottom: 0}]}>
            {viewModel.productPrice}
          </Text>
          <View style={{flexDirection:'row', marginRight: 5}}>
            {CellHelper.renderLabels(viewModel.productLabels)}
          </View>
        </View>
        <Text style={styles.discussion}>
          {viewModel.productTalkCount} Diskusi - {viewModel.productReviewCount} Ulasan
        </Text>
        <HTMLView RootComponent={Text} style={styles.shopName} value={viewModel.shopName}/>
        <View style={{flexDirection: 'row', justifyContent: 'space-between', alignItems: 'center', marginBottom: 10, marginRight: 10}}>
            <View style={{flex: 2, flexDirection: 'row', alignItems: 'center', marginRight: 2}}>
              <Icon style={{marginLeft: 10}} name='ios-pin-outline' size={10}/>
              <Text numberOfLines={1} style={styles.shopLocation}>{viewModel.shopLocation}</Text>
            </View>
            <View style={{flex: 1, flexDirection: 'row', justifyContent:'flex-end', alignItems: 'center'}}>
              {viewModel.badges != null  ?
                viewModel.badges.map((badge) =>
                  <Image key={badge.image_url+viewModel.productId} style={{width: 15, height: 15}} source={{uri: badge.image_url}}/>
                ):(
                <View/>
              )}
            </View>

        </View>

        {this.props.isTopAds ? <View/> : (
          <WishlistCategoryButton
          isWishlist={viewModel.isOnWishlist || false}
          productId={viewModel.productId}
          didTapWishlist={(isOnWishlist) =>
            this.props.didTapWishlist(isOnWishlist)
          } />
        )}

      </TouchableOpacity>
    )
  }
}

const styles = require('./CellStylesheet');
