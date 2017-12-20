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
import { INPUT_MAX_HEIGHT, INPUT_MIN_HEIGHT } from '@TopChatHelpers/Constants'

export default class MessageComposer extends Component {
  constructor(props) {
    super(props)
    this.state = {
      messageText: props.messageText,
    }
  }

  onChangeText = messageText => {
    if (this.props.onChangeText) {
      this.props.onChangeText(messageText)
    }
  }

  onPressSend = () => {
    if (this.props.onPressSend) {
      this.props.onPressSend(this.state.messageText)
    }
  }

  onPressAttachment = () => {
    if (this.props.onPressAttachment) {
      this.props.onPressAttachment()
    }
  }

  componentWillReceiveProps = nextProps => {
    this.setState({
      messageText: nextProps.messageText,
    })
  }

  render() {
    return (
      <View
        style={{
          flex: 1,
          flexDirection: 'row',
          backgroundColor: 'white',
          paddingVertical: 8,
        }}
        onLayout={this.props.onLayoutComposer}
      >
        <View style={styles.buttonWrapper}>
          <View
            style={{
              height: INPUT_MIN_HEIGHT,
              justifyContent: 'center',
              alignItems: 'center',
            }}
          >
            <TouchableOpacity
              onPress={this.onPressAttachment}
              disabled={!this.props.connectedToWS}
            >
              <Image
                source={attachProduct}
                style={{ width: 17, height: 17, tintColor: '#666666' }}
                resizeMode={'contain'}
              />
            </TouchableOpacity>
          </View>
        </View>
        <View style={styles.inputWrapper}>
          <TextInput
            style={styles.textInput}
            placeholder={'Tulis Pesan...'}
            onChangeText={this.onChangeText}
            value={this.state.messageText}
            multiline
          />
        </View>
        <View style={styles.buttonWrapper}>
          <View
            style={{
              height: INPUT_MIN_HEIGHT,
              justifyContent: 'center',
              alignItems: 'center',
            }}
          >
            <TouchableOpacity
              onPress={this.onPressSend}
              disabled={!this.props.connectedToWS}
            >
              <Image
                source={sendButton}
                style={{
                  width: 25,
                  height: 21,
                  tintColor: this.props.connectedToWS
                    ? 'rgb(66,181,73)'
                    : 'silver',
                }}
                resizeMode={'contain'}
              />
            </TouchableOpacity>
          </View>
        </View>
      </View>
    )
  }
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
  },
  buttonWrapper: {
    flex: 0.15,
    justifyContent: 'flex-end',
  },
  attachButtonWrapper: {
    flex: 0.15,
    alignItems: 'center',
    justifyContent: 'center',
    backgroundColor: 'pink',
    height: INPUT_MIN_HEIGHT,
  },
  inputWrapper: {
    flex: 0.7,
    minHeight: INPUT_MIN_HEIGHT,
    maxHeight: INPUT_MAX_HEIGHT,
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
    justifyContent: 'center',
    backgroundColor: 'blue',
    height: INPUT_MIN_HEIGHT,
  },
})
