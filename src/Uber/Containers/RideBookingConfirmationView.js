// @flow

import React from 'react'
import {
  View,
  Text,
  StyleSheet,
  TouchableOpacity,
  ActivityIndicator,
  Image,
} from 'react-native'
import { connect } from 'react-redux'
import Navigator from 'native-navigation'

import { trackEvent, currencyFormat, rupiahFormat } from '../Lib/RideHelper'

import IconUberThumbsUp from '../Resources/icon-uber-thumbs-up.png'
import IconUberTag from '../Resources/icon-uber-tag.png'
import IconUberPeople from '../Resources/icon-uber-people.png'

const styles = StyleSheet.create({
  shadow: {
    shadowColor: 'black',
    shadowRadius: 1,
    shadowOpacity: 0.3,
    shadowOffset: { width: 0, height: 0 },
  },
  confirmation: {
    backgroundColor: 'white',
    margin: 8,
    borderRadius: 3,
    borderWidth: 1,
    borderColor: 'white',
  },
  verticalSeparator: {
    backgroundColor: '#e6e6e6',
    height: 1,
  },
})

class RideBookingConfirmationView extends React.Component {
  constructor(props) {
    super(props)
    this.state = {}
  }

  renderSelectedProduct = () => {
    const {
      fareOverviewLoadStatus,
      selectedProduct,
      requestStatus,
      cancelSelectedProduct,
      bookRide,
      mode,
      screenName,
    } = this.props
    const fareOverview =
      fareOverviewLoadStatus && fareOverviewLoadStatus.fareOverview

    if (
      fareOverviewLoadStatus.status !== 'error' &&
      requestStatus.status !== 'error'
    ) {
      return (
        <View style={[styles.shadow, styles.confirmation]}>
          <View>
            <View
              style={{
                flexDirection: 'row',
                alignItems: 'center',
                paddingVertical: 8,
              }}
            >
              <View
                style={{
                  borderColor: '#c6c6c6',
                  borderWidth: 1,
                  borderRadius: 15,
                  width: 30,
                  height: 30,
                  padding: 5,
                  marginHorizontal: 8,
                }}
              >
                {selectedProduct &&
                selectedProduct.image && (
                  <Image
                    source={{ uri: selectedProduct.image }}
                    resizeMode="contain"
                    style={{ flex: 1, alignSelf: 'stretch' }}
                  />
                )}
              </View>
              <Text style={{ fontSize: 12 }}>
                {selectedProduct.display_name}
                {fareOverview ? (
                  ` - pickup in ${fareOverview.pickup_estimate} min`
                ) : (
                  ''
                )}
              </Text>
            </View>

            <View style={styles.verticalSeparator} />

            <View style={{ flexDirection: 'row' }}>
              <View style={{ flex: 1, justifyContent: 'center' }}>
                {fareOverview ? (
                  <Text style={{ textAlign: 'center', paddingVertical: 8 }}>
                    {`${currencyFormat(
                      fareOverview.fare.currency_code,
                    )} ${rupiahFormat(fareOverview.fare.value)}`}
                  </Text>
                ) : (
                  <ActivityIndicator />
                )}
              </View>
              <View style={{ width: 1, backgroundColor: '#e6e6e6' }} />
              <View
                style={{
                  flexDirection: 'row',
                  flex: 1,
                  justifyContent: 'center',
                  alignItems: 'center',
                }}
              >
                <Image
                  source={IconUberPeople}
                  style={{ height: 15, width: 15 }}
                />
                <Text
                  style={{
                    textAlign: 'center',
                    padding: 8,
                  }}
                >
                  {selectedProduct.capacity}
                </Text>
              </View>
            </View>

            <View style={styles.verticalSeparator} />

            <View
              style={{
                flexDirection: 'row',
                alignItems: 'center',
                justifyContent: 'center',
                paddingVertical: 8,
              }}
            >
              <Image
                source={{ uri: 'icon_wallet' }}
                style={{ width: 25, aspectRatio: 1, marginRight: 7 }}
              />
              <Text>Tokocash</Text>
            </View>

            <View style={styles.verticalSeparator} />

            <View
              style={{
                flexDirection: 'row',
              }}
            >
              <View
                style={{
                  backgroundColor: '#FFFFFF',
                  borderRadius: 2,
                  margin: 5,
                  borderWidth: 1,
                  borderColor: '#DCDCDC',
                  flex: 3,
                }}
              >
                <TouchableOpacity
                  onPress={() => cancelSelectedProduct()}
                  style={{ paddingVertical: 10 }}
                  disabled={!fareOverview}
                >
                  <Text
                    style={{
                      color: '#B4B4B4',
                      textAlign: 'center',
                      fontWeight: '500',
                    }}
                  >
                    Back
                  </Text>
                </TouchableOpacity>
              </View>

              <View
                style={{
                  backgroundColor: fareOverview ? '#ff5722' : '#e0e0e0',
                  borderRadius: 2,
                  margin: 5,
                  flex: 7,
                }}
              >
                <TouchableOpacity
                  onPress={() => {
                    bookRide(selectedProduct.product_id)
                    trackEvent(
                      'GenericUberEvent',
                      `click request ${selectedProduct.display_name}`,
                      `${screenName}`,
                    )
                  }}
                  style={{ paddingVertical: 10 }}
                  disabled={!fareOverview}
                >
                  <Text
                    style={{
                      color: fareOverview ? 'white' : 'rgba(0,0,0,0.26)',
                      textAlign: 'center',
                      fontWeight: '500',
                    }}
                  >
                    Request {selectedProduct.display_name}
                  </Text>
                </TouchableOpacity>
              </View>
            </View>
          </View>
        </View>
      )
    }

    return (
      <View style={[styles.shadow, styles.confirmation]}>
        <View
          style={{
            justifyContent: 'flex-end',
            padding: 8,
          }}
        >
          <Text
            style={{
              color: 'red',
              textAlign: 'center',
              marginBottom: 10,
            }}
          >
            {requestStatus.status === 'error' ? (
              requestStatus.error.description
            ) : (
              fareOverviewLoadStatus.error.description
            )}
          </Text>

          <View style={{ backgroundColor: '#42b549', borderRadius: 3 }}>
            <TouchableOpacity
              style={{ paddingHorizontal: 20, paddingVertical: 10 }}
              onPress={() => {
                if (fareOverviewLoadStatus.status === 'error') {
                  this.props.selectRide(selectedProduct.product_id)
                } else {
                  bookRide(selectedProduct.product_id)
                }
              }}
            >
              <Text
                style={{
                  color: 'white',
                  fontWeight: '500',
                  textAlign: 'center',
                }}
              >
                Retry
              </Text>
            </TouchableOpacity>
          </View>
        </View>
      </View>
    )
  }

