import React from 'react'
import { View, Dimensions } from 'react-native'
import glamorous from 'glamorous-native'
import { ReactTPRoutes, TKPReactAnalytics } from 'NativeModules'
import ActionButton from '../common/TKPButton'

const { width } = Dimensions.get('window')

const Expiredpromo = () => {
  const EmptyView = glamorous.view({
    alignItems: 'center',
    paddingVertical: 30,
  })

  const HeaderText = glamorous.text({
    fontSize: 16,
    fontWeight: 'bold',
    textAlign: 'center',
    color: '#4a4a4a',
  })

  const SubHeaderText = glamorous.text({
    fontSize: 13,
    textAlign: 'center',
    color: '#606060',
  })

  const EmptyBagImage = glamorous.image({
    width: width > 414 ? 250 : 200,
    height: width > 414 ? 250 : 200,
    resizeMode: 'contain',
  })

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
      <EmptyView>
        <EmptyBagImage source={emptyBagImage} />
        <HeaderText>Promo telah berakhir</HeaderText>
        <SubHeaderText style={{ paddingTop: 15 }}>
          Temukan promo menarik lainnya di Official Store
        </SubHeaderText>
        <View style={{ paddingTop: 30 }}>
          <ActionButton type="big" content="Cek Sekarang" onTap={onActionTap} />
        </View>
      </EmptyView>
    </View>
  )
}

export default Expiredpromo
