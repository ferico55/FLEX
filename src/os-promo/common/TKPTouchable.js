import React from 'react'
import {
  TouchableHighlight,
  TouchableNativeFeedback,
  Platform,
} from 'react-native'

function TKPTouchableIOS(props) {
  return (
    <TouchableHighlight
      accessibilityTraits="button"
      underlayColor="#ff5722"
      {...props}
    />
  );
}

const TKPTouchable = Platform.OS === 'android'
  ? TouchableNativeFeedback
  : TKPTouchableIOS;

module.exports = TKPTouchable;
