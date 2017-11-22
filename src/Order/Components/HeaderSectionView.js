import React from 'react'
import { Text, View, StyleSheet } from 'react-native'

const styles = StyleSheet.create({
  container: {
    height: 60,
    backgroundColor: 'white',
    flex: 1,
    flexDirection: 'column',
  },
  title: {
    fontWeight: '500',
    fontSize: 16,
    marginLeft: 16,
  },
  titleView: {
    height: 58,
    backgroundColor: 'white',
    justifyContent: 'center',
  },
  line: {
    height: 1,
    backgroundColor: 'rgba(0, 0, 0, 0.12)',
  },
})

const HeaderSection = ({ title }) => (
  <View style={styles.container}>
    <View style={styles.line} />
    <View style={styles.titleView}>
      <Text style={styles.title}>{title}</Text>
    </View>
    <View style={styles.line} />
  </View>
)

export default HeaderSection
