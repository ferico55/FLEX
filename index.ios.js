/**
 * @flow
 */

import React from 'react';
import {
  AppRegistry,
  StyleSheet,
  Text,
  View,
} from 'react-native';

import HybridContainer from './src/HybridContainer';

const NotFoundComponent = () => (
  <View style={styles.container}>
    <Text style={styles.welcome}>
      Screen not found!
    </Text>
  </View>
);

const container = HybridContainer({
  Hotlist: require('./src/Hotlist'),
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
