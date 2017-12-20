// @flow

import React from 'react'
import {
  View,
  Text,
  StyleSheet,
  Image,
  TouchableOpacity,
  ActivityIndicator,
} from 'react-native'
import { connect } from 'react-redux'
import Navigator from 'native-navigation'
import { ReactInteractionHelper } from 'NativeModules'
import SafeAreaView from 'react-native-safe-area-view'

import {
  allowAutoDebitPaymentMethod,
  getTokoCashBalance,
} from '../Services/api'

import NoResult from '../../unify/NoResult'
import RideAlertDialog from '../Components/RideAlertDialog'

import IconTokocash from '../Resources/icon-tokocash.png'
import IconCheckbox from '../Resources/icon-checkbox.png'
import IconAddCC from '../Resources/icon-add-cc.png'

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: '#FFFFFF',
  },
  leftContainer: {
    flex: 8,
    flexDirection: 'row',
    alignItems: 'center',
  },
  rightContainer: {
    flex: 2,
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'flex-end',
  },
  item: {
    flexDirection: 'row',
    paddingVertical: 14,
    paddingHorizontal: 12,
  },
  itemText: {
    marginHorizontal: 8,
  },
  buttonText: {
    marginHorizontal: 8,
    color: '#42b549',
  },
  itemIcon: {
    width: 30,
    aspectRatio: 1,
  },
  itemCheckbox: {
    width: 20,
    aspectRatio: 1,
    marginHorizontal: 10,
  },
  itemSeparator: {
    backgroundColor: '#eeeeee',
    height: 1,
    marginHorizontal: 12,
  },
  textTokoCashBalance: {
    marginHorizontal: 8,
    color: 'rgba(0, 0, 0, 0.54)',
    fontSize: 11,
    lineHeight: 16,
  },
})

class RidePaymentMethodScreen extends React.Component {
  constructor(props) {
    super(props)
    this.state = {
      showPopup: false,
      saveUrl: null,
      saveData: null,
      isLoadingAllowAutoDebit: false,
      isLoadingChangeActivePayment: false,
      isLoadingTokoCash: true,
      tokoCashBalance: '',
    }
  }

  componentDidMount() {
    this.loadTokoCashbalance()
  }

  loadTokoCashbalance = () => {
    this.setState({ isLoadingTokoCash: true })
    getTokoCashBalance()
      .then(response => {
        if (response.status === 'OK') {
          this.setState({
            tokoCashBalance: response.data.balance,
            isLoadingTokoCash: false,
          })
        }
      })
      .catch(error => {
        this.setState({
          isLoadingTokoCash: false,
        })
      })
  }

  allowAutoDebitPaymentMethod = (url, data) => {
    this.setState({ isLoadingAllowAutoDebit: true })
    allowAutoDebitPaymentMethod(url, data)
      .then(response => {
        if (response.status === 'OK') {
          this.props.getPaymentMethod()
          this.setState({ showPopup: false, isLoadingAllowAutoDebit: false })
          setTimeout(() => {
            Navigator.pop()
          }, 250)
        } else {
          this.setState({ showPopup: false, isLoadingAllowAutoDebit: false })
        }
      })
      .catch(error => {
        this.setState({ showPopup: false, isLoadingAllowAutoDebit: false })
        ReactInteractionHelper.showErrorStickyAlert(error.description)
      })
  }

  changeActivePaymentMethod = (url, data) => {
    this.setState({ isLoadingChangeActivePayment: true })
    allowAutoDebitPaymentMethod(url, data)
      .then(response => {
        if (response.status === 'OK') {
          this.props.getPaymentMethod()
          this.setState({ isLoadingChangeActivePayment: false })
          setTimeout(() => {
            Navigator.pop()
          }, 250)
        } else {
          this.setState({ isLoadingChangeActivePayment: false })
        }
      })
      .catch(error => {
        this.setState({ isLoadingChangeActivePayment: false })
        ReactInteractionHelper.showErrorStickyAlert(error.description)
      })
  }

