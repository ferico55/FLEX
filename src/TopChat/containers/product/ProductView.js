/* @flow */

import React, { Component } from 'react'
import {
  View,
  Text,
  StyleSheet,
  TouchableHighlight,
  FlatList,
  Image,
  Dimensions,
  ActivityIndicator,
} from 'react-native'
import Navigator from 'native-navigation'
import SearchBar from 'react-native-search-bar'
import { TKPReactAnalytics, RNSearchBarManager } from 'NativeModules'
import { Loading, Overlay } from '@TopChatComponents/'

const { height } = Dimensions.get('window')
const WINDOW_HEIGHT = height

class ProductView extends Component {
  constructor(props) {
    super(props)
    this.state = {
      loading: true,
      overlay: false,
      overlayBottom: 0,
      keyword: '',
    }
    this.params = {
      ...props.params,
      keyword: '',
    }
    this.page = 2
  }

  componentWillMount() {
    this.props.fetchShopProducts(this.params)
  }

  componentWillReceiveProps(nextProps) {
    if (nextProps.products.status === 'OK' && !nextProps.products.loading) {
      this.setState({
        loading: false,
        overlay: false,
      })
    }
  }

  onPressSendChat = url => {
    const data = {
      ...this.props.sendChatAttr,
      message: url,
    }
    const trackerParams = {
      name: 'ClickChatDetail',
      category: 'chat detail',
      action: 'click on send product attachemnt',
      label: '',
    }
    TKPReactAnalytics.trackEvent(trackerParams)
    this.props.sendMessage(data)
    Navigator.dismiss()
  }

  renderItem = ({ item }) => (
    <TouchableHighlight
      onPress={() => this.onPressSendChat(item.product_url)}
      underlayColor={'#f3fef3'}
    >
      <View
        style={{
          flex:1,
          flexDirection: 'row',
          padding: 15,
          borderBottomColor: 'rgba(0,0,0,0.05)',
          borderBottomWidth: 1,
        }}
      >
        <View style={{justifyContent:'center'}}>
          <Image
            source={{ uri: item.product_image }}
            style={{ height: 54, width: 54, borderRadius: 3 }}
            resizeMode={'contain'}
          />
        </View>
        <View
          style={{
            flex:1,
            justifyContent: 'center',
            paddingVertical: 5,
            paddingHorizontal: 10,
          }}
        >
          <Text numberOfLines={2} style={styles.productName}>{item.product_name}</Text>
          <Text style={styles.productPrice}>{item.product_price}</Text>
        </View>
      </View>
    </TouchableHighlight>
  )

  renderLoading = () => {
    if (this.props.products.list.length === this.props.products.total_data) {
      return null
    }

    return (
      <View
        style={{ height: 40, alignItems: 'center', justifyContent: 'center' }}
      >
        <ActivityIndicator animating size={'small'} />
      </View>
    )
  }

  onPullRefresh = () => {
    this.page = 1
    this.params = {
      ...this.params,
      keyword: '',
      page: this.page,
    }
    this.props.fetchShopProducts(this.params)
  }

  onKeyboardWillShow = ({ endCoordinates: { height } }) => {
    this.setState({
      overlayBottom: height,
    })
  }

  onKeyboardWillHide = () => {
    this.setState({
      overlayBottom: 0,
    })
  }

  onBlur = () => {
    this.setState(prevState => ({
      overlay: false,
    }))
  }

  onFocus = () => {
    this.setState({ overlay: true })
  }

  renderEmptyList = () => (
    <View
      style={{
        flex:1,
        backgroundColor:'#E1E1E1',
        alignItems: 'center',
        justifyContent: 'center',
      }}
    >
      <Image
        source={{ uri: 'icon_no_data_grey' }}
        style={{ width: 80, height: 80 }}
        resizeMode={'contain'}
      />
      <Text style={{ fontSize: 17, fontWeight: '500' }}>
        Toko ini belum memiliki produk
      </Text>
    </View>
  )

  renderScreen = loading => {
    if (loading) {
      return <Loading />
    }

    if(this.props.products.list.length === 0 ){
      return this.renderEmptyList()
    }

    return (
      <FlatList
        data={this.props.products.list}
        keyExtractor={(item, index) => index}
        renderItem={this.renderItem}
        keyboardDismissMode={'on-drag'}
        onScroll={this.onScroll}
        onRefresh={this.onPullRefresh}
        refreshing={this.props.products.loading && !this.state.overlay}
        onKeyboardWillShow={this.onKeyboardWillShow}
        onKeyboardWillHide={this.onKeyboardWillHide}
        ListFooterComponent={this.renderLoading}
      />
    )
  }

  onScroll = ({
    nativeEvent: { contentOffset: { y }, contentSize: { height } },
  }) => {
    if (
      WINDOW_HEIGHT + y >= height &&
      !this.props.products.loading &&
      this.props.products.list.length < this.props.products.total_data
    ) {
      this.params = {
        ...this.params,
        page: this.page,
      }
      this.props.fetchShopProducts(this.params)
      this.page += 1
    }
  }

  onSearchButtonPress = () => {
    this.page = 1
    this.params = {
      ...this.params,
      page: this.page,
      keyword: this.state.keyword,
    }

    this.props.fetchShopProducts(this.params)
  }

  onChangeText = text => {
    this.setState({
      keyword: text,
      overlay: true,
    })
  }

  onDismissOverlay = () => {
    if (this.state.keyword.trim() === '' && this.params.keyword !== '') {
      this.params = {
        ...this.params,
        keyword: '',
      }
      this.props.fetchShopProducts(this.params)
    }
    this.refs.chatSearchBar.unFocus()
  }

  renderOverlay = overlay => {
    if (overlay && !this.props.fromIpad) {
      return (
        <Overlay
          bottom={this.state.overlayBottom}
          animating={this.props.products.loading}
          onDismiss={this.onDismissOverlay}
          top={RNSearchBarManager.ComponentHeight}
        />
      )
    }

    return null
  }

  renderSearchBar = () => {
    if (this.props.products.list.length > 0) {
      return (
        <SearchBar
          ref="chatSearchBar"
          placeholder="Cari produk di semua etalase"
          backgroundColor="#f1f1f1"
          onChangeText={this.onChangeText}
          onBlur={this.onBlur}
          onFocus={this.onFocus}
          onSearchButtonPress={this.onSearchButtonPress}
        />
      )
    }

    return null
  }

  render() {
    return (
      <Navigator.Config
        leftImage={{
          uri: 'icon_close',
          scale: 2,
        }}
        onLeftPress={Navigator.dismiss}
        title={'Lampirkan Produk'}
      >
        <View style={styles.container}>
          {this.renderSearchBar()}
          {this.renderScreen(this.state.loading)}
          {this.renderOverlay(this.state.overlay)}
        </View>
      </Navigator.Config>
    )
  }
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
  },
  productName: {
    fontSize: 14,
    color: 'rgba(0,0,0,0.7)',
    marginBottom: 2.5,
    fontWeight: 'bold',
  },
  productPrice: {
    fontSize: 14,
    color: 'rgb(255,87,34)',
    marginTop: 2.5,
    fontWeight: 'bold',
  },
})

export default ProductView
