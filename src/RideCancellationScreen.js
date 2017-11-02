// @flow
import React, { Component } from 'react'
import {
  View,
  Text,
  StyleSheet,
  ActivityIndicator,
  TouchableOpacity,
  Button,
} from 'react-native'

import { connect } from 'react-redux'
import Navigator from 'native-navigation'
import { Observable, Subject } from 'rxjs'
import NoResult from './unify/NoResult'

import { getCancellationReasons } from './api'
import { trackEvent } from './RideHelper'

const styles = StyleSheet.create({
  container: {
    flex: 1,
  },
  buttonEnabled: {
    backgroundColor: '#42b549',
    margin: 8,
    borderRadius: 3,
    borderColor: '#42b549',
    borderWidth: 1,
  },
  buttonDisabled: {
    backgroundColor: '#e6e6e6',
    margin: 8,
    borderRadius: 3,
    borderColor: '#e6e6e6',
    borderWidth: 1,
  },
  separator: {
    backgroundColor: '#e6e6e6',
    height: 1,
  },
  error: {
    color: 'red',
    textAlign: 'center',
    marginTop: 5,
  },
  cancellationFee: {
    textAlign: 'center',
    marginVertical: 8,
  },
})

export class RideCancellationScreen extends Component {
  state = {
    loadReasonProgress: { status: 'loading' },
    screenName: 'Ride Cancel Reason Screen',
  }

  componentDidMount() {
    this._loadReasonsSubscription = this._loadReasons$
      .do(() => this.setState({ loadReasonProgress: { status: 'loading' } }))
      .switchMap(() =>
        Observable.from(getCancellationReasons())
          .do({
            next: reasons =>
              this.setState({
                reasons,
                loadReasonProgress: { status: 'loaded' },
              }),
            error: error =>
              this.setState({ loadReasonProgress: { status: 'error', error } }),
          })
          .catch(() => Observable.empty()),
      )
      .subscribe()

    this._timerSubscription = Observable.interval(3000).subscribe(() =>
      this.setState({}),
    )

    this._loadReasons()
  }

  componentWillUnmount() {
    this._timerSubscription.unsubscribe()
    this._loadReasonsSubscription.unsubscribe()
    trackEvent('GenericUberEvent', 'click back', this.state.screenName)
  }

  _loadReasons$ = new Subject()

  _onSubmitPress = () =>
    this.props.submitCancellation(this.state.selectedReason)

  _loadReasons = () => {
    this._loadReasons$.next()
  }

  _renderContent = () => {
    const {
      loadReasonProgress,
      reasons,
      selectedReason,
      screenName,
    } = this.state

    const {
      submitCancellation,
      cancellationProgress,
      cancelGracePeriod,
      selectedProduct,
    } = this.props

    const buttonStyle = selectedReason
      ? styles.buttonEnabled
      : styles.buttonDisabled
    const isButtonDisabled =
      !selectedReason || cancellationProgress.status == 'loading'
    const showCancellationFee = cancelGracePeriod < Date.now()
    const cancellationFee =
      selectedProduct &&
      `${selectedProduct.price_details.currency_code} ${selectedProduct
        .price_details.cancellation_fee}`

    if (loadReasonProgress.status == 'loading') {
      return (
        <View style={{ flex: 1, justifyContent: 'center' }}>
          <ActivityIndicator />
        </View>
      )
    }

    if (loadReasonProgress.status == 'error') {
      return (
        <NoResult
          title={loadReasonProgress.error.description}
          subtitle="Please try again"
          buttonTitle="Try again"
          onButtonPress={this._loadReasons}
          style={{ marginTop: 60 }}
        />
      )
    }

    return (
      <View style={{ flex: 1 }}>
        {showCancellationFee ? (
          <Text style={styles.cancellationFee}>
            Cancellation Fee:{' '}
            <Text style={{ color: 'red' }}>{cancellationFee}</Text>
          </Text>
        ) : null}
        <Text style={{ marginHorizontal: 8, marginTop: 8, color: '#606060' }}>
          Why are you cancelling?
        </Text>

        {reasons.map(reason => [
          <TouchableOpacity
            key={reason}
            style={{
              height: 51.5,
              justifyContent: 'center',
              marginHorizontal: 8,
            }}
            onPress={() => this.setState({ selectedReason: reason })}
          >
            <Text
              style={{
                color: selectedReason == reason ? '#42b549' : '#ababab',
                fontWeight: '500',
              }}
            >
              {reason}
            </Text>
          </TouchableOpacity>,
          <View
            style={{
              height: 1,
              backgroundColor: '#ababab',
              marginHorizontal: 8,
            }}
          />,
        ])}
        <View style={{ flex: 1 }} />

        <View style={styles.separator} />

        {cancellationProgress.status == 'error' ? (
          <Text style={styles.error}>
            {cancellationProgress.error.description}
          </Text>
        ) : null}

        <TouchableOpacity
          style={[
            buttonStyle,
            { flexDirection: 'row', justifyContent: 'center' },
          ]}
          disabled={isButtonDisabled}
          onPress={() => {
            this._onSubmitPress()
            trackEvent(
              'GenericUberEvent',
              'click cancel request ride',
              `${screenName} - ${selectedReason}`,
            )
          }}
        >
          <Text style={{ color: 'white', fontSize: 15, margin: 10 }}>
            Submit
          </Text>
          {cancellationProgress.status === 'loading' ? (
            <ActivityIndicator
              color="white"
              style={{ position: 'absolute', right: 8, top: 8, bottom: 8 }}
            />
          ) : null}
        </TouchableOpacity>
      </View>
    )
  }

  render() {
    const { loadReasonProgress, reasons, selectedReason } = this.state

    const {
      submitCancellation,
      cancellationProgress,
      cancelGracePeriod,
      selectedProduct,
    } = this.props

    const buttonStyle = selectedReason
      ? styles.buttonEnabled
      : styles.buttonDisabled
    const isButtonDisabled =
      !selectedReason || cancellationProgress.status == 'loading'
    const showCancellationFee = cancelGracePeriod < Date.now()
    const cancellationFee =
      selectedProduct &&
      `${selectedProduct.price_details.currency_code} ${selectedProduct
        .price_details.cancellation_fee}`

    return (
      <View style={styles.container}>
        <Navigator.Config title="Cancellation Reason" />
        {this._renderContent()}
      </View>
    )
  }
}

const expiryTime = dateString => {
  if (!dateString) {
    return Date.UTC(3000)
  }

  const [datePart, hourPart] = dateString.split(' ')
  const [year, month, day] = datePart.split('-')
  const [hour, minute, second] = hourPart.split(':')
  const milliseconds = Date.UTC(year, month - 1, day, hour - 7, minute, second)

  return milliseconds
}

const mapStateToProps = state => ({
  cancellationProgress: state.cancellationProgress,
  cancelGracePeriod: expiryTime(
    state.currentTrip && state.currentTrip.data.cancel_grace_period,
  ),
  selectedProduct: state.products.find(
    product => product.product_id == state.selectedProductId,
  ),
})

const mapDispatchToProps = dispatch => ({
  submitCancellation: reason =>
    dispatch({ type: 'RIDE_CANCEL_BOOKING', reason }),
})

export default connect(mapStateToProps, mapDispatchToProps)(
  RideCancellationScreen,
)
