import React, { PureComponent } from 'react'
import {
  Text,
  View,
  TextInput,
  StyleSheet,
  Keyboard,
  TouchableOpacity,
} from 'react-native'
import PropTypes from 'prop-types'
import { Loading } from '@TopChat/components'
import DeviceInfo from 'react-native-device-info'

const styles = StyleSheet.create({
  container: {
    flex: 1,
  },
  textAreaWrapper: {
    padding: 16,
  },
  textArea: {
    flex: 1,
    fontSize: 16,
    color: 'rgba(0,0,0,0.7)',
  },
  textCounterWrapper: {
    flex: 1,
    flexDirection: 'column',
  },
  textCounter: {
    fontSize: 12,
    color: 'rgba(0,0,0,0.38)',
  },
  buttonDisable: {
    height: 40,
    paddingHorizontal: 16,
    backgroundColor: 'rgb(224,224,224)',
    borderRadius: 3,
    alignItems: 'center',
    justifyContent: 'center',
  },
  buttonEnable: {
    height: 40,
    paddingHorizontal: 16,
    backgroundColor: 'rgb(66,181,73)',
    borderRadius: 3,
    alignItems: 'center',
    justifyContent: 'center',
  },
  textEnable: {
    fontSize: 14,
    color: 'rgb(255,255,255)',
  },
  textDisable: {
    fontSize: 14,
    color: 'rgba(0,0,0,0.26)',
  },
})

const BOTTOM_WRAPPER_HEIGHT = 60

class TextArea extends PureComponent {
  constructor(props) {
    super(props)
    this.state = {
      messageText: props.messageText,
      textCount: 0,
      loading: true,
      containerHeight: 0,
      originalHeight: 0,
      keyboardVerticalOffset: 0,
      bottomOffset: 0,
      setContainerHeight: false,
    }
  }

  componentWillMount() {
    this.keyboardDidShowListener = Keyboard.addListener(
      'keyboardDidShow',
      this.keyboardDidShow,
    )

    this.keyboardDidHideListener = Keyboard.addListener(
      'keyboardDidHide',
      () => {
        this.setState({
          bottomOffset: 0,
          containerHeight: this.state.originalHeight,
        })
      },
    )
  }

  componentWillReceiveProps = ({ messageText }) => {
    this.setState({
      messageText,
      textCount: messageText.length,
    })
  }

  componentWillUnmount() {
    this.keyboardDidShowListener.remove()
    this.keyboardDidHideListener.remove()
  }

  keyboardDidShow = ({ endCoordinates: { height } }) => {
    if (DeviceInfo.isTablet()) {
      this.setState({
        bottomOffset: 120,
        containerHeight: this.state.originalHeight + BOTTOM_WRAPPER_HEIGHT - 120 - 58,
      })
    } else {
      this.setState({
        bottomOffset: height,
        containerHeight: this.state.originalHeight + BOTTOM_WRAPPER_HEIGHT - height - 58, // 58 from height of absolute view (60 - 10) + 8 as bottomoffset is add 8 point
      })
    }
  }

  handleChangeText = messageText => {
    if (this.props.onChangeText) {
      this.props.onChangeText(messageText)
    } else {
      this.setState({ textCount: messageText.length, messageText })
    }
  }

  handleOnLayout = ({ nativeEvent }) => {
    if (nativeEvent.layout.height !== 0) {
      if (this.props.onLayoutContainer) {
        this.props.onLayoutContainer(nativeEvent.layout.height)
      }

      this.setState({
        containerHeight: nativeEvent.layout.height - BOTTOM_WRAPPER_HEIGHT,
        originalHeight: nativeEvent.layout.height - BOTTOM_WRAPPER_HEIGHT,
        loading: false,
      })
    }
  }

  handlePress = () => {
    if (this.state.messageText.length <= 4) {
      this.setState({
        showError: 'Template pesan minimal 5 karakter',
      })
    } else {
      this.setState(
        {
          showError: '',
        },
        () => {
          if (this.props.onPressSaveButton) {
            this.props.onPressSaveButton()
          }
        },
      )
    }
  }

  renderButton = () => {
    if (
      this.state.messageText.length > 0 &&
      this.state.messageText.trim() !== ''
    ) {
      return (
        <TouchableOpacity
          style={styles.buttonEnable}
          onPress={this.handlePress}
        >
          <Text style={styles.textEnable}>Simpan</Text>
        </TouchableOpacity>
      )
    }

    return (
      <TouchableOpacity style={styles.buttonDisable} disabled>
        <Text style={styles.textDisable}>Simpan</Text>
      </TouchableOpacity>
    )
  }

  render() {
    if (this.state.loading) {
      return (
        <View style={{ flex: 1 }} onLayout={this.handleOnLayout}>
          <Loading />
        </View>
      )
    }

    return (
      <View
        style={[styles.container, this.props.containerStyle]}
        onLayout={this.handleOnLayout}
      >
        <View
          style={[
            styles.textAreaWrapper,
            { height: this.state.containerHeight },
            this.props.textAreaContainerStyle,
          ]}
        >
          <TextInput
            style={[styles.textArea, this.props.textAreaStyle]}
            onChangeText={this.handleChangeText}
            value={this.state.messageText}
            multiline={this.props.multiline}
            {...this.props.textInputProps}
          />
        </View>
        <View style={styles.textCounterWrapper}>
          <View
            style={{
              position: 'absolute',
              bottom:
                this.state.bottomOffset === 0
                  ? 16
                  : this.state.bottomOffset + 8,
              right: 0,
              left: 0,
              marginHorizontal: 16,
              height: BOTTOM_WRAPPER_HEIGHT,
            }}
          >
            <View style={{ flex: 1, flexDirection: 'row' }}>
              <View
                style={{
                  alignItems: 'flex-start',
                  justifyContent: 'flex-start',
                  height: 20,
                }}
              >
                <Text style={{ fontSize: 12, color: 'rgb(213,0,0)' }}>
                  {this.state.showError}
                </Text>
              </View>
              <View
                style={{
                  flex: 1,
                  alignItems: 'flex-end',
                  justifyContent: 'flex-start',
                  height: 20,
                }}
              >
                <Text style={styles.textCounter}>
                  {this.state.textCount} / {this.props.textInputProps.maxLength}
                </Text>
              </View>
            </View>
            {this.renderButton()}
          </View>
        </View>
      </View>
    )
  }
}

TextArea.defaultProps = {
  messageText: '',
  multiline: true,
  textInputProps: {
    maxLength: 500,
    minLength: 1,
    placeholder: 'Ketik disini...',
    autoFocus: false,
  },
  containerStyle: {},
  textAreaStyle: {},
  textAreaContainerStyle: {},
}

TextArea.propTypes = {
  onChangeText: PropTypes.func.isRequired,
  containerStyle: PropTypes.object,
  textAreaStyle: PropTypes.object,
  textAreaContainerStyle: PropTypes.object,
  messageText: PropTypes.string,
  multiline: PropTypes.bool,
  textInputProps: PropTypes.shape({
    maxLength: PropTypes.number.isRequired,
    minLength: PropTypes.number.isRequired,
    placeholder: PropTypes.string,
  }),
}

export default TextArea
