// @flow
import React, { Component } from 'react'
import {
  View,
  Text,
  StyleSheet,
  TextInput,
  ActivityIndicator,
  TouchableOpacity,
  ScrollView,
} from 'react-native'
import { connect } from 'react-redux'
import Navigator from 'native-navigation'
import SafeAreaView from 'react-native-safe-area-view'

import { getAvailablePromos } from '../Services/api'
import { trackEvent } from '../Lib/RideHelper'

const styles = StyleSheet.create({
  container: {
    flex: 1,
    paddingHorizontal: 10,
    paddingTop: 10,
  },
  separator: {
    height: 1,
    backgroundColor: '#dbdbdb',
    marginTop: 10,
  },
})

export class RidePromoCodeScreen extends Component {
  state = {
    promos: [],
    text: this.props.promoCodeApplied,
    screenName: 'Ride Promo Code Screen',
  }

  componentDidMount() {
    this.loadAvailablePromos()
  }

  componentWillReceiveProps(newProps) {
    this.setState({ text: newProps.promoCodeApplied })
    if (
      this.state.isApplyingPromo &&
      newProps.fareOverviewLoadStatus !== 'loading'
    ) {
      this.setState({ isApplyingPromo: false })
    }
  }

  componentWillUnmount() {
    trackEvent('GenericUberEvent', 'click back', this.state.screenName)
  }

  loadAvailablePromos = () => {
    this.setState({ isLoading: true })

    getAvailablePromos()
      .then(promos => {
        this.setState({ isLoading: false, promos })
      })
      .catch(() => this.setState({ isLoading: false }))
  }

  applyPromoCode = promoCode => {
    // TODO didmount warning
    this.setState({ isApplyingPromo: true })
    this.props.applyPromoCode(promoCode)
  }

  removePromoCode = () => {
    this.props.removePromoCode()
  }

  render() {
    const { error } = this.props
    const { promos, text, isApplyingPromo, isLoading, screenName } = this.state
    const buttonDisabled =
      !text || isApplyingPromo || text === this.props.promoCodeApplied

    return (
      <SafeAreaView
        style={styles.container}
        forceInset={{ top: 'never', bottom: 'always' }}
      >
        {text && text.toUpperCase() === this.props.promoCodeApplied ? (
          <Navigator.Config
            title="Apply Promo Code"
            rightTitle={'Remove'}
            onRightPress={() => {
              trackEvent(
                'GenericUberEvent',
                'delete promotion',
                `${screenName} - ${this.props.promoCodeApplied}`,
              )
              this.removePromoCode()
            }}
          />
        ) : (
          <Navigator.Config
            title="Apply Promo Code"
            rightTitle={''}
            onRightPress={() => {}}
          />
        )}

        <View style={{ flexDirection: 'row' }}>
          <TextInput
            style={{
              paddingLeft: 10,
              fontSize: 14,
              borderWidth: 1,
              borderRadius: 3,
              borderColor: '#42b549',
              flex: 1,
            }}
            selectionColor="#42b549"
            onChangeText={text => this.setState({ text })}
            value={text}
            placeholder="Enter Promo Code"
          />

          <View
            style={{
              marginLeft: 10,
              backgroundColor: buttonDisabled ? '#e0e0e0' : '#42b549',
              width: 80,
              borderRadius: 3,
            }}
          >
            <TouchableOpacity
              onPress={() => {
                this.applyPromoCode(text)
                trackEvent(
                  'GenericUberEvent',
                  'click apply promo search',
                  `${screenName} - ${text}`,
                )
              }}
              disabled={buttonDisabled}
              style={{
                height: 40,
                justifyContent: 'center',
              }}
            >
              {isApplyingPromo ? (
                <ActivityIndicator />
              ) : (
                <Text
                  style={{
                    color: 'white',
                    backgroundColor: 'transparent',
                    textAlign: 'center',
                  }}
                >
                  Apply
                </Text>
              )}
            </TouchableOpacity>
          </View>
        </View>

        {error && (
          <Text style={{ color: 'red', marginTop: 5, fontSize: 12 }}>
            {error.description}
          </Text>
        )}

        <View style={styles.separator} />

        <Text style={{ marginTop: 15, marginBottom: 5 }}>
          Choose from offers below
        </Text>

        <ScrollView keyboardDismissMode="on-drag">
          {isLoading ? <ActivityIndicator /> : null}

          {!isLoading &&
          promos &&
          Array.isArray(promos) &&
          promos.length <= 0 && (
            <View>
              <Text style={{ color: 'rgba(0, 0, 0, 0.54)' }}>
                No promo available.
              </Text>
            </View>
          )}

          {promos.map(promo => (
            <View key={promo.code}>
              <TouchableOpacity
                onPress={() => {
                  this.setState({ text: promo.code })
                  this.applyPromoCode(promo.code)
                  trackEvent(
                    'GenericUberEvent',
                    'click apply offers',
                    `${screenName} - ${promo.code.toUpperCase()}`,
                  )
                }}
                disabled={isApplyingPromo}
              >
                <View style={{ flexDirection: 'row', paddingTop: 20 }}>
                  <View
                    style={{
                      backgroundColor: '#616161',
                      width: 30,
                      height: 30,
                      marginRight: 20,
                    }}
                  />
                  <View>
                    <Text>{promo.offer}</Text>
                    <Text style={{ marginVertical: 5 }}>
                      <Text style={{ color: 'gray' }}>Promo Code:</Text>{' '}
                      <Text style={{ color: '#42b549' }}>
                        {promo.code.toUpperCase()}
                      </Text>
                    </Text>
                    <TouchableOpacity
                      onPress={() => {
                        Navigator.push('RideWebViewScreen', {
                          url: promo.url,
                        })
                        trackEvent(
                          'GenericUberEvent',
                          'click read offer details',
                          `${screenName} - ${promo.code.toUpperCase()}`,
                        )
                      }}
                      style={{ marginTop: 10 }}
                      hitSlop={{ top: 10, bottom: 10 }}
                    >
                      <Text style={{ color: '#42b549', fontSize: 12 }}>
                        Read offer details
                      </Text>
                    </TouchableOpacity>
                  </View>
                </View>
              </TouchableOpacity>
              <View style={styles.separator} />
            </View>
          ))}
        </ScrollView>
      </SafeAreaView>
    )
  }
}

const mapStateToProps = state => ({
  promoCodeApplied: state.promoCodeApplied,
  error: state.fareOverviewLoadStatus.error,
})

const mapDispatchToProps = dispatch => ({
  onPromoCodeApplied: fareOverview =>
    dispatch({ type: 'RIDE_SET_FARE_OVERVIEW', fareOverview }),
  applyPromoCode: promoCode =>
    dispatch({ type: 'RIDE_CHECK_PROMO_CODE', promoCode }),
  removePromoCode: () => dispatch({ type: 'RIDE_REMOVE_PROMO_CODE' }),
})

export default connect(mapStateToProps, mapDispatchToProps)(RidePromoCodeScreen)
