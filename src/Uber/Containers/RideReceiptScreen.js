import React, { Component } from 'react'
import {
  View,
  Text,
  StyleSheet,
  NativeModules,
  ActivityIndicator,
  ScrollView,
  Image,
  TextInput,
  Button,
  Alert,
  Keyboard,
  KeyboardAvoidingView,
  TouchableOpacity,
} from 'react-native'
import Navigator from 'native-navigation'
import HTMLView from 'react-native-htmlview'
import Dash from 'react-native-dash'
import { ReactInteractionHelper } from 'NativeModules'
import SafeAreaView from 'react-native-safe-area-view'

import RatingStars from '../../RatingStars'

import { getReceipt, postReview, payPendingfare } from '../Services/api'
import { rupiahFormat, currencyFormat, trackEvent } from '../Lib/RideHelper'

const {
  ReactNetworkManager,
  TKPReactURLManager,
  HybridNavigationManager,
} = NativeModules

export default class RideReceiptScreen extends Component {
  constructor(props) {
    super(props)
    this.state = {
      isLoading: true,
      rating: 0,
      eligibleToRate: true,
      shouldHighlight: false,
      screenName: 'Ride Completed Screen',
      isLoadingPayPendingFare: false,
    }
  }

  componentWillMount() {
    this.keyboardDidShowSub = Keyboard.addListener(
      'keyboardDidShow',
      this.keyboardDidShow,
    )
    this.keyboardDidHideSub = Keyboard.addListener(
      'keyboardDidHide',
      this.keyboardDidHide,
    )
  }

  componentDidMount() {
    getReceipt(this.props.requestId).subscribe(response => {
      this.setState({
        receipt: response.receipt,
        detail: response.detail,
        isLoading: false,
        comment: '',
        rating: 0,
      })
    })
  }

  componentWillUnmount() {
    trackEvent('GenericUberEvent', 'click back', this.state.screenName)
    this.keyboardDidShowSub.remove()
    this.keyboardDidHideSub.remove()
  }

  keyboardDidShow = event => {
    this.scrollView.scrollToEnd({ animated: true })
  }

  keyboardDidHide = event => {
    this.scrollView.scrollToEnd({ animated: true })
  }

  payPendingfare = () => {
    this.setState({ isLoadingPayPendingFare: true })
    payPendingfare()
      .then(response => {
        if (!response.message_error && response.status === 'OK') {
          Navigator.push('RidePaymentWebViewScreen', {
            data: response.data,
            title: 'Payment',
            url: response.data.url,
          })
          this.setState({ isLoadingPayPendingFare: false })
        }
      })
      .catch(error => {
        ReactInteractionHelper.showErrorStickyAlert(error.description)
        this.setState({ isLoadingPayPendingFare: false })
      })
  }

  _handleRating = rating => {
    this.setState({
      rating,
    })
  }

  _submitRating = () => {
    this.setState({
      eligibleToRate: false,
      isPostingSuggestion: true,
    })
    const { receipt, comment, rating } = this.state

    postReview({
      request_id: receipt.request_id,
      stars: rating,
      comment,
    }).then(response => {
      if (response.status === 'OK') {
        this.setState({
          isPostingSuggestion: false,
        })
        Alert.alert('Your Review has been saved!', '', [
          {
            text: 'OK',
            onPress: () => Navigator.pop(),
          },
        ])
      } else {
        this.setState({
          isPostingSuggestion: false,
        })
        // TODO handle failure
        Alert.alert('Something went wrong!')
      }
    })
  }

  _highligherStyle = () => {
    if (this.state.shouldHighlight) {
      return [
        styles.suggestionBorder,
        {
          marginBottom: 16,
          borderColor: '#3AB539',
        },
      ]
    }

    return [
      styles.suggestionBorder,
      {
        marginBottom: 16,
      },
    ]
  }

  renderNode = (node, index, siblings, parent, defaultRenderer) => {
    if (node.name === 'u') {
      return (
        <Text
          key={index}
          style={{ color: '#3AB539', textDecorationLine: 'underline' }}
        >
          {defaultRenderer(node.children, parent)}
        </Text>
      )
    }
  }

