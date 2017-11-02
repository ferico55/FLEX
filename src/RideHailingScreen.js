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
  Linking,
  Dimensions,
  ImageBackground,
} from 'react-native'
import { ReactInteractionHelper } from 'NativeModules'
import Interactable from 'react-native-interactable'
import MapView, { PROVIDER_GOOGLE } from 'react-native-maps'
import Navigator from 'native-navigation'
import last from 'lodash/last'
import { connect } from 'react-redux'
import Dash from 'react-native-dash'

import { openCancelDialog } from './redux/RideActions'
import NoResult from './unify/NoResult'
import { expiryTime } from './selector'
import {
  rupiahFormat,
  currencyFormat,
  getCurrentLocation,
  trackEvent,
} from './RideHelper'

import SourceIcon from './resources/ride-source.png'
import DestinationIcon from './resources/ride-destination.png'
import BikeIcon from './resources/bike.png'
import CarIcon from './resources/car.png'
import LocationIcon from './resources/icon-location.png'
import NavigationIcon from './resources/icon-navigation.png'
import PinIcon from './resources/icon-pin-drop.png'
import CancelIcon from './resources/icon-cancel.png'
import UberIcon from './resources/icon-uber.png'
import IconUberPeople from './resources/icon-uber-people.png'
import IconUberTag from './resources/icon-uber-tag.png'
import IconUberThumbsUp from './resources/icon-uber-thumbs-up.png'
import IconMessage from './resources/icon-message.png'
import IconPhone from './resources/icon-phone.png'

const AnimatedTextInput = Animated.createAnimatedComponent(TextInput)
const screenHeight = Dimensions.get('screen').height - 64

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

