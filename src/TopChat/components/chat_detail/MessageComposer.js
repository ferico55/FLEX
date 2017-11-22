/* @flow */

import React, { Component } from 'react'
import {
  View,
  StyleSheet,
  Image,
  TextInput,
  TouchableOpacity,
} from 'react-native'

import attachProduct from '@img/attachProduct.png'
import sendButton from '@img/sendButton.png'

export default class MessageComposer extends Component {
  constructor(props) {
    super(props)
    this.state = {
      messageText: '',
    }
  }

  onChangeText = messageText => {
    if (this.props.onChangeText) {
      this.props.onChangeText(messageText)
    }

    this.setState({
      messageText,
    })
  }

  onPressSend = () => {
    if (this.props.onPressSend) {
      this.props.onPressSend(this.state.messageText)
    }

    this.setState({
      messageText: '',
    })
  }

  onPressAttachment = () => {
    if (this.props.onPressAttachment) {
      this.props.onPressAttachment()
    }
  }

  render() {
    return (
      <View
        style={{ flex: 1, flexDirection: 'row', backgroundColor: 'white' }}
        onLayout={this.props.onLayoutComposer}
      >
        <TouchableOpacity
          style={styles.attachButtonWrapper}
          onPress={this.onPressAttachment}
          disabled={!this.props.connectedToWS}
        >
          <Image
            source={attachProduct}
            style={{ width: 17, height: 17, tintColor: '#666666' }}
            resizeMode={'contain'}
          />
        </TouchableOpacity>
        <View style={styles.inputWrapper}>
          <TextInput
            style={styles.textInput}
            placeholder={'Tulis Pesan...'}
            onChangeText={this.onChangeText}
            value={this.state.messageText}
            multiline
          />
        </View>
        <TouchableOpacity
          style={styles.sendButtonWrapper}
          onPress={this.onPressSend}
          disabled={!this.props.connectedToWS}
        >
          <Image
            source={sendButton}
            style={{
              width: 25,
              height: 21,
              tintColor: this.props.connectedToWS ? 'rgb(66,181,73)' : 'silver',
            }}
            resizeMode={'contain'}
          />
        </TouchableOpacity>
      </View>
    )
  }
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
  },
  attachButtonWrapper: {
    flex: 0.15,
    alignItems: 'center',
    justifyContent: 'flex-end',
    paddingBottom: 12,
  },
  inputWrapper: {
    flex: 0.7,
    paddingVertical: 5,
    minHeight: 40,
    maxHeight: 80,
    justifyContent: 'center',
  },
  textInput: {
    justifyContent: 'center',
    alignItems: 'center',
    backgroundColor: 'white',
    fontSize: 14,
    paddingBottom: 4,
  },
  sendButtonWrapper: {
    flex: 0.15,
    alignItems: 'center',
    justifyContent: 'flex-end',
    paddingBottom: 10,
  },
})
