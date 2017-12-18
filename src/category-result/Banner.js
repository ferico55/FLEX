import { requireNativeComponent } from 'react-native'
import React, { Component } from 'react'

const ReactBanner = requireNativeComponent('ReactBanner', null)

const Banner = ({ children, style, onPageChange, onPress }) => (
  <ReactBanner
    style={[style, { flexDirection: 'row' }]}
    onPageChange={onPageChange}
    onPress={event => onPress(event.nativeEvent.index)}
  >
    {children}
  </ReactBanner>
)

export default Banner