export class RideHailingScreen extends Component {
  // basePanelheight => basic panel height
  state = {
    basePanelheight: 140,
    panelHeight: 140,
    snapIndex: 0,
    screenName: 'Ride Home Page',
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

  _onRowSelected = productId => {
    if (!this.props.routeSelection.destination) {
      this._shakeDestination()
    } else {
      this.props.selectRide(productId)
    }
  }

  componentDidMount() {
    this.props.loadCurrentTrip()
  }

  componentWillReceiveProps(newProps) {
    /* handle after cancel ride
    source and destination still empty
    need to update snapIndex to 0 and panelHeight to default
    so the Interactable can fit to the bottom of screen
    */
    const {
      routeSelection: { source, destination },
      mode,
      currentTrip,
    } = newProps

    // handle snapPanel
    if (mode === 'select-route' && !source && !destination) {
      this.setState({ snapIndex: 0, panelHeight: this.state.basePanelheight })
    }

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
  }

  componentDidUpdate(previousProps) {
    const {
      route: previousRoute,
      routeSelection: { destination: previousDestination },
      loadPickupEstimationStatus: previousPickupEstimationStatus,
      loadCurrentTripStatus: previousLoadCurrentTripStatus,
    } = previousProps

    const {
      route,
      routeSelection: { source, destination },
      loadPickupEstimationStatus,
      shouldZoom,
      loadCurrentTripStatus,
    } = this.props

    if (
      this.interactableView &&
      previousPickupEstimationStatus.status === 'loaded' &&
      previousPickupEstimationStatus.status !==
        loadPickupEstimationStatus.status
    ) {
      this.interactableView.snapTo({ index: this.state.snapIndex })
    }

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

  renderEstimatesContent = () => {
    const { estimates, routeSelection: { destination } } = this.props
    const { screenName } = this.state

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

  renderSelectedProduct = () => {
    const {
      fareOverviewLoadStatus,
      selectedProduct,
      requestStatus,
      cancelSelectedProduct,
      bookRide,
      mode,
    } = this.props
    const { screenName } = this.state
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
            height: 172,
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
    const {
      prediction,
      routeSelection: { source, destination },
      sourceSearch,
      sourceName,
      destinationSearch,
      route,
      selectRide,
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
    } = this.props

    const fareOverview = fareOverviewLoadStatus.fareOverview

    const {
      destinationPlaceholderColor,
      panelHeight,
      basePanelheight,
      screenName,
    } = this.state

    const coordinates = route && route.coordinates
    const pickUpBoxText =
      !destination && isDraggingMap ? 'Loading...' : sourceName

    // handle after cancel
    if (mode === 'select-route' && !source && !destination) {
      this.handleLocationButton()
    }

    if (isLoadingCurrentTrip) {
      return (
        <View style={[styles.container, { justifyContent: 'center' }]}>
          <ActivityIndicator size="large" />
        </View>
      )
    }

    if (loadCurrentTripStatus.status == 'error') {
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
        {mode === 'select-route' ? (
          <Navigator.Config
            title={screenTitle}
            rightTitle="Your Trips"
            onRightPress={() => {
              Navigator.push('RideHistoryScreen')
              trackEvent('GenericUberEvent', 'click on your trips', screenName)
            }}
          />
        ) : (
          <Navigator.Config
            title={screenTitle}
            rightTitle=""
            onRightPress={() => {}}
          />
        )}
        <MapView
          ref={ref => (this.mapView = ref)}
          provider={PROVIDER_GOOGLE}
          style={{ flexGrow: 1 }}
          initialRegion={{
            latitude: -6.1757247,
            longitude: 106.8265106,
            latitudeDelta: 0.04546489130798292,
            longitudeDelta: 0.03475338220596313,
          }}
          onRegionChangeComplete={onRegionChanged}
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

          {mode === 'select-route' ? (
            <View style={styles.overlay} pointerEvents="box-none">
              <View style={{ height: screenHeight }} pointerEvents="box-none" />
              <Interactable.View
                ref={ref => (this.interactableView = ref)}
                onLayout={event => {
                  this.setState({
                    panelHeight: event.nativeEvent.layout.height,
                  })
                }}
                snapPoints={[{ y: -basePanelheight }, { y: -panelHeight }]}
                boundaries={{ top: -panelHeight, bottom: -basePanelheight }}
                initialPosition={
                  this.state.snapIndex === 1 ? (
                    { y: -panelHeight }
                  ) : (
                    { y: -basePanelheight }
                  )
                }
                onSnap={this.onPanelSnap}
                onStop={this.onPanelStop}
                verticalOnly
              >
                <View
                  style={[
                    {
                      minHeight: 200,
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

                  {loadPickupEstimationStatus.status == 'error' ? (
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

                      <View
                        style={{ backgroundColor: '#42b549', borderRadius: 3 }}
                      >
                        <TouchableOpacity
                          style={{ paddingHorizontal: 20, paddingVertical: 10 }}
                          onPress={this.props.findPickupEstimation}
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
          ) : null}

          {mode === 'booking-confirmation' &&
          (fareOverviewLoadStatus.status !== 'idle' ||
            requestStatus.status === 'error') ? (
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
                        Edit
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
                        Apply
                      </Text>
                    </TouchableOpacity>
                  )}
                </View>
              ) : null}

              {this.renderSelectedProduct()}
            </View>
          ) : null}

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

          {/* {mode === 'riding' && requestStatus.status === 'error' ? (
            <View>
              <Text>{requestStatus.error.description}</Text>
              <Button
                title="Try again"
                onPress={() => bookRide(selectedProduct.product_id)}
              />
            </View>
          ) : null} */}

          {mode === 'riding' &&
          currentTrip &&
          currentTrip.status != 'processing' ? (
            <View
              style={[
                {
                  margin: 8,
                  backgroundColor: 'white',
                  borderRadius: 3,
                },
                styles.shadow,
              ]}
            >
              <View
                style={{
                  flexDirection: 'row',
                  padding: 15,
                }}
              >
                <View style={{ alignItems: 'center' }}>
                  <View style={[{ borderRadius: 27 }, styles.shadow]}>
                    <Image
                      source={{ uri: currentTrip.data.driver.picture_url }}
                      style={{
                        width: 54,
                        aspectRatio: 1,
                        borderRadius: 27,
                      }}
                    />
                  </View>

                  <View
                    style={[
                      {
                        flexDirection: 'row',
                        alignItems: 'center',
                        backgroundColor: 'white',
                        paddingVertical: 1,
                        paddingHorizontal: 10,
                        borderRadius: 3,
                        marginTop: -10,
                      },
                      styles.shadow,
                    ]}
                  >
                    <Image
                      source={{ uri: 'icon_star_active' }}
                      style={{ width: 10, height: 10, marginRight: 3 }}
                    />
                    <Text
                      style={{ color: 'rgba(0, 0, 0, 0.54)', fontSize: 11 }}
                    >
                      {currentTrip.data.driver.rating}
                    </Text>
                  </View>
                </View>

                <View style={{ flex: 1, marginLeft: 10 }}>
                  <Text style={{ fontWeight: '500', marginBottom: 5 }}>
                    {currentTrip.data.driver.name}
                  </Text>
                  <Text style={{ color: 'rgba(0,0,0,0.54)' }}>
                    {currentTrip.data.vehicle.make}{' '}
                    {currentTrip.data.vehicle.model}
                  </Text>
                  <Text style={{ color: 'rgba(0,0,0,0.54)' }}>
                    {currentTrip.data.vehicle.license_plate}
                  </Text>
                </View>
                <View>
                  <Text
                    style={{
                      color: '#42b549',
                      textAlign: 'right',
                      fontWeight: '500',
                      fontSize: 12,
                    }}
                  >
                    {currentTrip.status === 'arriving' ||
                    currentTrip.status === 'accepted' ? (
                      `ETA ${currentTrip.data.pickup.eta} min`
                    ) : (
                      `ETA ${currentTrip.data.destination.eta} min`
                    )}
                  </Text>

                  <View style={{ flexDirection: 'row', marginTop: 10 }}>
                    <TouchableOpacity
                      style={{ marginRight: 8 }}
                      onPress={() => {
                        const url = `sms:${currentTrip.data.driver
                          .phone_number}`

                        Linking.canOpenURL(url).then(canOpen => {
                          if (canOpen) {
                            Linking.openURL(url)
                          } else {
                            Alert.alert('SMS not supported on this device')
                          }
                        })
                        trackEvent('GenericUberEvent', 'click sms', screenName)
                      }}
                    >
                      <Image
                        source={IconMessage}
                        style={{ width: 30, height: 30, aspectRatio: 1 }}
                      />
                    </TouchableOpacity>

                    <TouchableOpacity
                      onPress={() => {
                        const url = `tel:${currentTrip.data.driver
                          .phone_number}`

                        Linking.canOpenURL(url).then(canOpen => {
                          if (canOpen) {
                            Linking.openURL(url)
                          } else {
                            Alert.alert(
                              'Phone call not supported on this device',
                            )
                          }
                        })
                        trackEvent('GenericUberEvent', 'click call', screenName)
                      }}
                    >
                      <Image
                        source={IconPhone}
                        style={{ width: 30, height: 30, aspectRatio: 1 }}
                      />
                    </TouchableOpacity>
                  </View>
                </View>
              </View>
              <View style={{ height: 1, backgroundColor: '#e6e6e6' }} />
              <View style={{ flexDirection: 'row', height: 51 }}>
                <TouchableOpacity
                  onPress={event => {
                    ReactInteractionHelper.share(
                      loadShareUrlTrip.url,
                      '',
                      `Follow my Uber trip`,
                      event.target,
                    )
                    trackEvent(
                      'GenericUberEvent',
                      'click share eta',
                      screenName,
                    )
                  }}
                  disabled={loadShareUrlTrip.status === 'loading'}
                  style={{
                    alignItems: 'center',
                    flex: 1,
                    justifyContent: 'center',
                  }}
                >
                  {loadShareUrlTrip.status !== 'loading' ? (
                    <View
                      style={{
                        flexDirection: 'row',
                        alignItems: 'center',
                        flex: 1,
                        justifyContent: 'center',
                      }}
                    >
                      <Image
                        source={{ uri: 'icon_button_share' }}
                        style={{
                          tintColor: '#646464',
                          width: 25,
                          aspectRatio: 1,
                        }}
                      />
                      <Text
                        style={{
                          marginLeft: 5,
                          color: 'rgba(0, 0, 0, 0.54)',
                        }}
                      >
                        Share
                      </Text>
                    </View>
                  ) : (
                    <ActivityIndicator size={'small'} />
                  )}
                </TouchableOpacity>

                {currentTrip.status !== 'in_progress' &&
                currentTrip.status !== 'completed' ? (
                  [
                    <View
                      key="separator"
                      style={{ width: 1, backgroundColor: '#e6e6e6' }}
                    />,

                    <TouchableOpacity
                      key="cancel"
                      onPress={() => {
                        this._onCancelButtonTap()
                        trackEvent(
                          'GenericUberEvent',
                          'click cancel',
                          screenName,
                        )
                      }}
                      style={{
                        flexDirection: 'row',
                        alignItems: 'center',
                        flex: 1,
                        justifyContent: 'center',
                      }}
                    >
                      <Image
                        source={CancelIcon}
                        style={{ width: 22, aspectRatio: 1 }}
                      />
                      <Text
                        style={{ marginLeft: 5, color: 'rgba(0, 0, 0, 0.54)' }}
                      >
                        Cancel
                      </Text>
                    </TouchableOpacity>,
                  ]
                ) : null}
              </View>
            </View>
          ) : null}
        </View>

        {currentTrip && currentTrip.status == 'processing' ? (
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

const placeDisplayName = place => place.name || 'Loading...'

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
    product => product.product_id == selectedProductId,
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
    isLoadingCurrentTrip: state.loadCurrentTripStatus.status == 'loading',
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

  removeDestination: () => {
    dispatch({
      type: 'RIDE_REMOVE_DESTINATION',
    })
  },

  cancelSelectedProduct: () => {
    dispatch({
      type: 'RIDE_CANCEL_SELECTED_PRODUCT',
    })
  },

  onRegionChanged: region => {
    dispatch({
      type: 'RIDE_MAP_STOP_DRAGGING',
    })

    dispatch({
      type: 'RIDE_REGION_CHANGE',
      region: {
        latitude: region.latitude,
        longitude: region.longitude,
      },
    })
  },

  onMapStartDragging: () => dispatch({ type: 'RIDE_MAP_START_DRAGGING' }),

  loadCurrentTrip: () => dispatch({ type: 'RIDE_LOAD_CURRENT_TRIP' }),

  cancelRide: () => dispatch(openCancelDialog),

  onExitScreen: () => dispatch({ type: 'RIDE_RESET_STATE' }),

  findPickupEstimation: () => dispatch({ type: 'RIDE_FIND_PICKUP_ESTIMATION' }),

  handleRejectTermsOfService: () => dispatch({ type: 'RIDE_REJECT_TOS' }),
})

export default connect(mapStateToProps, mapDispatchToProps)(RideHailingScreen)