  render() {
    const {
      isLoading,
      receipt,
      detail,
      rating,
      eligibleToRate,
      comment,
      screenName,
      isLoadingPayPendingFare,
    } = this.state

    if (isLoading) {
      return (
        <SafeAreaView
          style={{ padding: 10 }}
          forceInset={{ top: 'never', bottom: 'always' }}
        >
          <ActivityIndicator />
        </SafeAreaView>
      )
    }

    const {
      payment: { total_amount: tokocashCharged },
      total_fare: totalFare,
      currency_code: currencyCode,
      cashback_amount: cashbackAmount,
      payment: { payment_method: paymentMethod },
    } = receipt

    let totalAmount = totalFare.replace(/,/g, '')
    totalAmount = totalAmount.replace('Rp', '')
    totalAmount = totalAmount.replace(currencyCode, '')

    return (
      <SafeAreaView
        style={{ flex: 1 }}
        forceInset={{ top: 'never', bottom: 'always' }}
      >
        <KeyboardAvoidingView behavior="padding" style={{ flex: 1 }}>
          <ScrollView
            ref={ref => {
              this.scrollView = ref
            }}
            style={{ marginBottom: 36 }}
          >
            <Navigator.Config title="Trip Completed" />
            <View style={styles.topViewContainer}>
              <Text
                style={[
                  styles.disabledText,
                  styles.smallText,
                  { alignSelf: 'center' },
                ]}
              >
                YOUR FARE
              </Text>
              <Text style={styles.totalFare}>{`${currencyFormat(
                currencyCode,
              )} ${rupiahFormat(totalAmount)}`}</Text>
              <View style={styles.headerContainer}>
                <View
                  style={{
                    alignItems: 'center',
                    justifyContent: 'center',
                    marginRight: 32,
                  }}
                >
                  <Image
                    style={styles.roundedImage}
                    source={{ uri: detail.driver.picture_url }}
                  />
                  <View style={styles.driverRatingContainer}>
                    <View style={styles.highlightedContainer}>
                      <Image
                        source={{ uri: 'icon_star_active' }}
                        style={styles.smallStar}
                      />
                    </View>
                    <Text
                      style={[
                        styles.smallText,
                        styles.highlightedContainer,
                        { marginLeft: 4 },
                      ]}
                    >
                      {detail.driver.rating}
                    </Text>
                  </View>
                  <Text style={styles.subtitle}>{detail.driver.name}</Text>
                </View>
                <View style={{ alignItems: 'center', justifyContent: 'center' }}>
                  <Image
                    style={styles.roundedImage}
                    source={{ uri: detail.vehicle.picture_url }}
                  />
                  <View style={{ paddingVertical: 2, marginTop: -6 }}>
                    <Text style={[styles.smallText, styles.highlightedContainer]}>
                      {detail.vehicle.license_plate}
                    </Text>
                  </View>
                  <Text style={styles.subtitle}>
                    {detail.vehicle.make}-{detail.vehicle.model}
                  </Text>
                </View>
              </View>
              <View>
                <View style={styles.fareContainer}>
                  <Text style={[styles.smallText, styles.disabledText]}>
                    Total Fare
                  </Text>
                  <Text style={{ fontSize: 12 }}>{`${currencyFormat(
                    currencyCode,
                  )} ${rupiahFormat(totalAmount)}`}</Text>
                </View>
                <View style={[styles.fareContainer, { marginTop: 8 }]}>
                  <Text style={[styles.smallText, styles.disabledText]}>
                    {paymentMethod === 'wallet' ? (
                      'TokoCash Charged'
                    ) : (
                      'Credit Card Charged'
                    )}
                  </Text>
                  <Text style={{ fontSize: 12 }}>
                    {`${currencyFormat(currencyCode)} ${rupiahFormat(
                      tokocashCharged,
                    )}`}
                  </Text>
                </View>
                {cashbackAmount && cashbackAmount > 0 ? (
                  <View style={[styles.fareContainer, { marginTop: 8 }]}>
                    <Text style={[styles.smallText, styles.disabledText]}>
                      Cashback
                    </Text>
                    <Text style={{ fontSize: 12 }}>
                      {`${currencyFormat(currencyCode)} ${rupiahFormat(
                        cashbackAmount,
                      )}`}
                    </Text>
                  </View>
                ) : null}
              </View>
            </View>

            {receipt.pending_payment.balance !== '' && (
              <View>
                <View style={styles.pendingFare}>
                  <Dash
                    style={styles.dash}
                    dashColor="rgba(0,0,0,0.12)"
                    dashThickness={1}
                  />
                  <View style={styles.pendingFareContainer}>
                    <Text style={{ color: 'red' }}>Pending Fare</Text>
                    <Text style={{ color: 'red' }}>
                      Rp {receipt.pending_payment.pending_amount}
                    </Text>
                  </View>
                  <Dash
                    style={styles.dash}
                    dashColor="rgba(0,0,0,0.12)"
                    dashThickness={1}
                  />
                </View>
                <View style={styles.buttonContainer}>
                  <TouchableOpacity
                    style={styles.button}
                    onPress={() => this.payPendingfare()}
                    disabled={isLoadingPayPendingFare}
                  >
                    {isLoadingPayPendingFare ? (
                      <ActivityIndicator size={'small'} />
                    ) : (
                      <Text style={{ color: '#FFFFFF', fontWeight: 'bold' }}>
                        Pay Pending Fare
                      </Text>
                    )}
                  </TouchableOpacity>
                </View>
              </View>
            )}

            {receipt.pending_payment.balance === '' && (
              <View style={styles.reviewContainer}>
                <View style={styles.starContainer}>
                  <Text
                    style={[
                      styles.disabledText,
                      { fontSize: 12, marginBottom: 8 },
                    ]}
                  >
                    RATE YOUR RIDE
                  </Text>
                  <RatingStars
                    rating={rating}
                    enabled={eligibleToRate}
                    onStarPressed={this._handleRating}
                  />
                </View>
                <View>
                  <TextInput
                    ref={input => {
                      this.suggestionInput = input
                    }}
                    placeholder="Write suggestions..."
                    editable={eligibleToRate}
                    style={styles.reviewInput}
                    onFocus={() => {
                      this.setState({
                        shouldHighlight: true,
                      })
                    }}
                    onBlur={() => {
                      this.setState({
                        shouldHighlight: false,
                      })
                    }}
                    onChangeText={text => this.setState({ comment: text })}
                    value={comment}
                    returnKeyType={'done'}
                    blurOnSubmit
                  />
                  <View style={this._highligherStyle()} />
                  {isLoading && (
                    <ActivityIndicator
                      animating={isLoading}
                      style={[styles.centering, { height: 37 }]}
                      size="small"
                    />
                  )}
                  {!isLoading && (
                    <Button
                      title="Submit"
                      color="#3AB539"
                      disabled={rating === 0 || !eligibleToRate}
                      onPress={() => {
                        this._submitRating()
                        trackEvent(
                          'GenericUberEvent',
                          'click submit',
                          `${screenName} - ${rating} - ${comment}`,
                        )
                      }}
                    />
                  )}
                </View>
              </View>
            )}
          </ScrollView>

          <View style={styles.footerView}>
            <Text
              style={styles.smallText}
              onPress={() => {
                Navigator.push('RideWebViewScreen', {
                  url: receipt.ride_offer.url,
                })
                trackEvent(
                  'GenericUberEvent',
                  'click sign up uber',
                  `${screenName}`,
                )
              }}
            >
              <HTMLView
                value={receipt.ride_offer.html}
                renderNode={this.renderNode}
                RootComponent={Text}
              />
              <Text
                onPress={() => {
                  Navigator.push('RideWebViewScreen', {
                    url: receipt.ride_offer.terms,
                  })
                  trackEvent('GenericUberEvent', 'click tnc', `${screenName}`)
                }}
                style={[styles.smallText, { color: '#3AB539' }]}
              >
                {' '}
                (T&C)
              </Text>
            </Text>
          </View>
        </KeyboardAvoidingView>
      </SafeAreaView>
    )
  }
}

