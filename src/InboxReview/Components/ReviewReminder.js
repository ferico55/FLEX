import React from 'react'
import { StyleSheet, Text, View, Image } from 'react-native'

const styles = StyleSheet.create({
  warningViewContainer: {
    backgroundColor: 'rgb(252,231,228)',
    flexDirection: 'row',
    justifyContent: 'center',
    alignItems: 'center',
    paddingVertical: 5,
  },
  mutedText: {
    color: 'rgba(0,0,0,0.38)',
  },
})

const ReviewReminder = ({ style, isEditable, day }) => (
  <View style={[styles.warningViewContainer, style]}>
    <Image
      source={{ uri: 'icon_hourglass' }}
      style={{ width: 13, height: 16 }}
    />
    <Text style={[styles.mutedText, { fontSize: 13, marginLeft: 5 }]}>
      {`Batas ${isEditable ? 'mengubah' : 'memberikan'} penilaian ${day === null
        ? '3'
        : day} hari lagi`}
    </Text>
  </View>
)

export default ReviewReminder
