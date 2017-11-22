import React from 'react'
import { View, Dimensions, StyleSheet, Image, Text } from 'react-native'
import { ReactTPRoutes, TKPReactAnalytics } from 'NativeModules'
import ActionButton from '../common/TKPButton'

const { width } = Dimensions.get('window')

const styles = StyleSheet.create({
  emptyView: {
    alignItems: 'center',
    paddingVertical: 30,
  },
  headerText: {
    fontSize: 16,
    fontWeight: 'bold',
    textAlign: 'center',
    color: '#4a4a4a',
  },
  subHeaderText: {
    fontSize: 13,
    textAlign: 'center',
    color: '#606060',
    paddingTop: 15,
  },
  emptyBagImage: {
    width: width > 414 ? 250 : 200,
    height: width > 414 ? 250 : 200,
    resizeMode: 'contain',
  },
})

const Expiredpromo = () => {
  const onActionTap = () => {
    TKPReactAnalytics.trackEvent({
      name: 'clickOSMicrosite',
      category: 'main page - promo ended',
      action: 'click check now',
      label: `tokopedia://official-store/mobile`,
    })
    ReactTPRoutes.navigate(`tokopedia://official-store/mobile`)
  }

  const emptyBagImage =
    width > 414
      ? require('../../img/end-promo2x.png')
      : require('../../img/end-promo.png')

  return (
    <View>
      <View style={styles.emptyView}>
        <Image source={emptyBagImage} style={styles.emptyBagImage} />
        <Text style={styles.headerText}>Promo telah berakhir</Text>
        <Text style={styles.subHeaderText}>
          Temukan promo menarik lainnya di Official Store
        </Text>
        <View style={{ paddingTop: 30 }}>
          <ActionButton type="big" content="Cek Sekarang" onTap={onActionTap} />
        </View>
      </View>
    </View>
  )
}

export default Expiredpromo
