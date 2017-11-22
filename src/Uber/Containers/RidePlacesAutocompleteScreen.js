// @flow
import React, { Component } from 'react'
import {
  View,
  Text,
  StyleSheet,
  TextInput,
  TouchableOpacity,
  ScrollView,
  Image,
  Keyboard,
  ImageBackground,
  ActivityIndicator,
  FlatList,
} from 'react-native'

import MapView, { PROVIDER_GOOGLE } from 'react-native-maps'
import { connect } from 'react-redux'
import noop from 'lodash/noop'
import Navigator from 'native-navigation'
import { Observable } from 'rxjs'

import MapIcon from '../Resources/icon-map.png'
import PlaceIcon from '../Resources/icon-place.png'
import PinIcon from '../Resources/icon-pin-drop.png'
import LocationIcon from '../Resources/icon-location.png'
import LocationIconTransparant from '../Resources/icon-location-transparant.png'

import { getCurrentLocation, trackEvent } from '../Lib/RideHelper'

const blackColor = 'rgba(0,0,0, 0.7)'

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: '#f1f1f1',
  },
  overlay: {
    position: 'absolute',
    left: 0,
    right: 0,
    top: 0,
    bottom: 0,
    padding: 10,
    justifyContent: 'flex-end',
  },
  topOverlay: {
    position: 'absolute',
    left: 0,
    right: 0,
    top: 0,
    padding: 10,
    justifyContent: 'flex-end',
  },
  bottomOverlay: {
    position: 'absolute',
    left: 0,
    right: 0,
    bottom: 0,
    padding: 10,
    justifyContent: 'flex-end',
  },
  openMap: {
    backgroundColor: 'white',
    marginTop: 8,
    paddingVertical: 10,
    paddingHorizontal: 8,
    flexDirection: 'row',
    height: 44,
    alignItems: 'center',
  },
  textInput: {
    height: 45,
    flex: 1,
    fontSize: 14,
    backgroundColor: 'white',
    paddingHorizontal: 10,
  },
  description: {
    fontSize: 12,
    color: 'rgba(0,0,0,0.54)',
  },
  row: {
    paddingVertical: 5,
  },
  separator: {
    marginLeft: 36,
    height: 1,
    backgroundColor: '#f1f1f1',
  },
  overlayLoading: {
    position: 'absolute',
    top: 0,
    left: 0,
    right: 0,
    bottom: 0,
  },
})

const placeDisplayName = place => place.name || 'Loading...'

const mapStateToProps = state => ({
  ...state,
  currentLocation: state.locationSearch,
})

const mapDispatchToProps = dispatch => ({
  onAutoDetectLocation: region => {
    dispatch({
      type: 'RIDE_AUTO_DETECT_LOCATION',
      region,
    })
  },
  onPredictionSelected: (prediction, trackAction) => {
    dispatch({
      type: 'RIDE_SELECT_SUGGESTION',
      placeId: prediction.location.placeId,
      trackAction,
    })
  },
  onQueryChanged: event =>
    dispatch({
      type: 'RIDE_TYPE_AUTOCOMPLETE',
      query: event.nativeEvent.text,
    }),

  onExitScreen: () => dispatch({ type: 'RIDE_EXIT_AUTOCOMPLETE_SCREEN' }),

  onRegionChanged: region =>
    dispatch({
      type: 'RIDE_AUTOCOMPLETE_REGION_CHANGE',
      region,
    }),

  onCancelTapped: () => {
    dispatch({ type: 'RIDE_AUTOCOMPLETE_TYPE_MODE' })
    dispatch({ type: 'RIDE_AUTOCOMPLETE_REGION_CHANGE', region: null })
  },

  getRecentAddresses: () => {
    dispatch({
      type: 'RIDE_GET_RECENT_ADDRESSES',
    })
  },

  handleAddressSelected: address =>
    dispatch({
      type: 'RIDE_SELECT_ADDRESS',
      address: {
        name: address.addr_name,
        location: {
          coordinate: address,
        },
      },
    }),
})

