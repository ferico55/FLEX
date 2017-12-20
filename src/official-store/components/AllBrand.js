import React from 'react'
import { ReactTPRoutes } from 'NativeModules'
import { Image, TouchableWithoutFeedback } from 'react-native'

const AllBrands = () => (
  <TouchableWithoutFeedback
    onPress={() =>
      ReactTPRoutes.navigate('https://m.tokopedia.com/official-store/brand')}
  >
    <Image
      source={require('./img/banner-all-brand.jpg')}
      style={{ width: '100%', height: 105, resizeMode: 'contain' }}
    />
  </TouchableWithoutFeedback>
)

export default AllBrands
