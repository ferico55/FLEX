import React from 'react'
import { StyleSheet, Text, View, TouchableOpacity, Image } from 'react-native'

const styles = StyleSheet.create({
  filterContainer: {
    backgroundColor: 'white',
    width: 120,
    height: 40,
    borderRadius: 20,
    paddingVertical: 12,
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'center',
  },
})

const FilterButton = ({ onPress }) => (
  <TouchableOpacity onPress={onPress}>
    <View
      style={styles.filterContainer}
      shadowColor="black"
      shadowRadius={2}
      shadowOpacity={0.38}
      shadowOffset={{ height: 2 }}
    >
      <Image
        source={{ uri: 'icon_filter' }}
        style={{ width: 17, height: 17, marginRight: 7 }}
      />
      <Text style={{ color: 'rgba(0,0,0,0.7)', fontWeight: '600' }}>
        Filter
      </Text>
    </View>
  </TouchableOpacity>
)

export default FilterButton
