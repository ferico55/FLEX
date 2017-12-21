import React from 'react'
import { StyleSheet, Image, View } from 'react-native'
import { ReactTPRoutes, TKPReactAnalytics } from 'NativeModules'
import TKPTouchable from '../common/TKPTouchable'

const styles = StyleSheet.create({
  mainBanner: {
    height: 240,
    resizeMode: 'contain',
  },
})

const MainBanner = ({ data }) => {
  return (
    <View style={{ marginBottom: 15 }}>
      {data.map((mb, i) => (
        <TKPTouchable
          key={i}
          onPress={() => {
            ReactTPRoutes.navigate(mb.applinks)
          }}
        >
          <Image
            source={{ uri: mb.image_url_mobile }}
            style={styles.mainBanner}
            cache="default"
          />
        </TKPTouchable>
      ))}
    </View>
  )
}

export default MainBanner
