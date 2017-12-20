// @flow

import React from 'react'
import {
  View,
  Text,
  StyleSheet,
  Image,
  ActivityIndicator,
  TouchableOpacity,
} from 'react-native'
import Dash from 'react-native-dash'
import Navigator from 'native-navigation'
import { ReactInteractionHelper } from 'NativeModules'
import SafeAreaView from 'react-native-safe-area-view'

import { getPendingFare, payPendingfare } from '../Services/api'
import { rupiahFormat } from '../Lib/RideHelper'

import NoResult from '../../unify/NoResult'

import IconUnpaid from '../Resources/icon-unpaid.png'
import SourceIcon from '../Resources/ride-source.png'
import DestinationIcon from '../Resources/ride-destination.png'

const styles = StyleSheet.create({
  container: {
    flex: 1,
    padding: 10,
  },
  headerImageContainer: {
    justifyContent: 'center',
    alignItems: 'center',
  },
  headerImage: {
    aspectRatio: 1.5,
  },
  tripId: {
    textAlign: 'center',
    fontSize: 12,
    fontWeight: 'bold',
    margin: 5,
  },
  date: {
    textAlign: 'center',
    fontSize: 11,
    color: 'rgba(0, 0, 0, 0.38)',
    margin: 5,
  },
  tripContainer: {
    flexDirection: 'row',
    marginTop: 16,
    marginBottom: 16,
    paddingHorizontal: 10,
  },
  locationPointer: {
    width: 14,
    height: 14,
  },
  thinBorder: {
    borderBottomWidth: 1,
    borderColor: 'rgba(0,0,0,0.12)',
    height: 1,
    width: '100%',
  },
  dash: {
    width: 1,
    flex: 1,
    flexDirection: 'column',
  },
  horizontalDash: {
    flex: 1,
  },
  paymentContainer: {
    padding: 16,
  },
  mutedText: {
    color: 'rgba(0,0,0,0.7)',
  },
  buttonContainer: {
    flex: 1,
    margin: 10,
  },
  button: {
    justifyContent: 'center',
    alignItems: 'center',
    backgroundColor: '#ff5722',
    borderRadius: 3,
    height: 50,
  },
})

class RidePendingFareScreen extends React.Component {
  constructor(props) {
    super(props)
    this.state = {
      data: null,
      isLoadingGetPendingFare: true,
      error: null,
      isLoadingPayPendingFare: false,
    }
  }

  componentDidMount() {
    this.getPendingFare()
  }

  getPendingFare = () => {
    this.setState({ isLoadingGetPendingFare: true })
    getPendingFare()
      .then(response => {
        if (!response.message_error && response.status === 'OK') {
          const { data } = response
          this.setState({ data, isLoadingGetPendingFare: false, error: null })
        } else {
          throw {
            code: response.data.code,
            description: response.message_error[0],
          }
        }
      })
      .catch(error => {
        this.setState({ data: null, isLoadingGetPendingFare: false, error })
        ReactInteractionHelper.showErrorStickyAlert(error.description)
      })
  }

  payPendingfare = () => {
    this.setState({ isLoadingPayPendingFare: true })
    payPendingfare()
      .then(response => {
        if (!response.message_error && response.status === 'OK') {
          Navigator.push('RidePaymentWebViewScreen', {
            data: response.data,
            title: 'Pay Pending Fare',
            url: response.data.url,
          })
          this.setState({ isLoadingPayPendingFare: false })
        }
      })
      .catch(error => {
        this.setState({ isLoadingPayPendingFare: false })
        ReactInteractionHelper.showErrorStickyAlert(error.description)
      })
  }

  navigationConfig = () => ({
    title: 'Your Last Pending Fare',
    leftButtons: [
      {
        image: { uri: 'icon_close', scale: 1.6 },
      },
    ],
    onLeftPress: () => {
      Navigator.dismiss()
    },
  })

  render() {
    const {
      data,
      isLoadingGetPendingFare,
      isLoadingPayPendingFare,
      error,
    } = this.state
    if (isLoadingGetPendingFare) {
      return (
        <Navigator.Config {...this.navigationConfig()}>
          <SafeAreaView
            style={styles.container}
            forceInset={{ top: 'never', bottom: 'always' }}
          >
            <ActivityIndicator size="small" />
          </SafeAreaView>
        </Navigator.Config>
      )
    }

    if (!data) {
      return (
        <Navigator.Config {...this.navigationConfig()}>
          <SafeAreaView forceInset={{ top: 'never', bottom: 'always' }}>
            <NoResult
              title="Oops!"
              subtitle={error.description}
              style={{ marginTop: 100 }}
              buttonTitle="Try again"
              onButtonPress={() => this.getPendingFare()}
            />
          </SafeAreaView>
        </Navigator.Config>
      )
    }

    return (
      <Navigator.Config {...this.navigationConfig()}>
        <SafeAreaView
          style={styles.container}
          forceInset={{ top: 'never', bottom: 'always' }}
        >
          <View style={styles.headerImageContainer}>
            <Image
              style={styles.headerImage}
              source={IconUnpaid}
              resizeMode={'contain'}
            />
          </View>
          <Text style={styles.tripId}>TRIP ID: {data.last_request_id}</Text>
          <Text style={styles.date}>{data.date}</Text>

          <View style={styles.tripContainer}>
            <View
              style={{
                flexDirection: 'column',
                flex: 2,
                justifyContent: 'center',
                alignItems: 'center',
              }}
            >
              <Image style={styles.locationPointer} source={SourceIcon} />
              <Dash
                style={styles.dash}
                dashColor="rgba(0,0,0,0.34)"
                dashThickness={1}
              />
              <Image style={styles.locationPointer} source={DestinationIcon} />
            </View>
            <View
              style={{
                flexDirection: 'column',
                flex: 10,
                justifyContent: 'center',
              }}
            >
              <Text style={{ marginBottom: 8 }}>
                {data.pickup_address_name}
              </Text>
              <View style={styles.thinBorder} />
              <Text style={{ marginTop: 8 }}>
                {data.destination_address_name}
              </Text>
            </View>
          </View>

          <View style={styles.paymentContainer}>
            <View
              style={{
                flexDirection: 'row',
                justifyContent: 'space-between',
              }}
            >
              <Text style={styles.mutedText}>Total Fare</Text>
              <Text>{`${rupiahFormat(data.last_ride_amount)}`}</Text>
            </View>
            <View
              style={{
                marginVertical: 12,
                flexDirection: 'row',
                justifyContent: 'space-between',
              }}
            >
              <Text style={styles.mutedText}>
                {data.last_ride_payment_method} Charged
              </Text>
              <Text>{`${rupiahFormat(data.last_ride_payment)}`}</Text>
            </View>
            <Dash
              style={styles.horizontalDash}
              dashColor="rgba(0,0,0,0.12)"
              dashThickness={1}
            />
            <View
              style={{
                marginVertical: 12,
                flexDirection: 'row',
                justifyContent: 'space-between',
              }}
            >
              <View style={{ flexDirection: 'row' }}>
                <Text>Your Pending Fare</Text>
              </View>
              <Text>{`${rupiahFormat(data.pending_amount)}`}</Text>
            </View>
            <Dash
              style={styles.horizontalDash}
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
        </SafeAreaView>
      </Navigator.Config>
    )
  }
}

export default RidePendingFareScreen