  render() {
    const { fareOverviewLoadStatus, promoCodeApplied } = this.props
    const { fareOverview } = fareOverviewLoadStatus
    return (
      <View>
        {fareOverviewLoadStatus.status === 'loaded' ? (
          <View
            style={[
              styles.shadow,
              {
                flexDirection: 'row',
                backgroundColor: 'white',
                alignItems: 'stretch',
                justifyContent: 'center',
                marginHorizontal: 8,
                borderRadius: 3,
                paddingHorizontal: 8,
              },
            ]}
          >
            {promoCodeApplied && fareOverview.code ? (
              <Image
                source={IconUberThumbsUp}
                style={{
                  height: 20,
                  width: 20,
                  marginVertical: 8,
                  flex: 0.5,
                }}
                resizeMode={'contain'}
              />
            ) : (
              <Image
                source={IconUberTag}
                style={{
                  height: 20,
                  width: 20,
                  marginVertical: 8,
                  flex: 0.5,
                }}
                resizeMode={'contain'}
              />
            )}
            <Text style={{ flex: 6, padding: 8 }}>
              {promoCodeApplied && fareOverview.message_success ? (
                fareOverview.message_success
              ) : (
                'Do you have a promocode?'
              )}
            </Text>
            {promoCodeApplied && fareOverview.code ? (
              <TouchableOpacity
                onPress={() => Navigator.push('RidePromoCodeScreen')}
                style={{ justifyContent: 'center', paddingLeft: 20 }}
              >
                <Text
                  style={{
                    color: '#42b549',
                    fontSize: 14,
                    fontWeight: '500',
                  }}
                >
                  EDIT
                </Text>
              </TouchableOpacity>
            ) : (
              <TouchableOpacity
                onPress={() => Navigator.push('RidePromoCodeScreen')}
                style={{ justifyContent: 'center', paddingLeft: 20 }}
              >
                <Text
                  style={{
                    color: '#42b549',
                    fontSize: 14,
                    fontWeight: '500',
                  }}
                >
                  APPLY
                </Text>
              </TouchableOpacity>
            )}
          </View>
        ) : null}

        {this.renderSelectedProduct()}
      </View>
    )
  }
}

const pickupEstimation = state => {
  const { products, timeEstimations, priceEstimations } = state

  return (
    products &&
    timeEstimations &&
    products.map(product => {
      const timeEstimation = timeEstimations.find(
        estimate => estimate.product_id === product.product_id,
      )
      const priceEstimation = priceEstimations.find(
        estimation => estimation.product_id === product.product_id,
      )
      const priceRange =
        priceEstimation &&
        `${currencyFormat(priceEstimation.currency_code)} ${rupiahFormat(
          priceEstimation.low_estimate,
        )} - ${rupiahFormat(priceEstimation.high_estimate)}`

      return {
        product,
        time: timeEstimation ? timeEstimation.time : 15,
        priceRange,
      }
    })
  )
}

const selectedProduct = state => {
  const { selectedProductId, products } = state

  const product = products.filter(
    product => product.product_id === selectedProductId,
  )[0]

  return product
}

const mapStateToProps = state => {
  const source = state.routeSelection.source

  return {
    ...state,
    selectedProduct: selectedProduct(state),
  }
}

const mapDispatchToProps = dispatch => ({
  selectRide: productId => {
    dispatch({
      type: 'RIDE_SELECT_VEHICLE',
      productId,
    })
  },

  bookRide: (productId, additionalParams) => {
    dispatch({
      type: 'RIDE_BOOK_VEHICLE',
      productId,
      tosConfirmation: additionalParams,
    })
  },

  cancelSelectedProduct: () => {
    dispatch({
      type: 'RIDE_CANCEL_SELECTED_PRODUCT',
    })
  },
})

export default connect(mapStateToProps, mapDispatchToProps)(
  RideBookingConfirmationView,
)
