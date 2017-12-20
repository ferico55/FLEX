// @flow

import React from 'react'
import {
  View,
  StyleSheet,
  Text,
  TextInput,
  TouchableOpacity,
  AlertIOS,
} from 'react-native'
import Navigator from 'native-navigation'
import { connect } from 'react-redux'
import { ReactInteractionHelper } from 'NativeModules'
import SafeAreaView from 'react-native-safe-area-view'

import {
  deletePaymentMethod,
  allowAutoDebitPaymentMethod,
} from '../Services/api'

const styles = StyleSheet.create({
  container: {
    flex: 1,
  },
  formContainer: {
    paddingVertical: 14,
    paddingHorizontal: 12,
  },
  label: {
    color: 'rgba(0, 0, 0, 0.38)',
    fontSize: 12,
    marginVertical: 4,
  },
  textInput: {
    height: 24,
    fontSize: 16,
  },
  textInputSeparator: {
    height: 1,
    backgroundColor: '#000000',
    opacity: 0.12,
  },
  bottomOverlay: {
    position: 'absolute',
    bottom: 0,
    right: 0,
    left: 0,
  },
  btnAddCC: {
    height: 52,
    borderRadius: 2,
    margin: 10,
    justifyContent: 'center',
    alignItems: 'center',
  },
  textAddCC: {
    fontSize: 14,
    fontWeight: '500',
    textAlign: 'center',
  },
})

class RideDetailPaymentMethodScreen extends React.Component {
  constructor(props) {
    super(props)
    this.state = {
      isLoadingDelete: false,
      isLoadingAllowAutoDebit: false,
      showPopup: false,
      showDeletePopup: false,
    }
  }

  deletePaymentMethod = (url, data) => {
    this.setState({ isLoadingDelete: true })
    deletePaymentMethod(url, data)
      .then(response => {
        if (response.status === 'OK') {
          this.setState({ isLoadingDelete: false, showDeletePopup: false })
          this.props.getPaymentMethod()
          setTimeout(() => {
            Navigator.pop()
            ReactInteractionHelper.showStickyAlert('Credit card deleted.')
          }, 250)
        } else {
          this.setState({ isLoadingDelete: false, showDeletePopup: false })
          ReactInteractionHelper.showErrorStickyAlert(
            'Something went wrong, please try again.',
          )
        }
      })
      .catch(error => {
        this.setState({ isLoadingDelete: false, showDeletePopup: false })
        ReactInteractionHelper.showErrorStickyAlert(error.description)
      })
  }

  allowAutoDebitPaymentMethod = (url, data) => {
    this.setState({ isLoadingAllowAutoDebit: true })
    allowAutoDebitPaymentMethod(url, data)
      .then(response => {
        if (response.status === 'OK') {
          this.setState({ isLoadingAllowAutoDebit: false, showPopup: false })
          this.props.getPaymentMethod()
          setTimeout(() => {
            Navigator.pop()
            ReactInteractionHelper.showStickyAlert('Credit card allowed.')
          }, 250)
        } else {
          this.setState({ isLoadingAllowAutoDebit: false, showPopup: false })
          ReactInteractionHelper.showErrorStickyAlert(
            'Something went wrong, please try again.',
          )
        }
      })
      .catch(error => {
        this.setState({ isLoadingAllowAutoDebit: false, showPopup: false })
        ReactInteractionHelper.showErrorStickyAlert(error.description)
      })
  }

  render() {
    const { paymentMethod } = this.props
    return (
      <SafeAreaView
        style={styles.container}
        forceInset={{ top: 'never', bottom: 'always' }}
      >
        <Navigator.Config title="Credit Card" />
        <View style={{ flex: 8 }}>
          <View style={styles.formContainer}>
            <Text style={styles.label}>Card Number</Text>
            <TextInput
              style={styles.textInput}
              value={paymentMethod.masked_num}
              editable={false}
            />
            <View style={styles.textInputSeparator} />
          </View>
          <View style={styles.formContainer}>
            <Text style={styles.label}>Expiration Date</Text>
            <TextInput
              style={styles.textInput}
              value={`${paymentMethod.expiry_year}/${paymentMethod.expiry_month}`}
              editable={false}
            />
            <View style={styles.textInputSeparator} />
          </View>
        </View>
        <View
          style={{
            backgroundColor: '#FFFFFF',
            flex: 4,
            justifyContent: 'flex-end',
          }}
        >
          {!paymentMethod.allowed && (
            <TouchableOpacity
              style={[
                styles.btnAddCC,
                {
                  backgroundColor: '#F9F9F9',
                  borderColor: '#C5C5C5',
                  borderWidth: 1,
                  marginBottom: 0,
                },
              ]}
              onPress={() => {
                if (paymentMethod.save_webview) {
                  Navigator.push('RidePaymentWebViewScreen', {
                    url: paymentMethod.save_url,
                    data: paymentMethod.save_body,
                    title: 'Allow Auto Debit',
                  })
                } else {
                  this.setState({ showPopup: true })
                  AlertIOS.alert(
                    'Allow Auto Debit',
                    'Please proceed to allow your to card to auto debit permission.',
                    [
                      {
                        text: 'Cancel',
                        style: 'default',
                      },
                      {
                        text: 'Proceed',
                        onPress: () => {
                          this.allowAutoDebitPaymentMethod(
                            paymentMethod.save_url,
                            paymentMethod.save_body,
                          )
                        },
                        style: 'default',
                      },
                    ],
                  )
                }
              }}
            >
              <Text style={[styles.textAddCC, { color: '#6D6D6D' }]}>
                ALLOW AUTO DEBIT
              </Text>
            </TouchableOpacity>
          )}
          <TouchableOpacity
            style={[styles.btnAddCC, { backgroundColor: '#F14D28' }]}
            onPress={() => {
              this.setState({ showDeletePopup: true })
              AlertIOS.alert(
                'Delete Credit Card',
                'Are you sure you want to delete this card?',
                [
                  {
                    text: 'Cancel',
                    style: 'default',
                  },
                  {
                    text: 'Delete',
                    onPress: () => {
                      this.deletePaymentMethod(
                        paymentMethod.delete_url,
                        paymentMethod.remove_body,
                      )
                    },
                    style: 'destructive',
                  },
                ],
              )
            }}
          >
            <Text style={[styles.textAddCC, { color: '#FFFFFF' }]}>Delete</Text>
          </TouchableOpacity>
        </View>
      </SafeAreaView>
    )
  }
}

const mapDispatchToProps = dispatch => ({
  getPaymentMethod: () => dispatch({ type: 'RIDE_GET_PAYMENT_METHOD' }),
})

export default connect(null, mapDispatchToProps)(RideDetailPaymentMethodScreen)
