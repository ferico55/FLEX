import React from 'react'
import HTMLView from 'react-native-htmlview'
import { Text, View, StyleSheet } from 'react-native'

const styles = StyleSheet.create({
  container: {
    backgroundColor: 'white',
    flex: 1,
    flexDirection: 'row',
  },
  lineContainer: {
    flexDirection: 'column',
    marginLeft: 16,
    alignItems: 'center',
    width: 8,
    marginRight: 4,
  },
  textContainer: {
    flex: 1,
    flexDirection: 'column',
    marginLeft: 4,
  },
  timeContainer: {
    marginLeft: 4,
    marginRight: 16,
  },
  circle: {
    width: 8,
    height: 8,
    borderRadius: 8 / 2,
    marginBottom: 4,
    marginTop: 4,
  },
  line: {
    width: 2,
    height: 10,
    flexGrow: 1,
  },
  title: {
    fontSize: 14,
    fontWeight: '500',
    marginBottom: 5,
  },
  time: {
    fontSize: 12,
    color: 'rgba(0, 0, 0, 0.38)',
  },
})

const HTMLStylesheet = StyleSheet.create({
  div: {
    fontSize: 14,
    marginBottom: 20,
    color: 'rgba(0, 0, 0, 0.38)',
  },
})

const wrapHtml = description => `<div>${description}</div>`

const HistoryCell = ({ title, time, description, color, islastCell }) => (
  <View style={styles.container}>
    <View style={styles.lineContainer}>
      <View style={styles.circle} backgroundColor={color} />
      {islastCell ? (
        <View style={styles.line} backgroundColor={'white'} />
      ) : (
        <View style={styles.line} backgroundColor={color} />
      )}
    </View>
    <View style={styles.textContainer}>
      <View style={styles.titleView}>
        <Text style={[styles.title, { color }]}>{title}</Text>
        <HTMLView value={wrapHtml(description)} stylesheet={HTMLStylesheet} />
      </View>
    </View>

    <View style={styles.timeContainer}>
      <Text style={styles.time}>{time}</Text>
    </View>
  </View>
)

export default HistoryCell
