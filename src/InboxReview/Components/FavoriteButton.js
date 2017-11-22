import React, { Component } from 'react'
import {
  StyleSheet,
  Text,
  View,
  TouchableOpacity,
  Image,
  ActivityIndicator,
} from 'react-native'

import {
  TKPReactURLManager,
  ReactNetworkManager,
  ReactInteractionHelper,
} from 'NativeModules'

const styles = StyleSheet.create({
  followButton: {
    marginLeft: 8,
    paddingVertical: 11,
    paddingHorizontal: 18,
    flexDirection: 'row',
    height: 40,
    borderRadius: 3,
    backgroundColor: 'rgb(66,181,73)',
    alignItems: 'center',
    justifyContent: 'center',
  },
})

class FavoriteButton extends Component {
  constructor(props) {
    super(props)
    this.state = {
      isLoadingShopFavorite: true,
      isShopFavorited: false,
    }
  }

  componentDidMount() {
    this.getShopInfo()
  }

  getShopInfo = () => {
    ReactNetworkManager.request({
      method: 'GET',
      baseUrl: TKPReactURLManager.v4Url,
      path: '/v4/shop/get_shop_info.pl',
      params: {
        shop_id: this.props.shopID,
      },
    })
      .then(response => {
        this.setState({
          isShopFavorited: response.data.info.shop_already_favorited === 1,
          isLoadingShopFavorite: false,
        })
      })
      .catch(error => {
        console.log(error)
      })
  }

  handleFavoriteAction = () => {
    this.setState({
      isLoadingShopFavorite: true,
    })
    const params = {
      shop_id: this.props.shopID,
    }
    ReactNetworkManager.request({
      method: 'POST',
      baseUrl: TKPReactURLManager.v4Url,
      path: '/v4/action/favorite-shop/fav_shop.pl',
      params,
    })
      .then(response => {
        if (response.data.is_success === 1) {
          if (this.state.isShopFavorited) {
            ReactInteractionHelper.showSuccessAlert(
              'Anda berhenti memfavoritkan toko ini',
            )
          } else {
            ReactInteractionHelper.showSuccessAlert(
              'Anda berhasil memfavoritkan toko ini',
            )
          }
          this.setState({
            isShopFavorited: !this.state.isShopFavorited,
            isLoadingShopFavorite: false,
          })
        }
      })
      .catch(_ => {
        this.setState({
          isLoadingShopFavorite: false,
        })
        ReactInteractionHelper.showDangerAlert(
          'Anda gagal memfavoritkan toko ini',
        )
      })
  }

  render() {
    if (this.props.roleID === 1) {
      return null
    } else if (this.state.isLoadingShopFavorite) {
      return (
        <View
          style={[
            styles.followButton,
            {
              backgroundColor: 'white',
              borderWidth: 1,
              borderColor: 'rgb(224,224,224)',
            },
          ]}
        >
          <ActivityIndicator isLoading style={{ width: 16, height: 16 }} />
        </View>
      )
    } else if (!this.state.isShopFavorited) {
      return (
        <TouchableOpacity onPress={this.handleFavoriteAction}>
          <View style={styles.followButton}>
            <Image
              style={{ width: 12, height: 12, marginRight: 4 }}
              source={{ uri: 'icon_plus_white' }}
            />
            <Text style={{ color: 'white' }}>{'Favoritkan'}</Text>
          </View>
        </TouchableOpacity>
      )
    }
    return (
      <TouchableOpacity onPress={this.handleFavoriteAction}>
        <View
          style={[
            styles.followButton,
            {
              backgroundColor: 'white',
              borderWidth: 1,
              borderColor: 'rgb(224,224,224)',
            },
          ]}
        >
          <Image
            style={{ width: 12, height: 12, marginRight: 4 }}
            source={{ uri: 'icon_check_grey' }}
          />
          <Text style={{ color: 'rgba(0,0,0,0.54)' }}>{'Sudah Favorit'}</Text>
        </View>
      </TouchableOpacity>
    )
  }
}

export default FavoriteButton
