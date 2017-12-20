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
import RideHailing from './src/Uber'

import SearchFilterScreen from './src/search/'
import OrderHistoryPage from './src/Order/Page/HistoryPage'
import OrderDetailPage from './src/Order/Page/OrderDetailPage'
import FeedKOLActivityScreen from './src/Feed/KOL'

// TopChat Pages
import TopChat from './src/TopChat'

import Promo from './src/Promo'
import PromoDetail from './src/PromoDetail'
import CategoryResultPage from './src/category-result/CategoryResultPage'
import { createEpicMiddleware } from 'redux-observable'

import ThankYou from './src/thankyou-page'

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

registerScreens([TopAds, InboxReview, ThankYou, TopChat, RideHailing])