  renderItem = paymentMethod => {
    const { mode } = this.props
    const { tokoCashBalance, isLoadingTokoCash } = this.state
    return (
      <TouchableOpacity
        onPress={() => {
          if (mode === 'select-route' && paymentMethod.mode === 'cc') {
            Navigator.push('RideDetailPaymentMethodScreen', {
              paymentMethod,
              title: 'Credit Card',
            })
          } else if (
            paymentMethod.mode === 'cc' &&
            paymentMethod.save_webview
          ) {
            Navigator.push('RideDetailPaymentMethodScreen', {
              paymentMethod,
              title: 'Credit Card',
            })
          } else if (paymentMethod.allowed) {
            this.changeActivePaymentMethod(
              paymentMethod.save_url,
              paymentMethod.save_body,
            )
          } else {
            this.setState({
              showPopup: true,
              saveUrl: paymentMethod.save_url,
              saveData: paymentMethod.save_body,
            })
          }
        }}
        key={paymentMethod.label}
      >
        <View>
          <View style={styles.item}>
            <View style={styles.leftContainer}>
              {paymentMethod.mode === 'wallet' ? (
                <Image
                  source={IconTokocash}
                  style={styles.itemIcon}
                  resizeMode={'contain'}
                />
              ) : (
                <Image
                  source={{ uri: paymentMethod.image }}
                  style={styles.itemIcon}
                  resizeMode={'contain'}
                />
              )}
              <View>
                <Text style={styles.itemText}>
                  {paymentMethod.mode === 'cc' ? (
                    paymentMethod.label.slice(-8)
                  ) : (
                    paymentMethod.label
                  )}
                </Text>
                {paymentMethod.mode === 'wallet' &&
                !isLoadingTokoCash &&
                tokoCashBalance !== '' ? (
                  <Text style={styles.textTokoCashBalance}>
                    {tokoCashBalance}
                  </Text>
                ) : null}
                {paymentMethod.mode === 'wallet' && isLoadingTokoCash ? (
                  <ActivityIndicator size={'small'} />
                ) : null}
                {paymentMethod.mode === 'cc' &&
                !paymentMethod.allowed && (
                  <Text style={styles.textTokoCashBalance}>
                    Auto debit not allowed
                  </Text>
                )}
                {paymentMethod.mode === 'cc' &&
                paymentMethod.allowed && (
                  <Text style={styles.textTokoCashBalance}>
                    Auto debit allowed
                  </Text>
                )}
              </View>
            </View>
            <View style={styles.rightContainer}>
              {mode !== 'select-route' &&
              paymentMethod.active && (
                <Image source={IconCheckbox} style={styles.itemCheckbox} />
              )}
            </View>
          </View>
          <View style={styles.itemSeparator} />
        </View>
      </TouchableOpacity>
    )
  }

  renderButtonAdd = data => (
    <View>
      <TouchableOpacity
        style={styles.item}
        onPress={() =>
          Navigator.push('RidePaymentWebViewScreen', {
            url: data.save_url,
            data: data.save_body,
            title: 'Add Credit Card',
          })}
      >
        <View style={styles.leftContainer}>
          <Image source={IconAddCC} style={styles.itemIcon} />
          <Text style={styles.buttonText}>Add Credit Card</Text>
        </View>
      </TouchableOpacity>
      <View style={styles.itemSeparator} />
    </View>
  )

  render() {
    const {
      showPopup,
      saveUrl,
      saveData,
      isLoadingAllowAutoDebit,
      isLoadingChangeActivePayment,
    } = this.state
    const {
      paymentMethods,
      paymentMethodList,
      addPaymentMethod,
      title,
    } = this.props

    if (paymentMethods.status === 'loading') {
      return (
        <SafeAreaView
          style={[styles.container, { alignItems: 'center', marginTop: 10 }]}
          forceInset={{ top: 'never', bottom: 'always' }}
        >
          <ActivityIndicator size="small" />
        </SafeAreaView>
      )
    }

    if (isLoadingChangeActivePayment) {
      return (
        <SafeAreaView
          style={[styles.container, { alignItems: 'center', marginTop: 10 }]}
          forceInset={{ top: 'never', bottom: 'always' }}
        >
          <ActivityIndicator size="small" />
        </SafeAreaView>
      )
    }

    if (paymentMethodList.length <= 0) {
      return (
        <SafeAreaView
          style={[styles.container, { alignItems: 'center', marginTop: 10 }]}
          forceInset={{ top: 'never', bottom: 'always' }}
        >
          <Navigator.Config title={title} />
          <NoResult
            title="No payment"
            subtitle="No payment methods available"
            style={{ marginTop: 100 }}
            showButton={false}
          />
        </SafeAreaView>
      )
    }

    return (
      <SafeAreaView
        style={styles.container}
        forceInset={{ top: 'never', bottom: 'always' }}
      >
        <Navigator.Config title={title} />
        {paymentMethodList &&
          Array.isArray(paymentMethodList) &&
          paymentMethodList.map(paymentMethod =>
            this.renderItem(paymentMethod),
          )}
        {addPaymentMethod && this.renderButtonAdd(addPaymentMethod)}
        <RideAlertDialog
          title={'Allow Auto Debit'}
          message={
            'Please proceed to allow your to card to auto debit permission.'
          }
          visible={showPopup}
          isLoading={isLoadingAllowAutoDebit}
          negativeAction={{
            text: 'CANCEL',
            action: () => this.setState({ showPopup: false }),
          }}
          positiveAction={{
            text: 'PROCEED',
            action: () => {
              this.allowAutoDebitPaymentMethod(saveUrl, saveData)
            },
          }}
        />
      </SafeAreaView>
    )
  }
}

const mapStateToProps = state => ({
  mode: state.mode,
  paymentMethods: state.paymentMethods || null,
  addPaymentMethod:
    state.paymentMethods.data && state.paymentMethods.data.add_payment
      ? state.paymentMethods.data.add_payment
      : null,
  paymentMethodList:
    state.paymentMethods.data && state.paymentMethods.data.payment_methods
      ? state.paymentMethods.data.payment_methods
      : [],
})

const mapDispatchToProps = dispatch => ({
  getPaymentMethod: () => dispatch({ type: 'RIDE_GET_PAYMENT_METHOD' }),
})

export default connect(mapStateToProps, mapDispatchToProps)(
  RidePaymentMethodScreen,
)
