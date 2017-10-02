import { requireNativeComponent } from 'react-native'
import React, { Component } from 'react'

const ReactBanner = requireNativeComponent('ReactBanner', null)

const Banner = ({children, style, onPageChange}) => (
  <ReactBanner style={[style, {flexDirection: 'row'}]} onPageChange={onPageChange}>
    {children}
  </ReactBanner>
)

export default Banner
