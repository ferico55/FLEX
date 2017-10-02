import React, { Component } from 'react'
import {
  Button,
  StyleSheet,
  TouchableNativeFeedback,
  TouchableOpacity,
  Platform,
  Text,
  View,
  Image,
  Alert,
  NativeEventEmitter
} from 'react-native'
import Icon from 'react-native-vector-icons/Ionicons'

import {
  ReactUserManager,
  ReactNetworkManager,
  TKPReactURLManager,
  ReactCategoryResultManager,
  ReactInteractionHelper,
  TKPReactAnalytics,
  EventManager
} from 'NativeModules'

let nativeEventEmitter = new NativeEventEmitter(EventManager);

export default class WishlistCategoryButton extends Component {

  componentWillMount(){
    this.subscription = nativeEventEmitter.addListener("didRemoveWishlistProduct", (productId) => {
      if (productId == this.props.productId){
        this.props.didTapWishlist(false)
        this.setState({
          isWishlist: false
        })
      }
    });

    this.subscription = nativeEventEmitter.addListener("didWishlistProduct", (productId) => {
      if (productId == this.props.productId){
        this.props.didTapWishlist(true)
        this.setState({
          isWishlist: true
        })
      }
    });
  }

  componentWillUnmount(){
    this.subscription.remove()
  }

  constructor(props) {
    super(props)
    this.state = {
      isWishlist: this.props.isWishlist
    }
  }

  _removeFromWishlist = (productId) => {
    ReactUserManager.getUserId()
      .then(userId => {
        if(userId == '0') {
          ReactCategoryResultManager.showLoginModal()
          return
        }

        return ReactNetworkManager.request({
          method: 'DELETE',
          baseUrl: TKPReactURLManager.mojitoUrl,
          path: '/users/'+ userId +'/wishlist/'+ productId +'/v1.1',
          params: {},
          headers: {'X-User-ID' : ReactUserManager.userId},
        })
      .then((response) => {
        if (response!= undefined && response.message_error != undefined) {
          ReactInteractionHelper.showStickyAlert(response.message_error[0])
          return
        }

        this.props.didTapWishlist(false)
        this.setState({
          isWishlist: false
        })
        ReactInteractionHelper.showStickyAlert("Anda telah berhasil menghapus wishlist")
          return productId
        }).catch((error) => {
          ReactInteractionHelper.showErrorStickyAlert(error.message)
        })
      })
  }

  _addToWishlist = (productId) => {

    TKPReactAnalytics.trackEvent({
      name: 'clickWishlist',
      category: 'Product Detail Page',
      action: 'Click',
      label: 'Add to Wishlist'
    })

    ReactUserManager.getUserId()
      .then(userId => {
          if(userId == '0') {
            ReactCategoryResultManager.showLoginModal()
            return
          }

          return ReactNetworkManager.request({
            method: 'POST',
            baseUrl: TKPReactURLManager.mojitoUrl,
            path: '/users/'+ userId +'/wishlist/'+ productId +'/v1.1',
            params: {},
            headers: {'X-User-ID' : userId},
          })
      .then((response) => {
        if (response != undefined && response.message_error != undefined) {
          ReactInteractionHelper.showErrorStickyAlert(response.message_error[0])
          return
        }

        this.props.didTapWishlist(true)
        this.setState({
          isWishlist: true
        })

        return productId
      })
      .catch((error) => {
        ReactInteractionHelper.showErrorStickyAlert(error.message)
      })
    })
  }

  _onTap = (productId) => {
    if (this.state.isWishlist) {
      this._removeFromWishlist(productId)
    } else {
      this._addToWishlist(productId)
    }
  }
  render() {
    const productId = this.props.productId
    const Touchable = Platform.OS === 'android' ? TouchableNativeFeedback : TouchableOpacity
    return (
      <View style={styles.wrapper}>
        <Touchable style={{flex: 1}} onPress={() => this._onTap(productId)}>
           <View style={{marginRight: 6, marginTop: 8}}>
            {
              this.state.isWishlist ? (<Image source={require('../img/icon-love-active.png')} style={{height: 20, width: 23}} resizeMode='contain' />) :
                (<Image source={require('../img/icon-love.png')} style={{height: 20, width: 23}} resizeMode='contain' />)
            }
          </View>
        </Touchable>
      </View>
    )
  }
}

const styles = StyleSheet.create({
  wrapper: {
    position: 'absolute',
    right: -7,
    top: -5,
    paddingTop: 2,
    paddingRight: 0,
    paddingBottom: 1,
    paddingLeft: 2,
    backgroundColor: '#fff',
    borderWidth: 0,
    width: 35,
    height: 35,
    borderRadius: 20,
    elevation: 4,
    justifyContent: 'center',
    alignItems: 'center',
    shadowOffset: { height: 1, width: 1},
    shadowColor: "#000000",
    shadowOpacity: 0.3
  }
})
