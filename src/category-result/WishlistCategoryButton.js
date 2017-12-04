import React, { Component } from 'react'
import {
  StyleSheet,
  TouchableOpacity,
  View,
  Image,
  NativeEventEmitter,
} from 'react-native'

import {
  ReactUserManager,
  ReactNetworkManager,
  TKPReactURLManager,
  ReactCategoryResultManager,
  ReactInteractionHelper,
  TKPReactAnalytics,
  EventManager,
} from 'NativeModules'

import iconLoveActive from '../img/icon-love-active.png'
import iconLove from '../img/icon-love.png'

const nativeEventEmitter = new NativeEventEmitter(EventManager)

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
    shadowOffset: { height: 1, width: 1 },
    shadowColor: '#000000',
    shadowOpacity: 0.3,
  },
})

export default class WishlistCategoryButton extends Component {
  constructor(props) {
    super(props)
    this.state = {
      isWishlist: this.props.isWishlist,
    }
  }

  componentWillMount() {
    this.subscription = nativeEventEmitter.addListener(
      'didRemoveWishlistProduct',
      productId => {
        if (productId === this.props.productId) {
          this.props.didTapWishlist(false)
          this.setState({
            isWishlist: false,
          })
        }
      },
    )

    this.subscription = nativeEventEmitter.addListener(
      'didWishlistProduct',
      productId => {
        if (productId === this.props.productId) {
          this.props.didTapWishlist(true)
          this.setState({
            isWishlist: true,
          })
        }
      },
    )
  }

  componentWillUnmount() {
    this.subscription.remove()
  }

  onTap = productId => {
    if (this.state.isWishlist) {
      this.removeFromWishlist(productId)
    } else {
      this.addToWishlist(productId)
    }
  }

  addToWishlist = productId => {
    TKPReactAnalytics.trackEvent({
      name: 'clickWishlist',
      category: 'Product Detail Page',
      action: 'Click',
      label: 'Add to Wishlist',
    })

    ReactUserManager.getUserId().then(userId => {
      if (userId === '0') {
        ReactCategoryResultManager.showLoginModal()
        return
      }

      ReactNetworkManager.request({
        method: 'POST',
        baseUrl: TKPReactURLManager.mojitoUrl,
        path: '/wishlist/v1.2',
        params: {
          user_id: userId,
          product_id: productId
        },
        headers: { 'X-User-ID': userId },
      })
        .then(response => {
          if (response !== undefined && response.message_error !== undefined) {
            ReactInteractionHelper.showErrorStickyAlert(
              response.message_error[0],
            )
            return
          }

          this.props.didTapWishlist(true)
          this.setState({
            isWishlist: true,
          })
        })
        .catch(error => {
          ReactInteractionHelper.showErrorStickyAlert(error.message)
        })
    })
  }

  removeFromWishlist = productId => {
    ReactUserManager.getUserId().then(userId => {
      if (userId === '0') {
        ReactCategoryResultManager.showLoginModal()
        return
      }

      ReactNetworkManager.request({
        method: 'DELETE',
        baseUrl: TKPReactURLManager.mojitoUrl,
        path: '/wishlist/v1.2',
        params: {
          user_id: userId,
          product_id: productId
        },
        headers: { 'X-User-ID': ReactUserManager.userId },
      })
        .then(response => {
          if (response !== undefined && response.message_error !== undefined) {
            ReactInteractionHelper.showStickyAlert(response.message_error[0])
            return
          }

          this.props.didTapWishlist(false)
          this.setState({
            isWishlist: false,
          })
          ReactInteractionHelper.showStickyAlert(
            'Anda telah berhasil menghapus wishlist',
          )
        })
        .catch(error => {
          ReactInteractionHelper.showErrorStickyAlert(error.message)
        })
    })
  }

  render() {
    const productId = this.props.productId
    return (
      <View style={styles.wrapper}>
        <TouchableOpacity
          style={{ flex: 1 }}
          onPress={() => this.onTap(productId)}
        >
          <View style={{ marginRight: 6, marginTop: 8 }}>
            <Image
              source={this.state.isWishlist ? iconLoveActive : iconLove}
              style={{ height: 20, width: 23 }}
              resizeMode="contain"
            />
          </View>
        </TouchableOpacity>
      </View>
    )
  }
}
