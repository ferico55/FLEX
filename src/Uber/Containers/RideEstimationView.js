// @flow

import React from 'react'
import {
  View,
  Text,
  StyleSheet,
  TouchableOpacity,
  ActivityIndicator,
  Dimensions,
  Image,
} from 'react-native'
import Interactable from 'react-native-interactable'
import { connect } from 'react-redux'

import { trackEvent, currencyFormat, rupiahFormat } from '../Lib/RideHelper'

import UberIcon from '../Resources/icon-uber.png'

const screenHeight = () => {
  const X_HEIGHT = 812
  const X_WIDTH = 375
  return Dimensions.get('screen').height === X_HEIGHT &&
  Dimensions.get('screen').width === X_WIDTH
    ? Dimensions.get('screen').height - 64 - 59
    : Dimensions.get('screen').height - 64
}
const styles = StyleSheet.create({
  overlay: {
    position: 'absolute',
    top: 0,
    left: 0,
    right: 0,
    bottom: 0,
  },
  shadow: {
    shadowColor: 'black',
    shadowRadius: 1,
    shadowOpacity: 0.3,
    shadowOffset: { width: 0, height: 0 },
  },
})

class RideEstimationView extends React.Component {
  constructor(props) {
    super(props)
  }

  componentDidUpdate(previousProps) {
    const {
      loadPickupEstimationStatus: previousPickupEstimationStatus,
    } = previousProps

    const { loadPickupEstimationStatus, snapIndex } = this.props

    if (
      this.interactableView &&
      previousPickupEstimationStatus.status === 'loaded' &&
      previousPickupEstimationStatus.status !==
        loadPickupEstimationStatus.status
    ) {
      this.interactableView.snapTo({ index: snapIndex })
    }
  }

  _onRowSelected = productId => {
    if (!this.props.routeSelection.destination) {
      this.props.shakeDestination()
    } else {
      this.props.selectRide(productId)
    }
  }

  renderEstimatesContent = () => {
    const {
      estimates,
      routeSelection: { destination },
      screenName,
      snapIndex,
    } = this.props

    return (
      estimates &&
      estimates.map((estimate, index) => {
        const {
          cost_per_distance: costPerDistance,
          currency_code: currency,
          distance_unit: distanceUnit,
        } =
          estimate.product.price_details || {}

        const formattedCostPerDistance = costPerDistance
          ? `${currency} ${costPerDistance}/${distanceUnit}`
          : '--'

        return (
          <View key={estimate.product.product_id}>
            {index ? (
              <View
                style={{
                  backgroundColor: '#c6c6c6',
                  height: 1,
                  marginLeft: 46,
                }}
              />
            ) : null}
            <TouchableOpacity
              onPress={() => {
                this._onRowSelected(estimate.product.product_id)
                if (destination) {
                  trackEvent(
                    'GenericUberEvent',
                    'select ride option',
                    `${screenName} - ${estimate.product
                      .display_name} - ${estimate.time} - ${estimate.priceRange}`,
                  )
                }
              }}
              style={{
                flexDirection: 'row',
                paddingVertical: 8,
                alignItems: 'center',
              }}
            >
              <View
                style={{
                  flex: 1,
                  flexDirection: 'row',
                  alignItems: 'center',
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
                  <Image
                    source={{ uri: estimate.product.image }}
                    resizeMode="contain"
                    style={{ flex: 1, alignSelf: 'stretch' }}
                    defaultSource={UberIcon}
                  />
                </View>
                <Text style={{ fontSize: 12 }}>
                  {estimate.product.display_name}
                </Text>
              </View>

              <View
                style={{
                  flex: 1,
                  alignItems: 'center',
                }}
              >
                <Text style={{ fontSize: 12, textAlign: 'center' }}>
                  {estimate.time} min
                </Text>
              </View>

              {destination ? (
                <View
                  style={{ flex: 1.5, paddingRight: 8, alignItems: 'flex-end' }}
                >
                  <Text style={{ fontSize: 12 }}>
                    {destination ? (
                      estimate.priceRange
                    ) : (
                      formattedCostPerDistance
                    )}
                  </Text>
                </View>
              ) : null}
            </TouchableOpacity>
          </View>
        )
      })
    )
  }

  render() {
    const {
      estimates,
      routeSelection: { destination },
      loadPickupEstimationStatus,
      findPickupEstimation,
      onPanelSnap,
      onPanelStop,
      onUpdatePanelHeight,
      snapIndex,
      basePanelheight,
      panelHeight,
    } = this.props

    return (
      <View style={styles.overlay} pointerEvents="box-none">
        <View style={{ height: screenHeight() }} pointerEvents="box-none" />
        <Interactable.View
          ref={ref => (this.interactableView = ref)}
          onLayout={event => onUpdatePanelHeight(event)}
          snapPoints={[{ y: -basePanelheight }, { y: -panelHeight }]}
          boundaries={{ top: -panelHeight, bottom: -basePanelheight }}
          initialPosition={
            snapIndex === 1 ? { y: -panelHeight } : { y: -basePanelheight }
          }
          onSnap={event => onPanelSnap(event)}
          onStop={event => onPanelStop(event)}
          verticalOnly
        >
          <View
            style={[
              {
                minHeight: 140,
                backgroundColor: 'white',
                margin: 5,
                borderRadius: 3,
              },
              styles.shadow,
            ]}
          >
            <View style={{ flexDirection: 'row', padding: 10 }}>
              <Text style={{ flex: 1, color: '#8e8e8e', fontSize: 13 }}>
                All Options
              </Text>
              <Text
                style={{
                  flex: 1,
                  color: '#8e8e8e',
                  fontSize: 13,
                  textAlign: 'center',
                }}
              >
                Time
              </Text>
              {destination ? (
                <Text
                  style={{
                    flex: 1.5,
                    color: '#8e8e8e',
                    fontSize: 13,
                    textAlign: 'right',
                  }}
                >
                  Fare
                </Text>
              ) : null}
            </View>

            <View style={{ height: 1, backgroundColor: '#c6c6c6' }} />

            {loadPickupEstimationStatus.status === 'error' ? (
              <View style={{ padding: 5 }}>
                <Text
                  style={{
                    color: 'red',
                    marginBottom: 5,
                    textAlign: 'center',
                  }}
                >
                  {loadPickupEstimationStatus.error.description}
                </Text>

                <View style={{ backgroundColor: '#42b549', borderRadius: 3 }}>
                  <TouchableOpacity
                    style={{ paddingHorizontal: 20, paddingVertical: 10 }}
                    onPress={findPickupEstimation}
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
            ) : null}

            {loadPickupEstimationStatus.status === 'loading' ? (
              <ActivityIndicator style={{ marginTop: 7 }} />
            ) : (
              this.renderEstimatesContent()
            )}
          </View>
        </Interactable.View>
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

const mapStateToProps = state => ({
  ...state,
  estimates: pickupEstimation(state),
})

const mapDispatchToProps = dispatch => ({
  selectRide: productId => {
    dispatch({
      type: 'RIDE_SELECT_VEHICLE',
      productId,
    })
  },
  findPickupEstimation: () => dispatch({ type: 'RIDE_FIND_PICKUP_ESTIMATION' }),
})

export default connect(mapStateToProps, mapDispatchToProps)(RideEstimationView)
