// @flow

import React, { Component } from 'react'
import {
  StyleSheet,
  Text,
  View,
  TextInput,
  TouchableWithoutFeedback,
  TouchableOpacity,
  ActivityIndicator,
  Image,
  Animated,
  Easing,
  Alert,
  ImageBackground,
} from 'react-native'
import MapView, { PROVIDER_GOOGLE } from 'react-native-maps'
import Navigator from 'native-navigation'
import last from 'lodash/last'
import { connect } from 'react-redux'
import Dash from 'react-native-dash'

import { openCancelDialog } from '../Actions/RideActions'
import NoResult from '../../unify/NoResult'
import {
  rupiahFormat,
  currencyFormat,
  getCurrentLocation,
  trackEvent,
  expiryTime,
} from '../Lib/RideHelper'

import RideEstimationView from './RideEstimationView'
import RideBookingConfirmationView from './RideBookingConfirmationView'
import RideOntripView from './RideOntripView'

import SourceIcon from '../Resources/ride-source.png'
import DestinationIcon from '../Resources/ride-destination.png'
import BikeIcon from '../Resources/bike.png'
import CarIcon from '../Resources/car.png'
import LocationIcon from '../Resources/icon-location.png'
import NavigationIcon from '../Resources/icon-navigation.png'
import PinIcon from '../Resources/icon-pin-drop.png'
import CancelIcon from '../Resources/icon-cancel.png'

const AnimatedTextInput = Animated.createAnimatedComponent(TextInput)

const styles = StyleSheet.create({
  container: {
    flex: 1,
    alignItems: 'stretch',
    backgroundColor: '#F5FCFF',
  },
  welcome: {
    fontSize: 20,
    textAlign: 'center',
    margin: 10,
  },
  instructions: {
    textAlign: 'center',
    color: '#333333',
    marginBottom: 5,
  },
  overlay: {
    position: 'absolute',
    top: 0,
    left: 0,
    right: 0,
    bottom: 0,
  },
  textInputWrapper: {
    height: 40,
    flexDirection: 'row',
  },
  inputContainer: {
    flex: 1,
  },
  locationBox: {
    flexDirection: 'row',
    marginHorizontal: 10,
    marginVertical: 5,
    backgroundColor: 'white',
    borderRadius: 3,
  },
  textInput: {
    flex: 1,
    alignSelf: 'center',
    fontSize: 14,
  },
  shadow: {
    shadowColor: 'black',
    shadowRadius: 1,
    shadowOpacity: 0.3,
    shadowOffset: { width: 0, height: 0 },
  },
})

export class RideHailingScreen extends Component {
  state = {
    screenName: 'Ride Home Page',
    basePanelheight: 140,
    panelHeight: 140,
    snapIndex: 0,
    initialLatitude: -6.1757247,
    initialLongitude: 106.8265106,
  }

  componentWillMount() {
    getCurrentLocation()
      .then(({ latitude, longitude }) => {
        this.setState({
          initialLatitude: latitude,
          initialLongitude: longitude,
        })
      })
      .catch(error => console.log('geo error', error))
  }

  componentDidMount() {
    this.props.loadCurrentTrip()
    this.zoomToCurrentLocation()
  }

  componentWillReceiveProps(newProps) {
    const { mode, currentTrip } = newProps

    // handle change screenName
    if (mode === 'riding') {
      if (
        currentTrip &&
        currentTrip.data &&
        currentTrip.data.status === 'in_progress'
      ) {
        this.setState({ screenName: 'Ride Booked Screen' })
      } else {
        this.setState({ screenName: 'Ride Booking Page' })
      }
    } else {
      this.setState({ screenName: 'Ride Home Page' })
    }

    /* handle after cancel ride
    source and destination still empty
    need to update snapIndex to 0 and panelHeight to default
    so the Interactable can fit to the bottom of screen
    */
    const { routeSelection: { source, destination } } = newProps

    // handle snapPanel
    if (mode === 'select-route' && !source && !destination) {
      this.setState({ snapIndex: 0, panelHeight: this.state.basePanelheight })
    }
  }

