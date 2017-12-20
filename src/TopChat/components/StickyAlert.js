/* @flow */

import React, { Component } from 'react'
import { View, Text, Animated, ActivityIndicator } from 'react-native'
import PropTypes from 'prop-types'

const successColor = 'rgb(66,181,73)'
const errorColor = 'rgb(255,59,48)'

class StickyAlert extends Component {
  constructor(props) {
    super(props)
    this.state = {
      show: props.show,
    }
    this.top = new Animated.Value(props.hiddenOffset)
  }

  hideStickyAlert = () =>
    Animated.spring(this.top, {
      toValue: this.props.hiddenOffset,
      bounciness: 0,
      delay: 1500,
      duration: 250,
    }).start()

  showStickyAlert = show =>
    this.setState({ show }, () => {
      Animated.spring(this.top, {
        toValue: this.props.top,
        bounciness: 0,
        duration: 500,
      }).start()
    })

  componentWillReceiveProps(nextProps) {
    if (this.props.show && !nextProps.show) {
      this.hideStickyAlert()
    } else {
      this.showStickyAlert(nextProps.show)
    }
  }

  backgroundColor = () =>
    this.props.alertType === 'success' ? successColor : errorColor

  renderText = () => (
    <Text style={{ fontSize: 13, color: 'white' }}>{this.props.message}</Text>
  )

  renderLoading = () => {
    if (this.props.alertType === 'error') {
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
            backgroundColor: this.backgroundColor(),
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
          <View style={{ flexDirection: 'row' }}>{this.renderText()}</View>
          <View style={{ flex: 1, alignItems: 'flex-end' }}>
            {this.renderLoading()}
          </View>
        </View>
      </Animated.View>
    )
  }
}

StickyAlert.propTypes = {
  show: PropTypes.bool.isRequired,
  message: PropTypes.string.isRequired,
  top: PropTypes.number,
  height: PropTypes.number,
  hiddenOffset: PropTypes.number,
  alertType: PropTypes.string,
}

StickyAlert.defaultProps = {
  show: false,
  message: '',
  top: 0,
  height: 50,
  hiddenOffset: -100,
  alertType: 'error',
}

export default StickyAlert