const styles = StyleSheet.create({
  topViewContainer: {
    padding: 16,
  },
  disabledText: {
    color: 'rgba(0,0,0,0.7)',
  },
  totalFare: {
    fontSize: 22,
    fontWeight: '400',
    alignSelf: 'center',
    marginTop: 12,
  },
  roundedImage: {
    height: 40,
    width: 40,
    borderRadius: 20,
  },
  smallStar: {
    height: 10,
    width: 10,
  },
  smallText: {
    fontSize: 10,
  },
  thinSeparator: {
    borderBottomWidth: 1,
    borderColor: 'rgba(0,0,0,0.12)',
  },
  subtitle: {
    fontSize: 12,
    marginTop: 2,
  },
  driverRatingContainer: {
    flexDirection: 'row',
    alignItems: 'center',
    marginLeft: -4,
    paddingVertical: 2,
    marginTop: -6,
    alignItems: 'stretch',
  },
  headerContainer: {
    flexDirection: 'row',
    justifyContent: 'center',
    marginTop: 16,
  },
  fareContainer: {
    marginTop: 24,
    paddingHorizontal: 16,
    flex: 1,
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'space-between',
  },
  reviewContainer: {
    marginTop: 8,
  },
  starContainer: {
    padding: 16,
    backgroundColor: '#FAFAFA',
    alignItems: 'center',
  },
  reviewInput: {
    margin: 32,
    marginTop: 24,
    marginBottom: 0,
  },
  suggestionBorder: {
    borderBottomWidth: 1,
    borderColor: 'rgba(0,0,0,0.12)',
    height: 1,
    marginLeft: 32,
    marginRight: 32,
    flex: 1,
  },
  footerView: {
    borderTopWidth: 1,
    borderColor: 'rgba(0,0,0,0.12)',
    alignItems: 'center',
    position: 'absolute',
    bottom: 0,
    width: '100%',
    zIndex: 10,
    paddingVertical: 8,
    backgroundColor: 'white',
  },
  highlightedContainer: {
    backgroundColor: '#F2F2F2',
    padding: 2,
  },
  dash: {
    flex: 1,
  },
  pendingFareContainer: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    marginHorizontal: 32,
    marginVertical: 16,
  },
  tokoCashDropdown: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    marginTop: 6,
    paddingBottom: 4,
    marginBottom: 24,
  },
  buttonContainer: {
    flex: 1,
    marginHorizontal: 50,
    marginTop: 50,
  },
  button: {
    justifyContent: 'center',
    alignItems: 'center',
    backgroundColor: '#ff5722',
    borderRadius: 3,
    height: 50,
  },
})
