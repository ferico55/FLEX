/* @flow */

import React, { Component } from 'react'
import { View, ActivityIndicator, StyleSheet } from 'react-native'

export default class Loading extends Component {
  render() {
    return (
      <View
        style={[
          styles.container,
          { alignItems: 'center', justifyContent: 'center' },
        ]}
      >
        <ActivityIndicator size={'small'} animating />
      </View>
    )
  }
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
  },
})
