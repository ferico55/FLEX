import React from 'react'
import {
  View,
  Image,
  Button,
  Text,
  TouchableNativeFeedback,
  TouchableOpacity,
  Platform,
  StyleSheet } from 'react-native'
import PropTypes from 'prop-types'
import Icon from 'react-native-vector-icons/Ionicons'

const LoadMore = ({ onLoadMore, onSlideMore, offset, limit, canFetch, isFetching }) => {
  _onClick = () => {
    if (isFetching) {
      return
    } else {
      if (canFetch) {
        onLoadMore(limit, offset)
      } else {
        onSlideMore()
      }
    }
  }

  const Touchable = Platform.OS === 'android' ? TouchableNativeFeedback : TouchableOpacity

  return (
    <View style={{flex: 1 / 3}}>
      <Touchable onPress={_onClick}>
        <View style={styles.container}>
          <Icon name='ios-more' size={46} color='#42b549' />
          <Text style={styles.text}>Brand Lainnya</Text>
        </View>
      </Touchable>
    </View>
  )
}

const styles = StyleSheet.create({
  container: {
    flexDirection: 'column',
    justifyContent: 'center',
    alignItems: 'center',
  },
  text: {
    color: '#42b549',
  }
})

export default LoadMore