  componentDidUpdate(previousProps) {
    const {
      loadCurrentTripStatus: previousLoadCurrentTripStatus,
    } = previousProps

    const {
      route,
      routeSelection: { source, destination },
      shouldZoom,
      loadCurrentTripStatus,
    } = this.props

    if (
      loadCurrentTripStatus.status === 'loaded' &&
      previousLoadCurrentTripStatus.status !== 'loaded'
    ) {
      this.zoomToCurrentLocation()
    }

    if (shouldZoom) {
      if (source && !destination) {
        this.mapView.animateToRegion(
          {
            ...source.location.coordinate,
            latitudeDelta: 0.003,
            longitudeDelta: 0.003,
          },
          1000,
        )
      } else if (route && route.region) {
        this.mapView.animateToRegion(route.region, 1000)
      }
    }
  }

  componentWillUnmount() {
    this.props.onExitScreen()
    trackEvent('GenericUberEvent', 'click back', this.state.screenName)
  }

  _shakeValue = new Animated.Value(0)

  _shakeDestination = () => {
    this._shakeValue.setValue(0)

    this.setState({ destinationPlaceholderColor: 'red' })

    Animated.timing(this._shakeValue, {
      toValue: 2,
      easing: Easing.bounce,
      duration: 800,
      useNativeDriver: true,
      onComplete: () => this.setState({ destinationPlaceholderColor: null }),
    }).start()
  }

  _onCancelButtonTap = () => {
    const { cancelGracePeriod, selectedProduct } = this.props
    const showCancellationFee = cancelGracePeriod < Date.now()
    const cancellationFee =
      selectedProduct &&
      `${currencyFormat(
        selectedProduct.price_details.currency_code,
      )} ${rupiahFormat(selectedProduct.price_details.cancellation_fee)}`
    const text = showCancellationFee
      ? `\nCancellation Fee: ${cancellationFee}`
      : ''

    Alert.alert('Cancel ride', `Are you sure?${text}`, [
      {
        text: 'Yes',
        onPress: () => {
          this.props.cancelRide()
        },
      },
      { text: 'No', style: 'cancel' },
    ])
  }

  onPanelSnap = event => {
    this.setState({ snapIndex: event.nativeEvent.index })
  }

  onPanelStop = event => {
    const { basePanelheight } = this.state
    const { y } = event.nativeEvent
    // snapIndex = 1 means panel is open
    // 5 is to tolerate number between  basePanelHeight to basePanelheight + 5
    const basePanelHeightWithTolerate = basePanelheight + 5
    if (Math.abs(Math.floor(y)) > basePanelHeightWithTolerate) {
      this.setState({ snapIndex: 1 })
    } else {
      this.setState({ snapIndex: 0 })
    }
  }

  onUpdatePanelHeight = event => {
    this.setState({
      panelHeight: event.nativeEvent.layout.height,
    })
  }

  zoomToCurrentLocation = () =>
    getCurrentLocation()
      .then(({ latitude, longitude }) => {
        if (this.mapView) {
          this.mapView.animateToRegion({
            latitude,
            longitude,
            latitudeDelta: 0.003,
            longitudeDelta: 0.003,
          })
        }
      })
      .catch(error => console.log('geo error', error))

  handleLocationButton = this.zoomToCurrentLocation

