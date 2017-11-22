import React from 'react'
import { View } from 'react-native'

const ImageRow = ({ selectedImages, style, renderImage }) => {
  const images = selectedImages.map((image, index) =>
    renderImage({
      item: image,
      index,
    }),
  )
  return <View style={[{ flexDirection: 'row' }, style]}>{images}</View>
}

export default ImageRow
