// @flow

import React from 'react'
import {
  Modal,
  View,
  Text,
  TouchableOpacity,
  ActivityIndicator,
  StyleSheet,
} from 'react-native'

const styles = StyleSheet.create({
  overlay: {
    position: 'absolute',
    top: 0,
    left: 0,
    right: 0,
    bottom: 0,
  },
  popupConfirm: {
    backgroundColor: '#FFFFFF',
    marginHorizontal: 30,
    borderRadius: 3,
  },
  popupConfirmTitle: {
    textAlign: 'center',
    margin: 10,
    fontSize: 14,
    fontWeight: 'bold',
  },
  popupConfirmDesc: {
    margin: 10,
    fontSize: 14,
  },
  popupConfirmButtonContainer: {
    flexDirection: 'row',
    margin: 10,
  },
  btn: {
    height: 52,
    borderRadius: 2,
    justifyContent: 'center',
    alignItems: 'center',
  },
})

export default class RideAlertDialog extends React.Component {
  render() {
    const {
      visible,
      negativeAction,
      positiveAction,
      isLoading,
      title,
      message,
    } = this.props
    return (
      <Modal visible={visible} transparent>
        <View
          style={[
            styles.overlay,
            {
              justifyContent: 'center',
              alignItems: 'center',
              backgroundColor: 'rgba(0,0,0,0.5)',
              elevation: 5,
              zIndex: 1000,
            },
          ]}
          pointerEvents="box-none"
        >
          <View style={styles.popupConfirm}>
            <Text style={styles.popupConfirmTitle}>{title}</Text>
            <Text style={styles.popupConfirmDesc}>{message}</Text>
            <View style={styles.popupConfirmButtonContainer}>
              <TouchableOpacity
                style={[
                  styles.btn,
                  {
                    backgroundColor: '#F9F9F9',
                    borderColor: '#C5C5C5',
                    borderWidth: 1,
                    marginBottom: 0,
                    marginRight: 5,
                    flex: 1,
                  },
                ]}
                onPress={negativeAction.action}
                disabled={isLoading}
              >
                <Text>{negativeAction.text}</Text>
              </TouchableOpacity>
              <TouchableOpacity
                style={[
                  styles.btn,
                  {
                    backgroundColor: '#F14D28',
                    borderColor: '#F14D28',
                    borderWidth: 1,
                    marginBottom: 0,
                    flex: 1,
                    marginLeft: 5,
                  },
                ]}
                onPress={positiveAction.action}
                disabled={isLoading}
              >
                {isLoading ? (
                  <ActivityIndicator size={'small'} />
                ) : (
                  <Text style={{ color: '#FFFFFF' }}>{positiveAction.text}</Text>
                )}
              </TouchableOpacity>
            </View>
          </View>
        </View>
      </Modal>
    )
  }
}
