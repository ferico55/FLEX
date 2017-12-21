import React from 'react'
import { Image, View, StyleSheet } from 'react-native'
const styles = StyleSheet.create({
  header: {
    height: 100,
    marginTop: 10,
    resizeMode: 'center',
    paddingHorizontal: 10,
  }
})

const Header = (title) => {
  const imageUrl = title['title'][0].image_url_mobile
  return (
    <View>
      <Image source={{ uri: imageUrl }} style={styles.header} cache="default"/>
    </View>
  )
}

export default Header
