import React from 'react'
import {
  View,
  Text,
  Image,
  ScrollView,
  StyleSheet,
  TouchableWithoutFeedback,
} from 'react-native'
import { ReactTPRoutes } from 'NativeModules'
import LoadMore from './LoadMore'
import FavouriteBtn from '../common/Favourite/favBtn'
import WishlistBtn from '../common/Wishlist/WishlistButton'

const BrandList = props => {
  const validBrands = props.brands.filter(
    brand =>
      brand && brand.microsite_url && brand.products.length && brand.logo_url,
  )

  return (
    <View>
      {validBrands.map(b => (
        <View key={b.id} style={styles.brandContainer}>
          <View style={styles.shopHeadContainer}>
            <View style={styles.shopImageWrapper}>
              <TouchableWithoutFeedback
                onPress={() => ReactTPRoutes.navigate(b.shop_apps_url)}
              >
                <Image style={styles.shopImage} source={{ uri: b.logo_url }} />
              </TouchableWithoutFeedback>
            </View>
            <TouchableWithoutFeedback
              onPress={() => ReactTPRoutes.navigate(b.shop_apps_url)}
            >
              <View style={{ flexGrow: 1, flexShrink: 1 }}>
                <Text
                  style={styles.shopName}
                  ellipsizeMode="tail"
                  numberOfLines={0}
                >
                  {b.name}
                </Text>
              </View>
            </TouchableWithoutFeedback>
            <View style={{ flexGrow: 1, flexShrink: 1 }}>
              <FavouriteBtn shopId={b.id} isFav={b.isFav} />
            </View>
          </View>
          <View style={styles.productsWrapper}>
            <ScrollView
              horizontal
              automaticallyAdjustContentInsets={false}
              showsHorizontalScrollIndicator={false}
            >
              {b.products.map(p => (
                <View style={styles.thumb} key={p.id}>
                  <TouchableWithoutFeedback
                    onPress={() => ReactTPRoutes.navigate(p.url_app)}
                  >
                    <View>
                      <Image
                        style={styles.productImage}
                        source={{ uri: p.image_url }}
                      />
                      <Text
                        style={styles.productName}
                        ellipsizeMode="tail"
                        numberOfLines={2}
                      >
                        {p.name}
                      </Text>
                    </View>
                  </TouchableWithoutFeedback>
                  <View style={styles.originalPriceContainer}>
                    {p.discount_percentage && (
                      <Text style={styles.originalPriceText}>
                        {p.original_price}
                      </Text>
                    )}
                  </View>
                  <View style={styles.productAttributeContainer}>
                    <Text style={styles.price}>{p.price}</Text>
                    {p.discount_percentage && (
                      <View style={styles.productGridCampaignRate}>
                        <Text
                          style={styles.productGridCampaignRateText}
                        >{`${p.discount_percentage}% OFF`}</Text>
                      </View>
                    )}
                    {p.badges.map(
                      (badge, i) =>
                        badge.title === 'Free Return' ? (
                          <View key={i}>
                            <Image
                              source={{ uri: badge.image_url }}
                              style={styles.badgeImage}
                            />
                          </View>
                        ) : null,
                    )}
                  </View>
                  <View style={styles.label}>
                    {p.labels.map((l, index) => {
                      let labelTitle = l.title
                      if (l.title.indexOf('Cashback') > -1) {
                        labelTitle = 'Cashback'
                      }
                      switch (labelTitle) {
                        case 'PO':
                        case 'Grosir':
                          return (
                            <View style={styles.productLabel} key={index}>
                              <Text style={styles.labelText}>{l.title}</Text>
                            </View>
                          )
                        case 'Cashback':
                          return null
                        default:
                          return null
                      }
                    })}
                  </View>
                  <WishlistBtn isWishlist={p.is_wishlist} productId={p.id} />
                </View>
              ))}
            </ScrollView>
          </View>
        </View>
      ))}
      {props.canFetch && (
        <LoadMore
          onLoadMore={props.loadMore}
          offset={props.offset}
          limit={props.limit}
          canFetch={props.canFetch}
          isFetching={props.isFetching}
        />
      )}
    </View>
  )
}

const styles = StyleSheet.create({
  brandContainer: {
    backgroundColor: '#fff',
    borderTopWidth: 1,
    marginBottom: 10,
    borderColor: '#e0e0e0',
    flexGrow: 1,
  },
  thumb: {
    padding: 7,
    borderRightWidth: 1,
    borderColor: '#e0e0e0',
  },
  productImage: {
    height: 135,
    width: 135,
  },
  shopHeadContainer: {
    borderBottomWidth: 1,
    borderColor: '#e0e0e0',
    flexGrow: 1,
    flexDirection: 'row',
    padding: 10,
    alignItems: 'flex-start',
  },
  shopImageWrapper: {
    borderWidth: 1,
    borderRadius: 3,
    borderColor: '#e0e0e0',
  },
  shopImage: {
    width: 50,
    height: 50,
    borderRadius: 3,
  },
  shopName: {
    marginTop: 5, // '5 5 8 10'
    marginRight: 5,
    marginBottom: 8,
    marginLeft: 10,
    fontWeight: '600',
    fontSize: 14,
    color: 'rgba(0,0,0,.7)',
  },
  productsWrapper: {
    borderBottomWidth: 1,
    borderColor: '#e0e0e0',
    backgroundColor: '#fff',
  },
  price: {
    color: '#ff5722',
    fontSize: 13,
    lineHeight: 18,
  },
  productAttributeContainer: {
    flexGrow: 1,
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'space-between',
  },
  productName: {
    width: 135,
    paddingTop: 4,
    paddingBottom: 4,
  },
  label: {
    flex: 1,
    flexDirection: 'row',
    marginTop: 5,
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
  badgeImage: {
    height: 16,
    width: 16,
    alignSelf: 'flex-end',
  },
  originalPriceText: {
    fontSize: 10,
    fontWeight: '600',
    textDecorationLine: 'line-through',
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

export default BrandList