  render() {
    const {
      routeSelection,
      routeSelection: { source, destination },
      sourceSearch,
      sourceName,
      destinationSearch,
      route,
      removeDestination,
      estimates,
      currentTrip,
      onRegionChanged,
      isDraggingMap,
      onMapStartDragging,
      screenTitle,
      dropOffCoordinate,
      pickupCoordinate,
      fareOverviewLoadStatus,
      selectedProduct,
      bookRide,
      isLoadingCurrentTrip,
      loadCurrentTripStatus,
      loadPickupEstimationStatus,
      mode,
      requestStatus,
      shortestPickupTime,
      showTermsOfServiceInterrupt,
      interrupt,
      promoCodeApplied,
      loadShareUrlTrip,
      locationSource,
    } = this.props

    const {
      destinationPlaceholderColor,
      screenName,
      snapIndex,
      basePanelheight,
      panelHeight,
      initialLatitude,
      initialLongitude,
    } = this.state

    const coordinates = route && route.coordinates
    const pickUpBoxText =
      !destination && routeSelection.status === 'loading'
        ? 'Loading...'
        : sourceName

    if (isLoadingCurrentTrip) {
      return (
        <View style={[styles.container, { justifyContent: 'center' }]}>
          <ActivityIndicator size="large" />
        </View>
      )
    }

    if (loadCurrentTripStatus.status === 'error') {
      return (
        <View>
          <NoResult
            title="Oops!"
            subtitle={loadCurrentTripStatus.error.description}
            buttonTitle="Try again"
            onButtonPress={this.props.loadCurrentTrip}
            style={{
              marginTop: 60,
            }}
          />
        </View>
      )
    }

    return (
      <View style={styles.container}>
        {/* navigator.config */}
        {mode === 'select-route' ? (
          <Navigator.Config
            title={screenTitle}
            rightTitle="Your Trips"
            onRightPress={() => {
              Navigator.push('RideHistoryScreen')
              trackEvent('GenericUberEvent', 'click on your trips', screenName)
            }}
            onAppear={() => {
              // handle after cancel and open receipt
              if (mode === 'select-route' && !source && !destination) {
                this.handleLocationButton()
              }
            }}
          />
        ) : (
          <Navigator.Config
            title={screenTitle}
            rightTitle=""
            onRightPress={() => {}}
            onAppear={() => {}}
          />
        )}

        {/* mapview */}
        <MapView
          ref={ref => (this.mapView = ref)}
          provider={PROVIDER_GOOGLE}
          style={{ flexGrow: 1 }}
          initialRegion={{
            latitude: initialLatitude,
            longitude: initialLongitude,
            latitudeDelta: 0.04546489130798292,
            longitudeDelta: 0.03475338220596313,
          }}
          onRegionChangeComplete={region =>
            onRegionChanged(region, locationSource)}
          onRegionChange={onMapStartDragging}
          showsUserLocation
        >
          {coordinates && (
            <MapView.Polyline
              coordinates={coordinates}
              strokeWidth={2}
              lineJoin={'round'}
            />
          )}
          {pickupCoordinate && (
            <MapView.Marker coordinate={pickupCoordinate}>
              <Image source={SourceIcon} style={{ width: 15, height: 15 }} />
            </MapView.Marker>
          )}
          {dropOffCoordinate && (
            <MapView.Marker coordinate={dropOffCoordinate}>
              <Image
                source={DestinationIcon}
                style={{ width: 15, height: 15 }}
              />
            </MapView.Marker>
          )}
          {currentTrip &&
          currentTrip.data &&
          currentTrip.data.status !== 'in_progress' && (
            <MapView.Marker
              coordinate={currentTrip.data.location}
              rotation={currentTrip.data.location.bearing}
              anchor={{ x: 0.5, y: 0.5 }}
            >
              <Image
                resizeMode="contain"
                source={
                  selectedProduct.display_name === 'uberMotor' ? (
                    BikeIcon
                  ) : (
                    CarIcon
                  )
                }
                style={{ maxWidth: 15 }}
              />
            </MapView.Marker>
          )}
          {currentTrip &&
          currentTrip.data &&
          currentTrip.data.status === 'in_progress' &&
          currentTrip.userLocation && (
            <MapView.Marker
              coordinate={currentTrip.userLocation}
              anchor={{ x: 0.5, y: 0.5 }}
            >
              <Image
                resizeMode="contain"
                source={
                  selectedProduct.display_name === 'uberMotor' ? (
                    BikeIcon
                  ) : (
                    CarIcon
                  )
                }
                style={{ maxWidth: 15 }}
              />
            </MapView.Marker>
          )}
        </MapView>

        {/* marker icon on map */}
        {mode === 'select-route' &&
        !destination && (
          <View
            style={[
              styles.overlay,
              { justifyContent: 'center', alignItems: 'center' },
            ]}
            pointerEvents="box-none"
          >
            <ImageBackground
              source={PinIcon}
              style={{
                marginBottom: 49,
                alignItems: 'center',
                width: 38,
                height: 49,
              }}
            >
              <View
                style={{ height: 22, marginTop: 8, justifyContent: 'center' }}
              >
                <Text
                  style={{
                    backgroundColor: 'transparent',
                    color: 'white',
                    fontSize: 9,
                    fontWeight: '500',
                    textAlign: 'center',
                  }}
                >
                  {shortestPickupTime ? `${shortestPickupTime}\nmin` : '--'}
                </Text>
              </View>
            </ImageBackground>
          </View>
        )}

        <View style={[styles.overlay]} pointerEvents="box-none">
          {/* form source and destination */}
          <View style={[styles.locationBox, styles.shadow]}>
            <View
              style={{
                alignItems: 'center',
                paddingHorizontal: 10,
                paddingVertical: 13,
              }}
            >
              <Image source={SourceIcon} style={{ width: 13, height: 13 }} />
              <Dash
                style={{ flexDirection: 'column', flex: 1, marginVertical: 3 }}
                dashColor="#c6c6c6"
                dashThickness={1}
              />
              <Image
                source={DestinationIcon}
                style={{ width: 13, height: 13 }}
              />
            </View>
            <View style={styles.inputContainer}>
              <TouchableWithoutFeedback
                onPress={() => {
                  sourceSearch()
                  trackEvent('GenericUberEvent', 'click source', screenName)
                }}
              >
                <View style={styles.textInputWrapper}>
                  <TextInput
                    placeholder="Select Pickup"
                    value={pickUpBoxText}
                    style={styles.textInput}
                    editable={false}
                    pointerEvents="box-none"
                  />
                </View>
              </TouchableWithoutFeedback>

              <View style={{ height: 1, backgroundColor: '#c6c6c6' }} />

              <TouchableWithoutFeedback
                onPress={() => {
                  destinationSearch()
                  trackEvent(
                    'GenericUberEvent',
                    'click destination',
                    screenName,
                  )
                }}
              >
                <View style={styles.textInputWrapper}>
                  <AnimatedTextInput
                    placeholder="Select Destination"
                    placeholderTextColor={destinationPlaceholderColor}
                    value={destination && destination.name}
                    pointerEvents="box-none"
                    style={[
                      styles.textInput,
                      {
                        transform: [
                          {
                            translateX: this._shakeValue.interpolate({
                              inputRange: [0, 1, 2],
                              outputRange: [0, 30, 0],
                            }),
                          },
                        ],
                      },
                    ]}
                    editable={false}
                  />

                  {destination &&
                  mode !== 'riding' && (
                    <TouchableOpacity
                      style={{
                        alignSelf: 'stretch',
                        justifyContent: 'center',
                        paddingRight: 10,
                        paddingLeft: 30,
                      }}
                      onPress={() => {
                        removeDestination()
                        trackEvent(
                          'GenericUberEvent',
                          'click delete destination',
                          `${screenName} - ${destination.name}`,
                        )
                      }}
                    >
                      <Image
                        source={CancelIcon}
                        style={{ height: 15, width: 15 }}
                      />
                    </TouchableOpacity>
                  )}
                </View>
              </TouchableWithoutFeedback>
            </View>
          </View>

          {/* button navigation */}
          <TouchableOpacity
            onPress={this.handleLocationButton}
            style={{ alignSelf: 'flex-end', marginRight: 8 }}
          >
            {mode === 'riding' &&
            currentTrip &&
            currentTrip.status === 'in_progress' ? (
              <Image source={NavigationIcon} />
            ) : (
              <Image source={LocationIcon} />
            )}
          </TouchableOpacity>
          <View style={{ flex: 1 }} pointerEvents="none" />

          {/* estimation view */}
          {mode === 'select-route' ? (
            <RideEstimationView
              shakeDestination={this._shakeDestination}
              screenName={screenName}
              snapIndex={snapIndex}
              onPanelSnap={this.onPanelSnap}
              onPanelStop={this.onPanelStop}
              onUpdatePanelHeight={this.onUpdatePanelHeight}
              basePanelheight={basePanelheight}
              panelHeight={panelHeight}
            />
          ) : null}

          {/* booking confirmation view */}
          {mode === 'booking-confirmation' &&
          (fareOverviewLoadStatus.status !== 'idle' ||
            requestStatus.status === 'error') ? (
              <RideBookingConfirmationView />
          ) : null}

          {/* overlay - load when uber/request */}
          {mode === 'riding' && !currentTrip ? (
            <View
              style={[
                styles.overlay,
                {
                  backgroundColor: 'rgba(0,0,0,0.5)',
                  alignItems: 'center',
                  justifyContent: 'center',
                },
              ]}
            >
              <Navigator.Config title="Requesting Ride" />
              <ActivityIndicator size="large" />
            </View>
          ) : null}

          {/* ontrip view */}
          {mode === 'riding' &&
          currentTrip &&
          currentTrip.status !== 'processing' ? (
            <RideOntripView
              screenName={screenName}
              onCancelButtonTap={this._onCancelButtonTap}
            />
          ) : null}
        </View>

        {/* overlay - when uber/request/detail */}
        {currentTrip && currentTrip.status === 'processing' ? (
          <View
            style={[
              styles.overlay,
              {
                backgroundColor: 'rgba(0,0,0,0.5)',
                alignItems: 'center',
                justifyContent: 'center',
              },
            ]}
          >
            <ActivityIndicator size="large" />

            <TouchableOpacity
              onPress={() => {
                this._onCancelButtonTap()
                trackEvent(
                  'GenericUberEvent',
                  'click cancel request ride',
                  screenName,
                )
              }}
              style={{
                margin: 10,
                padding: 10,
                backgroundColor: '#FFFFFF',
                borderRadius: 2,
                borderWidth: 1,
                borderColor: '#FFFFFF',
                position: 'absolute',
                left: 0,
                right: 0,
                bottom: 0,
                justifyContent: 'flex-end',
              }}
            >
              <Text
                style={{
                  color: '#B4B4B4',
                  textAlign: 'center',
                  fontWeight: '500',
                }}
              >
                Cancel
              </Text>
            </TouchableOpacity>
          </View>
        ) : null}

        {/* interupt tos view */}
        {showTermsOfServiceInterrupt ? (
          <View style={styles.overlay}>
            <View
              style={{
                flex: 1,
                backgroundColor: 'rgba(0, 0, 0, 0.5)',
                justifyContent: 'center',
                alignItems: 'center',
              }}
            >
              <View
                style={{
                  backgroundColor: 'white',
                  borderRadius: 3,
                  padding: 20,
                  alignItems: 'center',
                }}
              >
                <Text style={{ fontSize: 13 }}>By clicking Booking Ride,</Text>
                <Text style={{ fontSize: 13 }}>
                  I agree with{' '}
                  <TouchableOpacity
                    style={{ width: 132, height: 12.5 }}
                    onPress={() => {
                      Navigator.push('RideWebViewScreen', {
                        url: interrupt.link,
                        expectedCode: 'tos_tokopedia_id',
                      })
                    }}
                  >
                    <Text style={{ fontSize: 13, color: '#42b549' }}>
                      terms and conditions.
                    </Text>
                  </TouchableOpacity>
                </Text>

                <View style={{ flexDirection: 'row', marginTop: 20 }}>
                  <View
                    style={{
                      borderColor: '#42b549',
                      borderWidth: 1,
                      borderRadius: 3,
                    }}
                  >
                    <TouchableOpacity
                      style={{
                        width: 100,
                        height: 40,
                        alignItems: 'center',
                        justifyContent: 'center',
                      }}
                      onPress={this.props.handleRejectTermsOfService}
                    >
                      <Text style={{ color: '#42b549', textAlign: 'center' }}>
                        Cancel
                      </Text>
                    </TouchableOpacity>
                  </View>

                  <View
                    style={{
                      backgroundColor: '#42b549',
                      marginLeft: 20,
                      borderRadius: 3,
                    }}
                  >
                    <TouchableOpacity
                      style={{
                        width: 100,
                        height: 40,
                        alignItems: 'center',
                        justifyContent: 'center',
                      }}
                      onPress={() => {
                        this.props.bookRide(selectedProduct.product_id, {
                          [interrupt.code.name]: interrupt.code.value,
                        })
                      }}
                    >
                      <Text style={{ color: 'white', textAlign: 'center' }}>
                        Accept
                      </Text>
                    </TouchableOpacity>
                  </View>
                </View>
              </View>
            </View>
          </View>
        ) : null}
      </View>
    )
  }
}

