import React from 'react'
import { Image, View, TouchableWithoutFeedback } from 'react-native'

const star = { uri: 'icon_star' }
const star_active = { uri: 'icon_star_active' }

class RatingStars extends React.Component {
  renderStars = () => {
    const stars = []
    for (let i = 0; i < 5; i++) {
      if (this.props.enabled) {
        stars.push(
          <TouchableWithoutFeedback
            key={i}
            onPress={() => {
              this.props.onStarPressed(i + 1)
            }}
          >
            <Image
              style={{
                width: this.props.iconSize ? this.props.iconSize : 32,
                height: this.props.iconSize ? this.props.iconSize : 32,
                marginLeft: this.props.spacing ? this.props.spacing : 0,
              }}
              source={i < this.props.rating ? star_active : star}
            />
          </TouchableWithoutFeedback>,
        )
      } else {
        stars.push(
          <Image
            key={i}
            style={{
              width: this.props.iconSize ? this.props.iconSize : 32,
              height: this.props.iconSize ? this.props.iconSize : 32,
              marginLeft: this.props.spacing ? this.props.spacing : 0,
            }}
            source={i < this.props.rating ? star_active : star}
          />,
        )
      }
    }
    return stars
  }

  render = () => {
    if (this.props.rtl) {
      return (
        <View style={{ flexDirection: 'row-reverse' }}>
          {this.renderStars()}
        </View>
      )
    }
    return <View style={{ flexDirection: 'row' }}>{this.renderStars()}</View>
  }
}

module.exports = RatingStars
