import React from 'react'
import { StyleSheet, Text, View, TouchableOpacity } from 'react-native'
import color from '../Helper/Color'

const styles = StyleSheet.create({
  defaultView: {
    flex: 1,
  },
  aboveTabContainer: {
    height: 45,
    backgroundColor: 'white',
    flexDirection: 'row',
    shadowColor: 'grey',
    shadowOffset: {
      width: 0,
    },
    shadowRadius: 3,
    shadowOpacity: 1,
  },
  titleLabel: {
    color: color.mainGreen,
    fontSize: 14,
    fontWeight: '500',
  },
  aboveTabView: {
    flex: 1,
    backgroundColor: 'white',
  },
  aboveTabTextContainer: {
    flex: 9,
    alignItems: 'center',
    justifyContent: 'center',
  },
  aboveTabBottomStripOn: {
    height: 3,
    backgroundColor: color.mainGreen,
  },
  aboveTabBottomStripOff: {
    height: 1,
    backgroundColor: color.backgroundGrey,
  },
})

const AboveTabBar = ({
  firstTabTitle,
  secondTabTitle,
  selectedTabIndex,
  tabBarSelected,
}) => (
  <View style={styles.aboveTabContainer}>
    <TouchableOpacity
      style={styles.aboveTabView}
      onPress={() => tabBarSelected(0)}
    >
      <View style={styles.defaultView}>
        <View style={styles.aboveTabTextContainer}>
          <Text style={styles.titleLabel}>{firstTabTitle}</Text>
        </View>
        <View
          style={
            selectedTabIndex === 0 ? (
              styles.aboveTabBottomStripOn
            ) : (
              styles.aboveTabBottomStripOff
            )
          }
        />
      </View>
    </TouchableOpacity>
    <TouchableOpacity
      style={styles.aboveTabView}
      onPress={() => tabBarSelected(1)}
    >
      <View style={styles.defaultView}>
        <View style={styles.aboveTabTextContainer}>
          <Text style={styles.titleLabel}>{secondTabTitle}</Text>
        </View>
        <View
          style={
            selectedTabIndex === 1 ? (
              styles.aboveTabBottomStripOn
            ) : (
              styles.aboveTabBottomStripOff
            )
          }
        />
      </View>
    </TouchableOpacity>
  </View>
)

export default AboveTabBar
