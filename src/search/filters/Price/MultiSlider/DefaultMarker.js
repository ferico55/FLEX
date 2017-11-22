// @flow
import React from 'react'
import { View, StyleSheet } from 'react-native'

const styles = StyleSheet.create({
  markerStyle: {
    height: 30,
    width: 30,
    borderRadius: 30,
    borderWidth: 1,
    borderColor: '#66b573',
    backgroundColor: '#FFFFFF',
  },
  pressedMarkerStyle: {},
  disabled: {
    backgroundColor: '#d3d3d3',
  },
})

export default (props: {
  pressed: boolean,
  pressedMarkerStyle: object,
  markerStyle: object,
  enabled: boolean,
  valuePrefix: string,
  valueSuffix: string,
}) => (
  <View
    style={
      props.enabled ? (
        [
          styles.markerStyle,
          props.markerStyle,
          props.pressed && styles.pressedMarkerStyle,
          props.pressed && props.pressedMarkerStyle,
        ]
      ) : (
        [styles.markerStyle, styles.disabled]
      )
    }
  />
)
