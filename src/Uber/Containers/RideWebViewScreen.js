// @flow
import React, { Component } from 'react'
import { View, StyleSheet, WebView, NativeModules } from 'react-native'
import { connect } from 'react-redux'
import rlite from 'rlite-router'
import Navigator from 'native-navigation'
import parse from 'url-parse'
import SafeAreaView from 'react-native-safe-area-view'

const { TKPReactURLManager } = NativeModules

export class RideWebViewScreen extends Component {
  constructor(props) {
    super(props)
    this.state = {
      webViewHistoryCount: 0,
      isLoaded: false,
    }
  }

  handleBackButton = () => {
    const { webViewHistoryCount } = this.state
    if (webViewHistoryCount > 0) {
      this._webview.goBack()
      this.setState({ webViewHistoryCount: webViewHistoryCount - 1 })
    } else {
      Navigator.pop()
    }
  }

  render() {
    const { onLoadStart, url } = this.props
    const { webViewHistoryCount, isLoaded } = this.state
    const isButtonDisable = webViewHistoryCount > 0 || false

    if (!url) {
      return null
    }

    const urlParsed = parse(url)
    const { pathname } = urlParsed
    if (pathname === '/uber/help') {
      const leftButton = {
        title: 'Back',
        // image: { uri: 'icon-back', width: 20, height: 20 },
        // image: { uri: 'navigation-chevron', scale: 1.8 },
      }
      return (
        <SafeAreaView
          style={styles.container}
          forceInset={{ top: 'never', bottom: 'always' }}
        >
          <Navigator.Config
            title="Help"
            leftButtons={[leftButton]}
            onLeftPress={() => this.handleBackButton()}
          >
            <View style={styles.container}>
              <WebView
                ref={component => (this._webview = component)}
                onLoadStart={onLoadStart}
                style={styles.container}
                source={{ uri: url }}
                startInLoadingState
                onNavigationStateChange={() => {
                  if (isLoaded) {
                    this.setState({
                      webViewHistoryCount: webViewHistoryCount + 1,
                    })
                  }
                }}
                onLoadEnd={() => {
                  this.setState({ isLoaded: true })
                }}
              />
            </View>
          </Navigator.Config>
        </SafeAreaView>
      )
    }

    return (
      <SafeAreaView
        style={styles.container}
        forceInset={{ top: 'never', bottom: 'always' }}
      >
        <WebView
          onLoadStart={onLoadStart}
          style={styles.container}
          source={{ uri: url }}
        />
      </SafeAreaView>
    )
  }
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
  },
})

import { acceptedTermsOfService } from './RideHailingScreen'

const mapStateToProps = state => state
const mapDispatchToProps = (dispatch, ownProps) => ({
  onLoadStart: event => {
    // console.log("webview event", event.nativeEvent.url);
    const url = parse(event.nativeEvent.url)
    const router = rlite(() => {}, {
      'toko://redirect-url': params => {
        event.preventDefault()
        // console.log("hit!", params);
        dispatch(
          acceptedTermsOfService({
            [ownProps.expectedCode]: params[ownProps.expectedCode],
          }),
        )
        Navigator.pop()
      },
    })

    if (url.pathname === '/thanks_wallet') {
      Navigator.pop()
      dispatch({
        type: 'RIDE_BOOK_VEHICLE',
        productId: ownProps.productId,
      })
    }
  },
})

export default connect(mapStateToProps, mapDispatchToProps)(RideWebViewScreen)
