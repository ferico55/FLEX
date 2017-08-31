/**
 * @flow
 */

import React from 'react';
import {
  AppRegistry,
  StyleSheet,
  Text,
  View,
} from 'react-native'
import Navigator from 'native-navigation'
import HybridContainer from './src/HybridContainer'
import TopAdsDashboard from './src/TopAds/Page/TopAdsDashboard'
import AddPromoCredit from './src/TopAds/Page/AddPromoCredit'
import DateSettingsPage from './src/TopAds/Page/DateSettingsPage'
import PromoListPage from './src/TopAds/Page/PromoListPage'
import PromoDetailPage from './src/TopAds/Page/PromoDetailPage'
import FilterPage from './src/TopAds/Page/FilterPage'
import FilterGrupPage from './src/TopAds/Page/FilterGrupPage'
import StatDetailPage from './src/TopAds/Page/StatDetailPage'

import topAdsDashboardReducer from './src/TopAds/Redux/Reducer'
import { applyMiddleware ,createStore } from 'redux'
import { Provider } from 'react-redux'
import thunk from 'redux-thunk'
import logger from 'redux-logger'

const middleware = applyMiddleware(thunk)
const topAdsDashboardStore = createStore(topAdsDashboardReducer, middleware);

const NotFoundComponent = () => (
  <View style={styles.container}>
    <Text style={styles.welcome}>
      Screen not found!
    </Text>
  </View>
);

// Navigator.registerScreen('PromoListPage', () => PromoListPage)
Navigator.registerScreen('StatDetailPage', () => (props) => (
  <Provider store={topAdsDashboardStore}>
    <StatDetailPage {...props} />
  </Provider>
));

Navigator.registerScreen('FilterPage', () => (props) => (
  <Provider store={topAdsDashboardStore}>
    <FilterPage {...props} />
  </Provider>
));

Navigator.registerScreen('FilterGrupPage', () => (props) => (
  <Provider store={topAdsDashboardStore}>
    <FilterGrupPage {...props} />
  </Provider>
));

Navigator.registerScreen('PromoListPage', () => (props) => (
  <Provider store={topAdsDashboardStore}>
    <PromoListPage {...props} />
  </Provider>
));

Navigator.registerScreen('PromoDetailPage', () => (props) => (
  <Provider store={topAdsDashboardStore}>
    <PromoDetailPage {...props} />
  </Provider>
));

Navigator.registerScreen('DateSettingsPage', () => (props) => (
  <Provider store={topAdsDashboardStore}>
    <DateSettingsPage {...props} />
  </Provider>
));

Navigator.registerScreen('TopAdsDashboard', () => (props) => (
  <Provider store={topAdsDashboardStore}>
    <TopAdsDashboard {...props} />
  </Provider>
));

Navigator.registerScreen('AddPromoCredit', () => (props) => (
  <Provider store={topAdsDashboardStore}>
    <AddPromoCredit {...props} />
  </Provider>
));

const container = HybridContainer({
  Hotlist: require('./src/Hotlist'),
  Promo: require('./src/Promo'),
  PromoDetail: require('./src/PromoDetail'),
  'Official Store': require('./src/official-store/setup'),
  NotFoundComponent,
});


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
});

AppRegistry.registerComponent('Tokopedia', () => container);
