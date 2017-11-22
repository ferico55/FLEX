/**
 * @flow
 */

import React from 'react'
import CodePush from 'react-native-code-push'
import { AppRegistry, StyleSheet, Text, View } from 'react-native'
import Navigator from 'native-navigation'
import HybridContainer from './src/HybridContainer'
import TopAdsDashboard from './src/TopAds/Page/TopAdsDashboard'
import AddCreditPage from './src/TopAds/Page/AddCreditPage'
import DateSettingsPage from './src/TopAds/Page/DateSettingsPage'
import PromoListPage from './src/TopAds/Page/PromoListPage'
import PromoDetailPage from './src/TopAds/Page/PromoDetailPage'
import FilterPage from './src/TopAds/Page/FilterPage'
import FilterDetailPage from './src/TopAds/Page/FilterDetailPage'
import StatDetailPage from './src/TopAds/Page/StatDetailPage'
import AddPromoPage from './src/TopAds/Page/AddPromoPage'
import AddPromoPageStep1 from './src/TopAds/Page/AddPromoPageStep1'
import ChooseProductPage from './src/TopAds/Page/ChooseProductPage'
import AddPromoPageStep2 from './src/TopAds/Page/AddPromoPageStep2'
import AddPromoPageStep3 from './src/TopAds/Page/AddPromoPageStep3'
import EditPromoPage from './src/TopAds/Page/EditPromoPage'
import EditPromoGroupNamePage from './src/TopAds/Page/EditPromoGroupNamePage'
import FeedKOLActivityScreen from './src/Feed/KOL'

import topAdsDashboardReducer from './src/TopAds/Redux/Reducers/GeneralReducer'
import { applyMiddleware, createStore } from 'redux'
import { Provider } from 'react-redux'
import thunk from 'redux-thunk'
import logger from 'redux-logger'
import moment from 'moment'

import Promo from './src/Promo'
import PromoDetail from './src/PromoDetail'
import CategoryResultPage from './src/category-result/CategoryResultPage'


const middleware = applyMiddleware(thunk)
const topAdsDashboardStore = createStore(topAdsDashboardReducer, middleware)

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

moment.relativeTimeThreshold('ss', 1)
moment.relativeTimeThreshold('s', 60)
moment.relativeTimeThreshold('m', 60)
moment.relativeTimeThreshold('h', 24)
moment.relativeTimeThreshold('d', 30)
moment.relativeTimeThreshold('M', 12)

// Navigator.registerScreen('PromoListPage', () => PromoListPage)

Navigator.registerScreen('AddPromoPage', () => props => (
  <Provider store={topAdsDashboardStore}>
    <AddPromoPage {...props} />
  </Provider>
))

Navigator.registerScreen('AddPromoPageStep1', () => props => (
  <Provider store={topAdsDashboardStore}>
    <AddPromoPageStep1 {...props} />
  </Provider>
))

Navigator.registerScreen('ChooseProductPage', () => props => (
  <Provider store={topAdsDashboardStore}>
    <ChooseProductPage {...props} />
  </Provider>
))

Navigator.registerScreen('AddPromoPageStep2', () => props => (
  <Provider store={topAdsDashboardStore}>
    <AddPromoPageStep2 {...props} />
  </Provider>
))

Navigator.registerScreen('AddPromoPageStep3', () => props => (
  <Provider store={topAdsDashboardStore}>
    <AddPromoPageStep3 {...props} />
  </Provider>
))

Navigator.registerScreen('EditPromoPage', () => props => (
  <Provider store={topAdsDashboardStore}>
    <EditPromoPage {...props} />
  </Provider>
))

Navigator.registerScreen('EditPromoGroupNamePage', () => props => (
  <Provider store={topAdsDashboardStore}>
    <EditPromoGroupNamePage {...props} />
  </Provider>
))

Navigator.registerScreen('StatDetailPage', () => props => (
  <Provider store={topAdsDashboardStore}>
    <StatDetailPage {...props} />
  </Provider>
))

Navigator.registerScreen('FilterPage', () => props => (
  <Provider store={topAdsDashboardStore}>
    <FilterPage {...props} />
  </Provider>
))

Navigator.registerScreen('FilterDetailPage', () => props => (
  <Provider store={topAdsDashboardStore}>
    <FilterDetailPage {...props} />
  </Provider>
))

Navigator.registerScreen('PromoListPage', () => props => (
  <Provider store={topAdsDashboardStore}>
    <PromoListPage {...props} />
  </Provider>
))

Navigator.registerScreen('PromoDetailPage', () => props => (
  <Provider store={topAdsDashboardStore}>
    <PromoDetailPage {...props} />
  </Provider>
))

Navigator.registerScreen('DateSettingsPage', () => props => (
  <Provider store={topAdsDashboardStore}>
    <DateSettingsPage {...props} />
  </Provider>
))

Navigator.registerScreen('TopAdsDashboard', () => props => (
  <Provider store={topAdsDashboardStore}>
    <TopAdsDashboard {...props} />
  </Provider>
))

Navigator.registerScreen('AddCreditPage', () => props => (
  <Provider store={topAdsDashboardStore}>
    <AddCreditPage {...props} />
  </Provider>
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

AppRegistry.registerComponent('Tokopedia', () => container)

import { createEpicMiddleware } from 'redux-observable'

import RideHailingScreen, { getVehicles } from './src/RideHailingScreen'
import RidePlacesAutocompleteScreen from './src/RidePlacesAutocompleteScreen'
import RideWebViewScreen from './src/RideWebViewScreen'
import RideReceiptScreen from './src/RideReceiptScreen'
import RideHistoryScreen from './src/RideHistoryScreen'
import RideHistoryDetailScreen from './src/RideHistoryDetailScreen'
import RideCancellationScreen from './src/RideCancellationScreen'
import RidePromoCodeScreen from './src/RidePromoCodeScreen'
import rideReducer from './src/redux/RideReducer'
import RideTopupTokocashScreen from './src/RideTopupTokocashScreen'
import { epic } from './src/redux/RideActions'

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

Navigator.registerScreen('FeedKOLActivityComment', () => FeedKOLActivityScreen)
