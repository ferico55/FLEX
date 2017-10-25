import React from 'react'
import { Image, Text, View } from 'react-native'
import iconReview from '../img/icon-review.png'
import iconReviewEmpty from '../img/icon-review-empty.png'

export const Stars = ({ rate, totalReview }) => {
  const totalStar = Math.round(rate / 20)
  const stars = []

  if (rate == null || rate === 0) {
    return null
  }

  for (let i = 1; i <= 5; i++) {
    stars.push(
      <Image
        key={`active_${i}`}
        style={{ width: 12, height: 12 }}
        source={i <= totalStar ? iconReview : iconReviewEmpty}
      />,
    )
  }
  stars.push(
    <Text
      key="total-review"
      style={{ fontSize: 11, color: 'rgba(0,0,0,0.36)', marginLeft: 4 }}
    >
      ({totalReview})
    </Text>,
  )
  return (
    <View
      style={{
        flexDirection: 'row',
        alignItems: 'center',
        marginLeft: 10,
        marginBottom: 6,
      }}
    >
      {stars}
    </View>
  )
}

export const ProductLabels = ({ labels }) => {
  if (labels != null) {
    return (
      <View
        style={{
          marginLeft: 10,
          marginRight: 5,
          flexDirection: 'row',
          marginBottom: 4,
        }}
      >
        {labels.map(label => (
          <View
            key={label.title}
            style={{
              backgroundColor: label.color,
              borderRadius: 2,
              justifyContent: 'center',
              marginRight: 4,
              borderWidth: label.color === '#ffffff' ? 1 : 0,
              borderColor: 'rgba(0,0,0,0.12)',
            }}
          >
            <Text
              style={{
                fontSize: 10,
                color: label.color === '#ffffff' ? 'rgba(0,0,0,0.54)' : 'white',
                margin: 4,
                textAlign: 'center',
                fontWeight: label.color === '#ffffff' ? undefined : '600',
              }}
            >
              {label.title}
            </Text>
          </View>
        ))}
      </View>
    )
  }
  return null
}

export const Badges = ({ badges, productId }) =>
  badges != null && (
    <View style={{ flexDirection: 'row' }}>
      {badges.map(badge => (
        <Image
          style={{ width: 15, height: 15 }}
          key={badge.image_url + productId}
          source={{ uri: badge.image_url }}
        />
      ))}
    </View>
  )
