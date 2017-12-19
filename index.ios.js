/**
 * @flow
 */

import React from 'react'
import CodePush from 'react-native-code-push'
import { AppRegistry, StyleSheet, Text, View } from 'react-native'
import Navigator from 'native-navigation'
import { applyMiddleware, createStore } from 'redux'
import { Provider } from 'react-redux'
import thunk from 'redux-thunk'
import moment from 'moment'
import HybridContainer from './src/HybridContainer'

// top ads pages
import TopAds from './src/TopAds'
// inbox review pages
import InboxReview from './src/InboxReview'

import SearchFilterScreen from './src/search/'
import OrderHistoryPage from './src/Order/Page/HistoryPage'
import OrderDetailPage from './src/Order/Page/OrderDetailPage'
import FeedKOLActivityScreen from './src/Feed/KOL'
import TopChatMain from '@containers/main/MainContainers'
import TopChatDetail from '@containers/detail/DetailContainers'
import TopChatStore from './src/TopChat/Store'
import SendChatView from '@SendChatContainers/SendChatView'
import ProductAttachTopChat from '@containers/product/ProductContainers'

import Promo from './src/Promo'
import PromoDetail from './src/PromoDetail'
import CategoryResultPage from './src/category-result/CategoryResultPage'
import { createEpicMiddleware } from 'redux-observable'

import RideHailingScreen, {
  getVehicles,
} from './src/Uber/Containers/RideHailingScreen'
import RidePlacesAutocompleteScreen from './src/Uber/Containers/RidePlacesAutocompleteScreen'
import RideWebViewScreen from './src/Uber/Containers/RideWebViewScreen'
import RideReceiptScreen from './src/Uber/Containers/RideReceiptScreen'
import RideHistoryScreen from './src/Uber/Containers/RideHistoryScreen'
import RideHistoryDetailScreen from './src/Uber/Containers/RideHistoryDetailScreen'
import RideCancellationScreen from './src/Uber/Containers/RideCancellationScreen'
import RidePromoCodeScreen from './src/Uber/Containers/RidePromoCodeScreen'
import rideReducer from './src/Uber/Reducers/RideReducer'
import RideTopupTokocashScreen from './src/Uber/Components/RideTopupTokocashScreen'
import { epic } from './src/Uber/Actions/RideActions'

let composer
if (__DEV__) {
  const { composeWithDevTools } = require('remote-redux-devtools')
  composer = composeWithDevTools({
    name: 'Ridehailing',
    port: 8000,
    sendTo: 'http://localhost:8000',
  })
} else {
  composer = id => id
}

const rideStore = createStore(
  rideReducer,
  composer(applyMiddleware(thunk, createEpicMiddleware(epic))),
)
rideStore.dispatch({ type: 'FOO' })

const styles = StyleSheet.create({
  container: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
  },
  welcome: {
    fontSize: 20,
    textAlign: 'center',
    margin: 10,
  },
})

try {
  CodePush.sync()
} catch (error) {
  CodePush.log(error)
}

const NotFoundComponent = () => (
  <View style={styles.container}>
    <Text style={styles.welcome}>Screen not found!</Text>
  </View>
)

Navigator.registerScreen('RideHailing', () => props => (
  <Provider store={rideStore}>
    <RideHailingScreen {...props} />
  </Provider>
))

Navigator.registerScreen('RidePlacesAutocompleteScreen', () => () => (
  <Provider store={rideStore}>
    <RidePlacesAutocompleteScreen />
  </Provider>
))

Navigator.registerScreen('RideWebViewScreen', () => props => (
  <Provider store={rideStore}>
    <RideWebViewScreen {...props} />
  </Provider>
))

Navigator.registerScreen('RideReceiptScreen', () => props => (
  <Provider store={rideStore}>
    <RideReceiptScreen {...props} />
  </Provider>
))

Navigator.registerScreen('RideHistoryScreen', () => props => (
  <Provider store={rideStore}>
    <RideHistoryScreen {...props} />
  </Provider>
))

Navigator.registerScreen('RideHistoryDetailScreen', () => props => (
  <Provider store={rideStore}>
    <RideHistoryDetailScreen {...props} />
  </Provider>
))

Navigator.registerScreen('RideCancellationScreen', () => props => (
  <Provider store={rideStore}>
    <RideCancellationScreen {...props} />
  </Provider>
))

Navigator.registerScreen('RidePromoCodeScreen', () => props => (
  <Provider store={rideStore}>
    <RidePromoCodeScreen {...props} />
  </Provider>
))

Navigator.registerScreen('RideTopupTokocashScreen', () => props => (
  <Provider store={rideStore}>
    <RideTopupTokocashScreen {...props} />
  </Provider>
))

moment.relativeTimeThreshold('ss', 1)
moment.relativeTimeThreshold('s', 60)
moment.relativeTimeThreshold('m', 60)
moment.relativeTimeThreshold('h', 24)
moment.relativeTimeThreshold('d', 30)
moment.relativeTimeThreshold('M', 12)


// Order Management Screen
Navigator.registerScreen('HistoryPage', () => OrderHistoryPage)
Navigator.registerScreen('OrderDetailPage', () => OrderDetailPage)

Navigator.registerScreen('FeedKOLActivityComment', () => FeedKOLActivityScreen)

/* TOPCHAT */
Navigator.registerScreen('TopChatMain', () => props => (
  <Provider store={TopChatStore}>
    <TopChatMain {...props} />
  </Provider>
))

Navigator.registerScreen('TopChatDetail', () => props => (
  <Provider store={TopChatStore}>
    <TopChatDetail {...props} />
  </Provider>
))

Navigator.registerScreen('SendChat', () => props => <SendChatView {...props} />)

Navigator.registerScreen('ProductAttachTopChat', () => props => (
  <Provider store={TopChatStore}>
    <ProductAttachTopChat {...props} />
  </Provider>
))
/* TOPCHAT */

Navigator.registerScreen('SearchFilterScreen', () => props => (
  <SearchFilterScreen {...props} />
))

const container = HybridContainer({
  Hotlist: require('./src/Hotlist'),
  CategoryResultPage,
  Promo,
  PromoDetail,
  'Official Store': require('./src/official-store/setup'),
  'Official Store Promo': require('./src/os-promo/setup'),
  NotFoundComponent,
})

AppRegistry.registerComponent('Tokopedia', () => container)

const registerScreens = screenGroups =>
  screenGroups.forEach(group =>
    Object.keys(group).forEach(screenName =>
      Navigator.registerScreen(screenName, () => group[screenName]),
    ),
  )

registerScreens([TopAds, InboxReview])
