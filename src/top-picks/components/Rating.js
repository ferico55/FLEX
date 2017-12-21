import React from 'react'
import { View, Text, Image } from 'react-native'

const Rating = ({ rating, count }) => {
  if (!rating) {
    return <View style={{ height: 16 }} />
  }
  const ratings = []
  for (let index = 0; index < 5; index++) {
    if (index < rating) {
      ratings.push(
        <View key={index}>
          <Image
            source={require('./img/icon_review_full.png')}
            style={{ width: 11, height: 11 }}
            cache="default"
          />
        </View>,
      )
    } else {
      ratings.push(
        <View key={index}>
          <Image
            source={require('./img/icon_review_empty.png')}
            style={{ width: 11, height: 11 }}
            cache="default"
          />
        </View>,
      )
    }
  }

  return (
    <View
      style={{
        flexDirection: 'row',
        paddingHorizontal: 10,
        alignItems: 'center',
      }}
    >
      {ratings}
      <Text
        style={{
          color: 'rgba(0,0,0,0.36)',
          fontSize: 11,
          paddingLeft: 3,
          lineHeight: 16,
        }}
      >{`(${count})`}</Text>
    </View>
  )
}

export default Rating
