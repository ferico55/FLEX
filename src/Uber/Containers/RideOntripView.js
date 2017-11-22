// @flow

import React from 'react'
import {
  View,
  Text,
  Image,
  StyleSheet,
  TouchableOpacity,
  Linking,
  Alert,
  ActivityIndicator,
  Share,
} from 'react-native'
import { connect } from 'react-redux'
import { ReactInteractionHelper } from 'NativeModules'

import { trackEvent } from '../Lib/RideHelper'

import IconMessage from '../Resources/icon-message.png'
import IconPhone from '../Resources/icon-phone.png'
import CancelIcon from '../Resources/icon-cancel.png'

const styles = StyleSheet.create({
  shadow: {
    shadowColor: 'black',
    shadowRadius: 1,
    shadowOpacity: 0.3,
    shadowOffset: { width: 0, height: 0 },
  },
})

class RideOntripView extends React.Component {
  constructor(props) {
    super(props)
  }

  render() {
    const {
      currentTrip,
      screenName,
      loadShareUrlTrip,
      onCancelButtonTap,
    } = this.props
    return (
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
              <Text style={{ color: 'rgba(0, 0, 0, 0.54)', fontSize: 11 }}>
                {currentTrip.data.driver.rating}
              </Text>
            </View>
          </View>

          <View style={{ flex: 1, marginLeft: 10 }}>
            <Text style={{ fontWeight: '500', marginBottom: 5 }}>
              {currentTrip.data.driver.name}
            </Text>
            <Text style={{ color: 'rgba(0,0,0,0.54)' }}>
              {`${currentTrip.data.vehicle.make} ${currentTrip.data.vehicle
                .model}`}
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
                  const url = `sms:${currentTrip.data.driver.phone_number}`

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
                  const url = `tel:${currentTrip.data.driver.phone_number}`

                  Linking.canOpenURL(url).then(canOpen => {
                    if (canOpen) {
                      Linking.openURL(url)
                    } else {
                      Alert.alert('Phone call not supported on this device')
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
              Share.share({
                message: '',
                url: loadShareUrlTrip.url,
                title: `Follow my Uber trip`,
              })
              trackEvent('GenericUberEvent', 'click share eta', screenName)
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
                  onCancelButtonTap()
                  trackEvent('GenericUberEvent', 'click cancel', screenName)
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
                <Text style={{ marginLeft: 5, color: 'rgba(0, 0, 0, 0.54)' }}>
                  Cancel
                </Text>
              </TouchableOpacity>,
            ]
          ) : null}
        </View>
      </View>
    )
  }
}

const mapStateToProps = state => ({
  ...state,
})

export default connect(mapStateToProps, null)(RideOntripView)