const AddressRow = ({ onPress, name, description }) => (
  <View style={{ backgroundColor: 'white' }}>
    <TouchableOpacity
      onPress={onPress}
      style={{
        minHeight: 44,
        flexDirection: 'row',
        padding: 12,
      }}
    >
      <Image source={PlaceIcon} style={{ marginRight: 12 }} />
      <View style={{ flex: 1 }}>
        <Text
          style={{
            color: blackColor,
            fontWeight: '500',
            marginBottom: 8,
          }}
        >
          {name}
        </Text>
        <Text style={styles.description}>{description}</Text>
      </View>
    </TouchableOpacity>
  </View>
)

export class RidePlacesAutocompleteScreen extends Component {
  state = {
    isSearchingWithMap: false,
    readyToSubmitSelectedLocation: false,
    screenName:
      this.props.searchType === 'source'
        ? 'Ride Source Change Screen'
        : 'Ride Destination Change Screen',
  }

  componentDidMount() {
    this.props.getRecentAddresses()
  }

  componentWillReceiveProps(newProps) {
    const { currentLocation } = newProps
    if (currentLocation && currentLocation.location && currentLocation.name) {
      this.setState({ readyToSubmitSelectedLocation: true })
    }
  }

  componentDidUpdate(prevProps, prevState) {
    if (
      this.state.isSearchingWithMap !== prevState.isSearchingWithMap &&
      this.state.isSearchingWithMap
    ) {
      this.handleLocationButton()
    }
  }

  componentWillUnmount() {
    this.props.onExitScreen()
    trackEvent('GenericUberEvent', 'click back', this.state.screenName)
  }

  handleOpenMapPress = () => {
    this.setState({ isSearchingWithMap: true })
    const { searchType } = this.props
    const { screenName } = this.state
    trackEvent(
      'GenericUberEvent',
      `click ${searchType} open map`,
      `${screenName}`,
    )
  }

  handleSubmitButton = Keyboard.dismiss

  handleonRegionChange = region => {
    this.setState({ readyToSubmitSelectedLocation: false })
  }

  handleOnRegionChangeComplete = region => {
    this.props.onRegionChanged(region)
  }

