import React, { Component } from 'react'
import { View, NativeModules, StyleSheet, WebView } from 'react-native'
import Navigator from 'native-navigation'
import qs from 'qs'
import parse from 'url-parse'

const styles = StyleSheet.create({
  container: {
    flex: 1,
    justifyContent: 'center',
  },
})

class RideTopupTokocashScreen extends Component {
  handleContinuation = event => {
    const url = event.url

    // can't seem to handle it in onLoadStart because onLoadStart
    // can't prevent page from being opened automatically,
    // and if onShouldStartLoadWithRequest returns false, onLoadStart won't be called
    if (url.includes('/digital/cart')) {
      const queryString = url.split('?')[1]

      const { category_id, product_id, operator_id } = qs.parse(queryString)

      NativeModules.NotificationCenter.post('RideTokocashTopup', {
        category_id,
        product_id,
        operator_id,
      })

      return false
    }
    return true
  }

  render() {
    const url = this.props.uri
    const urlParsed = parse(url)
    const { pathname } = urlParsed
    return (
      <View style={styles.container}>
        {pathname === '/uber/pendingcash' ? (
          <Navigator.Config title="Pending Payment" />
        ) : (
          <Navigator.Config title="Insufficient Tokocash" />
        )}
        <WebView
          onShouldStartLoadWithRequest={this.handleContinuation}
          onLoadStart={this.handleLoadStart}
          style={{ flex: 1 }}
          source={{
            uri: this.props.uri,
          }}
        />
      </View>
    )
  }
}

export default RideTopupTokocashScreen
