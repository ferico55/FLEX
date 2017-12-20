// @flow
import React, { Component } from 'react'
import { StyleSheet, WebView, NativeModules, Text } from 'react-native'
import Navigator from 'native-navigation'
import { connect } from 'react-redux'
import { ReactInteractionHelper } from 'NativeModules'
import SafeAreaView from 'react-native-safe-area-view'

import { serialize } from '../Lib/RideHelper'

import NoResult from '../../unify/NoResult'

const styles = StyleSheet.create({
  container: {
    flex: 1,
  },
})

export class RidePaymentWebViewScreen extends Component {
  constructor(props) {
    super(props)
    this.state = {
      error: null,
    }
  }

  shouldStart = webViewState => {
    const { data } = this.props

    // need handle this webViewState.url === data.callback_url ?
    if (webViewState.url === 'tokopedia://action_add_cc_fail') {
      Navigator.pop()
      return false
    } else if (webViewState.url === 'tokopedia://action_add_cc_success') {
      this.props.getPaymentMethod()
      Navigator.pop()
      return false
    } else if (
      webViewState.url === `tokopedia://orderId/${data.transaction_id}`
    ) {
      ReactInteractionHelper.showStickyAlert('Payment is successful.')
      NativeModules.NotificationCenter.post('RideFinishPayment', null)
      return false
    } else if (
      webViewState.url === `https://www.tokopedia.com/` ||
      webViewState.url === `https://m.tokopedia.com/`
    ) {
      Navigator.pop()
      return false
    }
    return true
  }

  renderError = () => {
    const { error } = this.state
    return (
      <NoResult
        buttonTitle="Try again"
        title="Oops!"
        subtitle={error.description}
        style={{ marginTop: 100 }}
        onButtonPress={() => this.webview.reload()}
      />
    )
  }

  render() {
    const { url, data, title } = this.props
    return (
      <SafeAreaView
        forceInset={{ top: 'never', bottom: 'always' }}
        style={styles.container}
      >
        <Navigator.Config title={title}>
          <WebView
            ref={component => (this.webview = component)}
            style={styles.container}
            startInLoadingState
            source={{
              uri: url,
              method: 'POST',
              headers: {
                'content-type': 'application/x-www-form-urlencoded',
              },
              body: serialize(data),
            }}
            onShouldStartLoadWithRequest={webViewState =>
              this.shouldStart(webViewState)}
            onError={event => {
              this.setState({
                error: { description: event.nativeEvent.description },
              })
            }}
            renderError={() => this.renderError()}
          />
        </Navigator.Config>
      </SafeAreaView>
    )
  }
}

const mapDispatchToProps = dispatch => ({
  getPaymentMethod: () => dispatch({ type: 'RIDE_GET_PAYMENT_METHOD' }),
})

export default connect(null, mapDispatchToProps)(RidePaymentWebViewScreen)
