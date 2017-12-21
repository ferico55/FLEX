import React, { PureComponent } from 'react'
import Navigator from 'native-navigation'
import {
  StyleSheet,
  Text,
  ActivityIndicator,
  View,
  ScrollView,
  RefreshControl,
} from 'react-native'
import { find } from 'lodash'
import Product from '../components/Product'
import Header from '../components/Header'
import Banners from '../components/Banners'
import MainBanner from '../components/MainBanner'
import Brands from '../components/Brands'
import ProductRecomendation from '../components/ProductRecomendation'
import ErrorPage from '../components/errorPage'
import Products from './Products'

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: 'rgba(0, 0, 0, 0.05)',
  },
  text: {
    fontSize: 14,
    color: 'rgba(0,0,0,.7)',
    fontWeight: 'bold',
  },
})

class TopPick extends PureComponent {
  constructor(props) {
    super(props)
    this.state = { refreshing: false, isFetchingProduct: false }
  }

  componentDidMount() {
    this.props.getTopPicks(this.props.pageId)
  }

  fetchproducts = () => {
    const urls = find(this.props.components, ['name', 'product_cards']).data
    this.props.getProducts(urls)
  }

  handleRefresh = () => {
    this.props.resetState()
    this.props.getTopPicks(this.props.pageId)
  }

  handleTryAgain = () => {
    this.props.resetState()
    this.props.getTopPicks(this.props.pageId)
  }

  renderProduct = ({ item, index }) => <Product product={item} index={index} />

  render() {
    if (this.props.isError) {
      return <ErrorPage onTryAgain={this.handleTryAgain} />
    }
    if (this.props.isFetching) {
      return (
        <View style={[styles.container, { justifyContent: 'center' }]}>
          <ActivityIndicator size="small" animating={this.props.isFetching} />
        </View>
      )
    }
    console.log('asu jink');
    console.log(this.props);

    return (
      <Navigator.Config
        title={this.props.title}>
        <ScrollView
          refreshControl={
            <RefreshControl
              refreshing={this.state.refreshing}
              onRefresh={this.handleRefresh}
              colors={['#42b549']}
            />
          }
          style={styles.container}
        >
          {this.props.components.map(c => {
            switch (c.name) {
              case 'category_navigation': {
                return null
              }
              case 'title_image': {
                return <Header title={c.data} key={c.id} />
              }
              case 'banner_image_quadruple': {
                return <Banners data={c.data} key={c.id} />
              }
              case 'brand_recommendation': {
                return <Brands data={c.data} key={c.id} />
              }
              case 'product_recommendation': {
                return <ProductRecomendation data={c.data} key={c.id} />
              }
              case 'banner_image': {
                return <MainBanner data={c.data} key={c.id} />
              }
              case 'product_cards': {
                return (
                  <View key={c.id}>
                    <View
                      style={{
                        marginTop: 12,
                        paddingVertical: 12,
                        paddingLeft: 10,
                        backgroundColor: 'white',
                        borderTopWidth: 1,
                        borderColor: '#e0e0e0',
                      }}
                    >
                      <Text style={styles.text}>Produk Pilihan</Text>
                    </View>
                    <Products urls={c.data} />
                  </View>
                )
              }
              default:
                return null
            }
          })}
        </ScrollView>
      </Navigator.Config>
    )
  }
}

export default TopPick
