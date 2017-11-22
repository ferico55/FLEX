import React from 'react'
import { ActivityIndicator, Image, StyleSheet, View, Text } from 'react-native'
import { createStructuredSelector } from 'reselect'
import { connect } from './redux'
import ListOfFilters from './filters'

const styles = StyleSheet.create({
  notFoundIcon: {
    width: 80,
    height: 80,
    marginBottom: 20,
    marginTop: 20,
  },
  notFoundCountainer: {
    flex: 1,
    alignItems: 'center',
    justifyContent: 'center',
  },
  textErrorMain: {
    fontSize: 16,
  },
  textErrorSecond: {
    color: 'grey',
    fontSize: 14,
  },
})

const iconNotFound = { uri: 'no-result' }
const selector = createStructuredSelector({
  formReady: ({ formReady }) => formReady,
  dynamicFilterData: ({ dynamicFilterData, uniqueIdAndSource }) =>
    dynamicFilterData[uniqueIdAndSource],
})

export default connect(
  selector,
)(({ formReady, dynamicFilterData, nativeNavigationInstanceId }) => {
  if (!formReady) {
    return <ActivityIndicator />
  }
  if (formReady === 'error') {
    return (
      <View style={styles.notFoundCountainer}>
        <Image
          source={iconNotFound}
          style={styles.notFoundIcon}
          resizeMode="contain"
        />
        <Text style={styles.textErrorMain}>Terjadi kesalahan koneksi</Text>
        <Text style={styles.textErrorSecond}>Silakan coba lagi</Text>
      </View>
    )
  }

  return (
    <ListOfFilters
      dynamicFilterData={dynamicFilterData}
      nativeNavigationInstanceId={nativeNavigationInstanceId}
    />
  )
})
