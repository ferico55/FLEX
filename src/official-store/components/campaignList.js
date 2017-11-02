import React from 'react'
import PropTypes from 'prop-types'
import {
  Text,
  View,
  StyleSheet,
  FlatList,
  Image,
  TouchableWithoutFeedback,
} from 'react-native'
import { ReactTPRoutes } from 'NativeModules'
import ProductList from './ProductList'

const renderCampaign = c => {
  const products = c.item.Products || []
  return (
    <View
      style={{
        marginBottom: 10,
        backgroundColor: '#fff',
        borderTopWidth: 1,
        borderColor: '#e0e0e0',
      }}
    >
      {c.item.html_id === 6 ? null : (
        <Text style={styles.titleText}>{c.item.title}</Text>
      )}
      {
        <TouchableWithoutFeedback
          onPress={() => ReactTPRoutes.navigate(c.item.redirect_url_app)}
        >
          <Image
            style={{ height: 110 }}
            resizeMode="contain"
            source={{
              uri: c.item.html_id == '6' ? c.item.image_url : c.item.mobile_url,
            }}
            defaultSource={{ uri: 'grey-bg' }}
          />
        </TouchableWithoutFeedback>
      }
      <ProductList products={products} />
      {c.item.html_id === 6 ? null : (
        <View style={styles.viewAll}>
          <Text
            style={styles.viewAllText}
            onPress={() => ReactTPRoutes.navigate(c.item.redirect_url_mobile)}
          >
            Lihat Semua >{' '}
          </Text>
          {/* <Icon name='chevron-right' size={30} /> */}
        </View>
      )}
    </View>
  )
}

const CampaignList = ({ campaigns }) => (
  <View style={styles.container}>
    <FlatList
      data={campaigns}
      keyExtractor={item => item.banner_id}
      renderItem={renderCampaign}
      ListFooterComponent={this._footerComponent}
    />
  </View>
)

CampaignList.propTypes = {
  campaigns: PropTypes.array,
}

const styles = StyleSheet.create({
  container: {},
  titleText: {
    fontSize: 16,
    fontWeight: '600',
    margin: 10,
  },
  productRow: {
    flexGrow: 1,
    flexDirection: 'row',
    borderBottomWidth: 1,
    borderColor: '#e0e0e0',
  },
  productCell: {
    flex: 1 / 2,
    borderRightWidth: 1,
    borderColor: '#e0e0e0',
  },
  priceWrapper: {
    flexGrow: 1,
    flexDirection: 'row',
    alignItems: 'center',
    height: 34,
  },
  price: {
    color: '#ff5722',
    fontSize: 13,
    fontWeight: '600',
    lineHeight: 20,
    paddingHorizontal: 10,
  },
  productName: {
    fontSize: 13,
    fontWeight: '600',
    color: 'rgba(0,0,0,.7)',
    height: 33.8,
    paddingHorizontal: 10,
  },
  productImageWrapper: {
    borderBottomWidth: 1,
    borderColor: 'rgba(255,255,255,0)',
    padding: 10,
  },
  productImage: {
    height: 185,
    borderRadius: 3,
  },
  productBadgeWrapper: {
    height: 27,
    paddingVertical: 5,
    paddingHorizontal: 10,
    flexGrow: 1,
    flexDirection: 'row',
    alignItems: 'center',
  },
  productCashback: {
    borderRadius: 3,
    marginRight: 3,
    padding: 3,
    backgroundColor: '#42b549',
  },
  cashbackText: {
    color: '#fff',
    fontSize: 10,
  },
  shopSection: {
    flexGrow: 1,
    flexDirection: 'row',
    padding: 10,
    borderTopWidth: 1,
    borderColor: '#e0e0e0',
    justifyContent: 'center',
  },
  shopImage: {
    width: 28,
    height: 28,
  },
  shopImageWrapper: {
    width: 30,
    height: 30,
    borderRadius: 3,
    borderWidth: 1,
    borderColor: '#e0e0e0',
  },
  shopNameWrapper: {
    flex: 3 / 4,
    marginTop: 7,
    marginLeft: 10,
    marginBottom: 5,
    marginRight: 0,
  },
  viewAll: {
    paddingVertical: 15,
    paddingHorizontal: 10,
    borderBottomWidth: 1,
    borderColor: '#e0e0e0',
    flexGrow: 1,
    flexDirection: 'row',
    justifyContent: 'flex-end',
  },
  viewAllText: {
    color: '#42b549',
    fontSize: 13,
  },
  productLabel: {
    padding: 3,
    borderColor: '#e0e0e0',
    borderWidth: 1,
    marginRight: 3,
    backgroundColor: '#fff',
    borderRadius: 3,
  },
  labelText: {
    fontSize: 10,
  },
  productGridPrice: {
    height: 34,
  },
  productGridNormalPrice: {
    paddingHorizontal: 10,
  },
  productGridNormalPriceText: {
    fontSize: 10,
    fontWeight: '600',
    textDecorationLine: 'line-through',
  },
  badgeImageContainer: {
    paddingHorizontal: 10,
    left: 15,
  },
  badgeImage: {
    height: 16,
    width: 16,
  },
  productGridCampaignRate: {
    backgroundColor: '#ff5722',
    padding: 3,
    borderRadius: 3,
    marginLeft: 5,
  },
  productGridCampaignRateText: {
    color: '#fff',
    fontSize: 11,
    textAlign: 'center',
  },
})

export default CampaignList
