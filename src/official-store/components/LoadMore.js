import React from 'react'
import {
  StyleSheet,
  TouchableNativeFeedback,
  TouchableOpacity,
  Platform,
  Text,
  View,
} from 'react-native'

const LoadMore = props => {
  const Touchable =
    Platform.OS === 'android' ? TouchableNativeFeedback : TouchableOpacity

  return (
    <Touchable
      onPress={() => {props.canFetch && !props.isFetching ? props.onLoadMore(props.limit, props.offset) : null }}
    >
      <View style={styles.container}>
        <View style={styles.button}>
          <Text style={styles.text}>Lihat Selebihnya</Text>
        </View>
      </View>
    </Touchable>
  )
}

const styles = StyleSheet.create({
  container: {
    marginTop: 20,
    marginHorizontal: 10,
    marginBottom: 30,
  },
  button: {
    borderWidth: 1,
    borderColor: '#e0e0e0',
    backgroundColor: '#fff',
    paddingVertical: 18,
    borderRadius: 3,
  },
  text: {
    color: 'rgba(0,0,0,.38)',
    textAlign: 'center',
    fontWeight: '600',
    borderWidth: 0,
    backgroundColor: '#fff',
  },
})
export default LoadMore
