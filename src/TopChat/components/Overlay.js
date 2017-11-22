/* @flow */

import React, { PureComponent } from 'react'
import { View, ActivityIndicator, PanResponder } from 'react-native'
import PropTypes from 'prop-types'

class Overlay extends PureComponent {
  componentWillMount() {
    this.overlayPanResponder = PanResponder.create({
      onStartShouldSetPanResponder: () => true,
      onPanResponderRelease: () => {
        if (!this.props.animating) {
          this.props.onDismiss()
        }
      },
    })
  }

  render() {
    return (
      <View
        style={{
          position: 'absolute',
          top: this.props.top,
          left: 0,
          right: 0,
          bottom: this.props.bottom,
          backgroundColor: 'rgba(0,0,0,0.75)',
          justifyContent: 'center',
          alignItems: 'center',
        }}
        {...this.overlayPanResponder.panHandlers}
      >
        <ActivityIndicator
          size={'small'}
          animating={this.props.animating}
          color={'white'}
        />
      </View>
    )
  }
}

Overlay.propTypes = {
  onDismiss: PropTypes.func.isRequired,
  animating: PropTypes.bool.isRequired,
  bottom: PropTypes.number,
}

Overlay.defaultProps = {
  bottom: 0,
  top: 0,
}

export default Overlay
