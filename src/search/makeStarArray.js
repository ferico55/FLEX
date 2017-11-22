import React from 'react'
import { Image } from 'react-native'
import fp from 'lodash/fp'

const iconStarActive = { uri: 'icon_star_active' }

const maxStars = 5
const iconStarInactive = { uri: 'icon_star' }

export default style =>
  fp.times(index => {
    const starCount = index
    const blankStarCount = maxStars - starCount
    const stars = fp.times(
      key => (
        <Image key={`star_${key}`} source={iconStarActive} style={style} />
      ),
      starCount,
    )
    const blankStars = fp.times(
      key => (
        <Image
          key={`blankstar_${key}`}
          source={iconStarInactive}
          style={style}
        />
      ),
      blankStarCount,
    )
    return [...stars, ...blankStars]
  }, maxStars + 1)