  handleAutoDetectCurrentLocation = () => {
    getCurrentLocation().then(({ latitude, longitude }) => {
      const region = { latitude, longitude }
      this.props.onAutoDetectLocation(region)
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

  renderRecentAddressItem = ({ item: address, index }) => {
    const { recentAddresses } = this.props
    const { screenName } = this.state
    const { searchType } = this.props
    return (
      <View key={`${address.latitude},${address.longitude}`} style={styles.row}>
        <AddressRow
          onPress={() => {
            this.props.handleAddressSelected(address)
            Keyboard.dismiss()
            trackEvent(
              'GenericUberEvent',
              `click ${searchType} recent addresses`,
              `${screenName} - ${address.addr_name}`,
            )
          }}
          name={address.addr_name}
          description={address.description}
        />
        {index !== recentAddresses.data.length - 1 ? (
          <View style={styles.separator} />
        ) : null}
      </View>
    )
  }

  renderPredictionItem = ({ item: prediction }) => {
    const { onPredictionSelected, searchType } = this.props
    const { screenName } = this.state
    return (
      <View key={prediction.location.placeId}>
        <AddressRow
          onPress={() => {
            onPredictionSelected(
              prediction,
              `click ${searchType} recent addresses`,
            )
            Keyboard.dismiss()
          }}
          name={prediction.name}
          description={prediction.detailedName}
        />
        <View style={styles.separator} />
      </View>
    )
  }

  renderPredictions = () => {
    const { predictions } = this.props
    if (predictions && predictions.status === 'loading') {
      return (
        <View style={{ backgroundColor: 'white', padding: 10 }}>
          <ActivityIndicator size="small" />
        </View>
      )
    } else if (predictions && predictions.status === 'loaded') {
      return (
        <View style={{ backgroundColor: 'white' }}>
          <FlatList
            style={{ paddingVertical: 8, backgroundColor: 'white' }}
            data={predictions.data}
            renderItem={item => this.renderPredictionItem(item)}
            keyExtractor={item => `${item.location.placeId}`}
            keyboardShouldPersistTaps={'handled'}
          />
        </View>
      )
    } else if (predictions && predictions.status === 'error') {
      return (
        <View style={{ backgroundColor: 'white' }}>
          <Text style={{ margin: 10, color: 'rgba(0, 0, 0, 0.54)' }}>{predictions.error.description}</Text>
        </View>
      )
    }

    return null
  }

  renderRecentAddresses = () => {
    const { recentAddresses, predictions } = this.props

    if (predictions && predictions.status && predictions.status !== 'idle') {
      return null
    }

    if (recentAddresses && recentAddresses.status === 'loading') {
      return (
        <View>
          <Text
            style={{
              fontWeight: '500',
              marginLeft: 10,
              marginVertical: 10,
              color: blackColor,
            }}
          >
            Recent Addresses
          </Text>
          <ActivityIndicator size="small" />
        </View>
      )
    }

    if (recentAddresses && recentAddresses.status === 'loaded') {
      return (
        <View>
          <Text
            style={{
              fontWeight: '500',
              marginLeft: 10,
              marginVertical: 10,
              color: blackColor,
            }}
          >
            Recent Addresses
          </Text>
          {recentAddresses &&
          recentAddresses.data &&
          Array.isArray(recentAddresses.data) &&
          recentAddresses.data.length > 0 ? (
            <FlatList
              style={{ paddingVertical: 8, backgroundColor: 'white' }}
              data={recentAddresses.data}
              renderItem={item => this.renderRecentAddressItem(item)}
              keyExtractor={item => `${item.latitude},${item.longitude}`}
              keyboardShouldPersistTaps={'handled'}
            />
          ) : (
            <View style={{ paddingVertical: 8, backgroundColor: 'white' }}>
              <Text style={{ margin: 10, color: 'rgba(0, 0, 0, 0.54)' }}>
                No recent address
              </Text>
            </View>
          )}
        </View>
      )
    }

    return null
  }

  render() {
    const {
      predictions,
      onPredictionSelected,
      onQueryChanged,
      currentLocation,
      onRegionChanged,
      onCancelTapped,
      searchType,
      loadSelectedAddress,
    } = this.props

    const {
      isSearchingWithMap,
      readyToSubmitSelectedLocation,
    } = this.state

    return (
      <View style={styles.container}>
        <Navigator.Config title="Find Address" />

        {loadSelectedAddress &&
        loadSelectedAddress.status === 'loading' && (
          <View
            style={[
              styles.overlayLoading,
              {
                backgroundColor: 'rgba(0,0,0,0.5)',
                alignItems: 'center',
                justifyContent: 'center',
                zIndex: 1000,
              },
            ]}
          >
            <ActivityIndicator />
          </View>
        )}

        <View
          style={{
            flexDirection: 'row',
            zIndex: 10,
          }}
        >
          <TextInput
            ref={component => (this._textInputFindAddress = component)}
            placeholder="Find Address"
            style={styles.textInput}
            clearButtonMode={!isSearchingWithMap ? 'always' : 'never'}
            onChange={onQueryChanged}
            value={currentLocation && placeDisplayName(currentLocation)}
            editable={!isSearchingWithMap}
            selectionColor="#42b549"
            returnKeyType="done"
            onSubmitEditing={this.handleSubmitButton}
          />
        </View>

        {!isSearchingWithMap && (
          <ScrollView
            style={{ flex: 1 }}
            keyboardDismissMode="on-drag"
            keyboardShouldPersistTaps={'handled'}
          >
            {searchType === 'source' ? (
              <TouchableOpacity
                style={styles.openMap}
                onPress={() => {
                  this.handleAutoDetectCurrentLocation()
                  Keyboard.dismiss()
                }}
              >
                <Image source={LocationIconTransparant} />
                <Text style={{ marginLeft: 10, color: 'rgba(0, 0, 0, 0.54)' }}>
                  Auto detect location
                </Text>
              </TouchableOpacity>
            ) : null}
            <TouchableOpacity
              style={styles.openMap}
              onPress={() => {
                this.handleOpenMapPress()
                Keyboard.dismiss()
              }}
            >
              <Image source={MapIcon} />
              <Text style={{ marginLeft: 10, color: 'rgba(0, 0, 0, 0.54)' }}>
                Open map
              </Text>
            </TouchableOpacity>

            {this.renderPredictions()}

            {this.renderRecentAddresses()}
          </ScrollView>
        )}

        {isSearchingWithMap && (
          <View style={{ flexGrow: 1 }}>
            <MapView
              ref={ref => (this.mapView = ref)}
              provider={PROVIDER_GOOGLE}
              style={{ flexGrow: 1 }}
              initialRegion={{
                latitude: currentLocation
                  ? currentLocation.location.coordinate.latitude
                  : -6.1757247,
                longitude: currentLocation
                  ? currentLocation.location.coordinate.longitude
                  : 106.8265106,
                latitudeDelta: 0.0123,
                longitudeDelta: 0.0123,
              }}
              followsUserLocation
              onRegionChange={this.handleonRegionChange}
              onRegionChangeComplete={this.handleOnRegionChangeComplete}
            />
            <View
              style={[
                styles.overlay,
                {
                  justifyContent: 'center',
                  alignItems: 'center',
                },
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
              />
            </View>

            <View style={styles.topOverlay}>
              <TouchableOpacity
                onPress={this.handleLocationButton}
                style={{ alignSelf: 'flex-end', marginRight: 8 }}
              >
                <Image source={LocationIcon} />
              </TouchableOpacity>
            </View>

            <View
              style={[
                styles.bottomOverlay,
                {
                  flexDirection: 'row',
                  height: 70,
                  justifyContent: 'flex-end',
                  alignItems: 'flex-end',
                },
              ]}
              pointerEvents="box-none"
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
                  onPress={() => {
                    this.setState({ isSearchingWithMap: false })
                    onCancelTapped()
                  }}
                  disabled={!readyToSubmitSelectedLocation}
                >
                  <Text
                    style={{
                      color: '#B4B4B4',
                      textAlign: 'center',
                      fontWeight: '500',
                      paddingVertical: 10,
                    }}
                  >
                    Cancel
                  </Text>
                </TouchableOpacity>
              </View>

              <View
                style={{
                  backgroundColor: '#ff5722',
                  borderRadius: 2,
                  margin: 5,
                  borderWidth: 1,
                  borderColor: '#ff5722',
                  flex: 7,
                }}
              >
                <TouchableOpacity
                  onPress={() => {
                    onPredictionSelected(
                      currentLocation,
                      `click done on ${searchType} map`,
                    )
                  }}
                  disabled={!readyToSubmitSelectedLocation}
                >
                  {!readyToSubmitSelectedLocation ? (
                    <View style={{ paddingBottom: 8, paddingTop: 9 }}>
                      <ActivityIndicator size="small" color="white" />
                    </View>
                  ) : (
                    <Text
                      style={{
                        color: 'white',
                        textAlign: 'center',
                        fontWeight: '500',
                        paddingVertical: 10,
                      }}
                    >
                      Done
                    </Text>
                  )}
                </TouchableOpacity>
              </View>
            </View>
          </View>
        )}
      </View>
    )
  }
}

export default connect(mapStateToProps, mapDispatchToProps)(
  RidePlacesAutocompleteScreen,
)
