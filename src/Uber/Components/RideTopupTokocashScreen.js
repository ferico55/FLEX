import React, { Component } from 'react'
import { View, NativeModules, StyleSheet, WebView } from 'react-native'
import Navigator from 'native-navigation'
import qs from 'qs'
import parse from 'url-parse'

import { trackScreenName } from '../Lib/RideHelper'

const styles = StyleSheet.create({
  container: {
    flex: 1,
    justifyContent: 'center',
  },
})

class RideTopupTokocashScreen extends Component {
  componentWillMount() {
    const url = this.props.uri
    const urlParsed = parse(url)
    const { pathname } = urlParsed
    if (pathname === '/v1/uber/pendingcash') {
      trackScreenName('Ride Pending Payment Screen')
    } else if (pathname === '/v1/uber/pending/pay') {
      trackScreenName('Ride Pending Payment Screen')
    } else if (pathname === '/uber/topupcash') {
      trackScreenName('Ride Insufficient Tokocash Screen')
    }
  }

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

  navigatorConfig = () => {
    const url = this.props.uri
    const urlParsed = parse(url)
    const { pathname } = urlParsed
    if (pathname === '/v1/uber/pendingcash') {
      return { title: 'Pending Payment' }
    } else if (pathname === '/v1/uber/pending/pay') {
      return { title: 'Pending Payment' }
    } else if (pathname === '/uber/topupcash') {
      return { title: 'Insufficient Tokocash' }
    }

    return { title: '' }
  }

  render() {
    return (
      <View style={styles.container}>
        <Navigator.Config {...this.navigatorConfig()} />
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
