import React from 'react'
import { Image, View, TouchableWithoutFeedback } from 'react-native'

const star = { uri: 'icon_star' }
const star_active = { uri: 'icon_star_active' }

class RatingStars extends React.Component {
  _renderStars = () => {
    let stars = []
    for (let i = 0; i < 5; i++) {
      stars.push(
        <TouchableWithoutFeedback
          key={i}
          onPress={() => {
            if (!this.props.enabled) {
              return
            }
            this.props.onStarPressed(i + 1)
          }}
        >
          <Image
            style={{ width: 32, height: 32 }}
            source={i < this.props.rating ? star_active : star}
          />
        </TouchableWithoutFeedback>
      )
    }
    return stars
  }

  render = () => (
    <View style={{ flexDirection: 'row' }}>{this._renderStars()}</View>
  )
}

module.exports = RatingStars
