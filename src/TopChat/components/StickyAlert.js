/* @flow */

import React, { Component } from 'react'
import {
  View,
  Text,
  StyleSheet,
  Animated,
  TouchableOpacity,
  Image,
  ActivityIndicator,
} from 'react-native'
import PropTypes from 'prop-types'
import refresh from '@img/refresh.png'
import buttonDismiss from '@img/buttonDismiss.png'

const styles = StyleSheet.create({
  success: {
    backgroundColor: 'rgb(66,181,73)',
  },
  error: {
    backgroundColor: 'rgb(255,59,48)',
  },
})

class SticykAlert extends Component {
  constructor(props) {
    super(props)
    this.state = {
      loading: false,
      success: false,
      failed: false,
      showOnChangeProps: false,
      show: props.show,
    }
    this.top = new Animated.Value(props.hiddenOffset)
  }

  renderAction = () => {
    if (this.props.showLoading && this.props.msg !== 'Terhubung') {
      return (
        <ActivityIndicator
          animating
          size={'small'}
          color={'white'}
          style={{ marginRight: 10 }}
        />
      )
    }

    if (this.props.onPress === '') {
      return null
    }

    let imageProps = {
      source: buttonDismiss,
      style: { width: 17, height: 17 },
      resizeMode: 'contain',
    }

    if (this.props.async && !this.state.success && !this.state.loading) {
      imageProps = {
        ...imageProps,
        source: refresh,
        style: { width: 18, height: 18 },
      }
    } else if (this.props.async && !this.state.success && this.state.loading) {
      return null
    }

    return (
      <TouchableOpacity onPress={this.onPress}>
        <Image {...imageProps} />
      </TouchableOpacity>
    )
  }

  componentWillReceiveProps(nextProps) {
    if (
      this.props.show === true &&
      nextProps.show === false &&
      this.props.listenOnChangeProps
    ) {
      Animated.spring(this.top, {
        toValue: this.props.hiddenOffset,
        bounciness: 0,
        delay: 1500,
        duration: 250,
      }).start()
    } else {
      this.setState({ show: nextProps.show }, () => {
        Animated.spring(this.top, {
          toValue: this.props.top,
          bounciness: 0,
          duration: 500,
        }).start()
      })
    }
  }

  onPress = () => {
    if (this.props.onPress) {
      const isPromise = this.props.onPress()
      if (
        isPromise instanceof Promise &&
        !this.state.success &&
        this.props.async
      ) {
        this.setState({ loading: true }, () => {
          isPromise
            .then(res => {
              if (res) {
                this.setState({
                  loading: false,
                  success: true,
                })
              }
            })
            .catch(err => {
              this.setState({
                loading: false,
                success: false,
                failed: true,
              })
            })
        })
      } else {
        Animated.spring(this.top, {
          toValue: this.props.hiddenOffset,
          bounciness: 0,
          duration: 250,
        }).start(() => {
          this.setState({
            success: false,
            failed: false,
          })
        })
      }
    }
  }

  renderText = () => {
    let msg = this.props.msg
    if (this.props.async && this.state.success) {
      msg = this.props.asyncSuccessMsg
    } else if (this.props.async && this.state.failed) {
      msg = this.props.asyncFailedMsg
    }

    return <Text style={{ fontSize: 13, color: 'white' }}>{msg}</Text>
  }

  renderLoading = () => {
    if (this.props.async && this.state.loading) {
      return (
        <ActivityIndicator
          animating
          size={'small'}
          color={'white'}
          style={{ marginRight: 10 }}
        />
      )
    }

    return null
  }

  backgroundColor = () => {
    if (this.props.async) {
      if (this.state.success) {
        return {
          ...StyleSheet.flatten([styles.success]),
        }
      }
      return {
        ...StyleSheet.flatten([styles.error]),
      }
    }

    return {
      ...StyleSheet.flatten([styles[this.props.alertType]]),
    }
  }

  render() {
    if (!this.state.show) {
      return null
    }

    return (
      <Animated.View
        style={[
          {
            position: 'absolute',
            top: this.top,
            left: 0,
            right: 0,
            height: this.props.height,
          },
          {
            ...this.backgroundColor(),
          },
        ]}
      >
        <View
          style={{
            flex: 1,
            flexDirection: 'row',
            alignItems: 'center',
            padding: 15,
          }}
        >
          <View style={{ flexDirection: 'row' }}>
            {this.renderLoading()}
            {this.renderText()}
          </View>
          <View style={{ flex: 1, alignItems: 'flex-end' }}>
            {this.renderAction()}
          </View>
        </View>
      </Animated.View>
    )
  }
}

SticykAlert.propTypes = {
  show: PropTypes.bool.isRequired,
  async: PropTypes.bool,
  top: PropTypes.number,
  height: PropTypes.number,
  hiddenOffset: PropTypes.number,
  msg: PropTypes.string.isRequired,
  listenOnChangeProps: PropTypes.bool,
  asyncSuccessMsg: PropTypes.string,
  asyncFailedMsg: PropTypes.string,
  alertType: PropTypes.string,
  onPress: PropTypes.oneOfType([PropTypes.func, PropTypes.string]),
}

SticykAlert.defaultProps = {
  show: false,
  async: false,
  top: 0,
  height: 50,
  hiddenOffset: -100,
  msg: '',
  listenOnChangeProps: false,
  asyncSuccessMsg: 'success',
  asyncFailedMsg: 'failed',
  alertType: 'error',
  onPress: '',
}

export default SticykAlert
