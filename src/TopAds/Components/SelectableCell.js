import React from 'react'
import { StyleSheet, Text, View, TouchableOpacity, Image } from 'react-native'
import color from '../Helper/Color'
import checkImg from '../Icon/check.png'

const styles = StyleSheet.create({
  cellContainer: {
    backgroundColor: 'white',
    flexDirection: 'row',
    alignItems: 'center',
    paddingHorizontal: 20,
  },
  cellTitleLabel: {
    flex: 1,
    fontSize: 16,
    color: color.blackText,
  },
  cellChecklistContainer: {
    width: 16,
    alignItems: 'center',
    justifyContent: 'center',
  },
  cellChecklistView: {
    height: 16,
    width: 16,
    borderWidth: 1,
    borderRadius: 8,
    borderColor: color.darkerGrey,
    overflow: 'hidden',
  },
  cellChecklistImageView: {
    height: 16,
    width: 16,
  },
})

const SelectableCell = ({ title, cellSelected, currentIndex, isSelected }) => (
  <TouchableOpacity onPress={() => cellSelected(currentIndex)}>
    <View style={styles.cellContainer}>
      <Text style={styles.cellTitleLabel}>{title}</Text>
      <View style={styles.cellChecklistContainer}>
        <View
          style={{
            height: 64,
            justifyContent: 'center',
            marginRight: 5,
          }}
        >
          {isSelected ? (
            <Image style={styles.cellChecklistImageView} source={checkImg} />
          ) : (
            <View style={styles.cellChecklistView} />
          )}
        </View>
      </View>
    </View>
  </TouchableOpacity>
)

export default SelectableCell