const screenTitle = state => {
  const { currentTrip, selectedProductId } = state

  if (!currentTrip) {
    return 'Booking Ride'
  }

  const product = selectedProduct(state)

  const titles = {
    completed: 'On Trip',
    in_progress: 'On Trip',
    arriving: 'Driver arriving',
    accepted: `${product && product.display_name} Booked`,
    processing: `Finding your ${product && product.display_name}`,
  }

  return titles[currentTrip.status] || 'Booking Ride'
}

const placeDisplayName = place =>
  place.name ||
  `${place.location.coordinate.latitude}, ${place.location.coordinate
    .longitude}`

const dropOffCoordinateSelector = state => {
  const { route, currentTrip } = state

  if (currentTrip) {
    return currentTrip.data.destination
  }

  if (route && route.coordinates) {
    return last(route.coordinates)
  }

  return null
}

const pickupCoordinateSelector = state => {
  const { route, currentTrip } = state

  if (currentTrip) {
    return currentTrip.data.pickup
  }

  if (route && route.coordinates) {
    return route.coordinates[0]
  }

  return null
}

const selectedProduct = state => {
  const { selectedProductId, products } = state

  const product = products.filter(
    product => product.product_id === selectedProductId,
  )[0]

  return product
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

const getShortestPickupTime = state => {
  const { timeEstimations } = state
  if (!timeEstimations || !timeEstimations.length) {
    return null
  }

  return timeEstimations
    .map(estimation => estimation.time)
    .reduce((a, b) => Math.min(a, b), 10000)
}

const mapStateToProps = state => {
  const source = state.routeSelection.source

  return {
    ...state,
    sourceName: source && placeDisplayName(source),
    screenTitle: screenTitle(state),
    dropOffCoordinate: dropOffCoordinateSelector(state),
    pickupCoordinate: pickupCoordinateSelector(state),
    selectedProduct: selectedProduct(state),
    isLoadingCurrentTrip: state.loadCurrentTripStatus.status === 'loading',
    estimates: pickupEstimation(state),
    shortestPickupTime: getShortestPickupTime(state),
    cancelGracePeriod: expiryTime(
      state.currentTrip && state.currentTrip.data.cancel_grace_period,
    ),
  }
}

const mapDispatchToProps = dispatch => ({
  sourceSearch: () => {
    dispatch({
      type: 'RIDE_SEARCH',
      searchType: 'source',
    })
  },

  destinationSearch: () => {
    dispatch({
      type: 'RIDE_SEARCH',
      searchType: 'destination',
    })
  },

  bookRide: (productId, additionalParams) => {
    dispatch({
      type: 'RIDE_BOOK_VEHICLE',
      productId,
      tosConfirmation: additionalParams,
    })
  },

  removeDestination: () => {
    dispatch({
      type: 'RIDE_REMOVE_DESTINATION',
    })
  },

  onRegionChanged: (region, locationSource) => {
    dispatch({
      type: 'RIDE_MAP_STOP_DRAGGING',
    })

    dispatch({
      type: 'RIDE_REGION_CHANGE',
      region: {
        latitude: region.latitude,
        longitude: region.longitude,
      },
      locationSource,
    })
  },

  onMapStartDragging: () => dispatch({ type: 'RIDE_MAP_START_DRAGGING' }),

  loadCurrentTrip: () => dispatch({ type: 'RIDE_LOAD_CURRENT_TRIP' }),

  cancelRide: () => dispatch(openCancelDialog),

  onExitScreen: () => dispatch({ type: 'RIDE_RESET_STATE' }),

  handleRejectTermsOfService: () => dispatch({ type: 'RIDE_REJECT_TOS' }),
})

export default connect(mapStateToProps, mapDispatchToProps)(RideHailingScreen)
