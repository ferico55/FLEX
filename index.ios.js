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
import HybridContainer from './src/HybridContainer'
import moment from 'moment'

// top ads pages
import TopAdsDashboard from './src/TopAds/Page/TopAdsDashboard'
import AddCreditPage from './src/TopAds/Page/AddCreditPage'
import DateSettingsPage from './src/TopAds/Page/DateSettingsPage'
import PromoListPage from './src/TopAds/Page/PromoListPage'
import PromoDetailPage from './src/TopAds/Page/PromoDetailPage'
import FilterPage from './src/TopAds/Page/FilterPage'
import FilterDetailPage from './src/TopAds/Page/FilterDetailPage'
import StatDetailPage from './src/TopAds/Page/StatDetailPage'
import SearchFilterScreen from './src/search/'
import AddPromoPage from './src/TopAds/Page/AddPromoPage'
import AddPromoPageStep1 from './src/TopAds/Page/AddPromoPageStep1'
import ChooseProductPage from './src/TopAds/Page/ChooseProductPage'
import AddPromoPageStep2 from './src/TopAds/Page/AddPromoPageStep2'
import AddPromoPageStep3 from './src/TopAds/Page/AddPromoPageStep3'
import EditPromoPage from './src/TopAds/Page/EditPromoPage'
import EditPromoGroupNamePage from './src/TopAds/Page/EditPromoGroupNamePage'
import FeedKOLActivityScreen from './src/Feed/KOL'
import TopChatMain from '@containers/main/MainContainers'
import TopChatDetail from '@containers/detail/DetailContainers'
import TopChatStore from './src/TopChat/Store'
import SendChatView from '@SendChatContainers/SendChatView'
import ProductAttachTopChat from '@containers/product/ProductContainers'

// Inbox review pages
import InboxReview from './src/InboxReview/Page/InboxReview'
import ReviewFilterPage from './src/InboxReview/Page/ReviewFilterPage'
import InvoiceDetailPage from './src/InboxReview/Page/InvoiceDetailPage'
import ProductReviewFormPage from './src/InboxReview/Page/ProductReviewFormPage'
import ImageUploadPage from './src/InboxReview/Page/ImageUploadPage'
import ReportReviewPage from './src/InboxReview/Page/ReportReviewPage'
import ImageDetailPage from './src/InboxReview/Page/ImageDetailPage'
import ProductReviewPage from './src/InboxReview/Page/ProductReviewPage'
import ShopReviewPage from './src/InboxReview/Page/ShopReviewPage'

import topAdsDashboardReducer from './src/TopAds/Redux/Reducers/GeneralReducer'
import inboxReviewReducer from './src/InboxReview/Redux/Reducer'

import Promo from './src/Promo'
import PromoDetail from './src/PromoDetail'
import CategoryResultPage from './src/category-result/CategoryResultPage'
import { createEpicMiddleware } from 'redux-observable'

import RideHailingScreen, { getVehicles } from './src/Uber/Containers/RideHailingScreen'
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

const middleware = applyMiddleware(thunk)
const topAdsDashboardStore = createStore(topAdsDashboardReducer, middleware)
const inboxReviewStore = createStore(inboxReviewReducer, middleware)
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

// Inbox Review screen
Navigator.registerScreen('InboxReview', () => props => (
  <Provider store={inboxReviewStore}>
    <InboxReview {...props} />
  </Provider>
))
Navigator.registerScreen('ReviewFilterPage', () => props => (
  <Provider store={inboxReviewStore}>
    <ReviewFilterPage {...props} />
  </Provider>
))
Navigator.registerScreen('InvoiceDetailPage', () => props => (
  <Provider store={inboxReviewStore}>
    <InvoiceDetailPage {...props} />
  </Provider>
))
Navigator.registerScreen('ProductReviewFormPage', () => props => (
  <Provider store={inboxReviewStore}>
    <ProductReviewFormPage {...props} />
  </Provider>
))
Navigator.registerScreen('ImageUploadPage', () => props => (
  <Provider store={inboxReviewStore}>
    <ImageUploadPage {...props} />
  </Provider>
))
Navigator.registerScreen('ReportReviewPage', () => props => (
  <Provider store={inboxReviewStore}>
    <ReportReviewPage {...props} />
  </Provider>
))
Navigator.registerScreen('ImageDetailPage', () => props => (
  <Provider store={inboxReviewStore}>
    <ImageDetailPage {...props} />
  </Provider>
))

Navigator.registerScreen('ProductReviewPage', () => props => (
  <Provider store={inboxReviewStore}>
    <ProductReviewPage {...props} />
  </Provider>
))
Navigator.registerScreen('ShopReviewPage', () => props => (
  <Provider store={inboxReviewStore}>
    <ShopReviewPage {...props} />
  </Provider>
))

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

Navigator.registerScreen('SearchFilterScreen',() => props =>(
<SearchFilterScreen {...props}/>
))

const container = HybridContainer({
  Hotlist: require('./src/Hotlist'),
  CategoryResultPage,
  Promo,
  PromoDetail,
  ProductReview: require('./src/Review/ProductReview'),
  'Official Store': require('./src/official-store/setup'),
  'Official Store Promo': require('./src/os-promo/setup'),
  NotFoundComponent,
})

AppRegistry.registerComponent('Tokopedia', () => container)
