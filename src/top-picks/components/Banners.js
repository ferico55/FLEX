import React from 'react'
import { StyleSheet, Image, View } from 'react-native'
import { ReactTPRoutes, TKPReactAnalytics } from 'NativeModules'
import TKPTouchable from '../common/TKPTouchable'

const styles = StyleSheet.create({
  banner: {
    height: 170,
    resizeMode: 'contain',
    marginBottom: 15,
  },
})

const Banners = ({ data }) => (
  <View>{data.map((b, i) => <Banner banner={b} key={i} />)}</View>
)

const Banner = ({ banner }) => (
  <TKPTouchable
    onPress={() => {
      ReactTPRoutes.navigate(banner.applink)
    }}
  >
    <View>
      <Image
        source={{ uri: banner.image_url_mobile }}
        style={styles.banner}
        cache="default"
      />
    </View>
  </TKPTouchable>
)

export default Banners
