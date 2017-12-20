import React from 'react'
import PropTypes from 'prop-types'
import {
  View,
  Dimensions,
  Image,
  StyleSheet,
  TouchableWithoutFeedback,
  Text,
} from 'react-native'

import Swiper from 'react-native-swiper'

const { width } = Dimensions.get('window')

const BannerList = ({ banners, onBannerPress, onViewAllPress }) => {
  const topBanners = banners.filter(banner => banner.html_id === 0)
  if (topBanners.length == 0) {
    return null
  }

  return (
    <View
      height={215}
      backgroundColor={'rgba(0, 0, 0, 0.05)'}
      paddingBottom={10}
    >
      <Swiper
        autoplay={true}
        showsPagination={true}
        autoplayTimeout={5}
        height={205}
        style={styles.bannerSwipe}
        paginationStyle={styles.bannerPagination}
        activeDotColor={'#FF5722'}
      >
        {topBanners.map(banner => (
          <View key={banner.banner_id}>
            <TouchableWithoutFeedback onPress={e => onBannerPress(e, banner)}>
              <Image
                style={styles.pageStyle}
                source={{ uri: banner.image_url }}
                defaultSource={{ uri: 'grey-bg' }}
                resizeMode="cover"
              />
            </TouchableWithoutFeedback>
          </View>
        ))}
      </Swiper>
      <Text style={styles.viewAll} onPress={onViewAllPress}> Lihat Semua Promo</Text>
    </View>
  )
}

let styles = StyleSheet.create({
  bannerBox: {
    width,
    height: 180,
  },
  pageStyle: {
    alignItems: 'center',
    width,
    height: 180,
    resizeMode: 'contain',
  },
  viewAll: {
    position: 'absolute',
    bottom: 0,
    right: 0,
    color: '#42b549',
    fontSize: 12,
    fontWeight: '600',
    textAlign: 'right',
    padding: 10,
  },
  slide: {
    flexGrow: 1,
    justifyContent: 'center',
    alignItems: 'center',
  },
  bannerPagination: {
    justifyContent: 'flex-start',
    position: 'absolute',
    width: 210,
    left: 10,
    bottom: 0,
  }
})

BannerList.propTypes = {
  banners: PropTypes.array,
  onBannerPress: PropTypes.func,
  onViewAllPress: PropTypes.func,
}

export default BannerList
