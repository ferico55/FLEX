// @flow
import React from 'react'
import { View, Image, StyleSheet, ScrollView } from 'react-native'
import LabelTag from './LabelTag'

const styles = StyleSheet.create({
  container: {
    position: 'relative',
  },
  labelsContainer: {
    marginBottom: 22,
    paddingLeft: 5,
    paddingRight: 40,
  },
  transparentIcon: {
    position: 'absolute',
    right: 0,
    width: 50,
    height: 40,
  },
})
const transparentIcon = { uri: 'transparent_overlay' }

export default ({ values }: { values: Object }) => {
  if (!values.length) {
    return null
  }
  return (
    <View style={styles.container}>
      <ScrollView
        contentContainerStyle={styles.labelsContainer}
        showsHorizontalScrollIndicator={false}
        horizontal
      >
        {values.map(value => (
          <LabelTag
            {...value}
            key={`${value.key}_${value.value}`}
            formKey={value.key}
          />
        ))}
      </ScrollView>
      <Image source={transparentIcon} style={styles.transparentIcon} />
    </View>
  )
}
