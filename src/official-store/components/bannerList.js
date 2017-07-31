import React, { Component } from 'react'
import PropTypes from 'prop-types'
import {
  ViewPagerAndroid,
  Platform,
  View,
  Dimensions,
  Image,
  StyleSheet,
  TouchableWithoutFeedback,
  Text,
  Linking,
} from 'react-native'
import DeviceInfo from 'react-native-device-info';

import Swiper from 'react-native-swiper'
import PlaceholderImg from './img/grey-bg.png'

const { height, width } = Dimensions.get('window')

const BannerList = ({ banners, onBannerPress, onViewAllPress }) => {
  const topBanners = banners.filter(banner => banner.html_id === 0)
  if (topBanners.length == 0) {
    return null
  }

  return (
    <View>
      <Swiper autoplay={true} showsPagination={false} height={185} autoplayTimeout={5}>
        {
          topBanners.map((banner, index) => (
            <View key={banner.banner_id}>
              <TouchableWithoutFeedback onPress={(e) => onBannerPress(e, banner)}>
                <Image 
                        style={styles.pageStyle}
                        source={{ uri : banner.image_url }}
                        defaultSource = {{ uri : 'grey-bg' }}
                        resizeMode='contain'
                        />
              </TouchableWithoutFeedback>
            </View>
          ))
        }
      </Swiper>
      {/* <ViewPagerAndroid
        initialPage={0}
        style={styles.viewPager}>
        {
          banners.map((banner, index) => (
            <View key={banner.banner_id}>
              <TouchableWithoutFeedback onPress={(e) => onBannerPress(e, banner)}>
                <Image source={{ uri: banner.image_url }} style={styles.pageStyle}></Image>
              </TouchableWithoutFeedback>
            </View> 
          ))
        }
      </ViewPagerAndroid>  */}
      <Text
        style={styles.viewAll}
        onPress={onViewAllPress}> Lihat Semua Promo  >
    </Text>
    </View>
  )
}

var styles = StyleSheet.create({
  container: {
    marginVertical: 10
  },
  pageStyle: {
    alignItems: 'center',
    padding: 20,
    width: width,
    height: 173,
  },
  viewPager: {
    height: 185,
  },
  viewAll: {
    color: '#42b549',
    fontSize: 12,
    fontWeight: '600',
    textAlign: 'right',
    padding: 10
  },
  slide: {
    flexGrow: 1,
    justifyContent: 'center',
    alignItems: 'center',
  }
})

BannerList.propTypes = {
  banners: PropTypes.array,
  onBannerPress: PropTypes.func,
  onViewAllPress: PropTypes.func,
}

export default BannerList