import React from 'react'
import { ScrollView, Text, View, Image, Dimensions, StyleSheet } from 'react-native'

const { width } = Dimensions.get('window')

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: 'white'
  },
  welcome: {
    fontSize: 20,
    textAlign: 'center',
    margin: 15,
    color: 'black'
  },
  images: {
    resizeMode: 'contain',
    width
  },
})

const FlashSale = () => {
  return (
    <ScrollView style={styles.container}>
      <Text style={styles.welcome}>FlashSale 10-12 Dec</Text>
      <View>
        <Text>Homapage (Marketpalce) Banners:</Text>
        <Image source={require('./img/1.jpg')} style={styles.images} />
      </View>
      <View>
        <Text>Sub Cataegory Banner:</Text>
        <Image source={require('./img/2.jpg')} style={styles.images} />
      </View>
      <View>
        <Text>Hot List Landscape Banner:</Text>
        <Image source={require('./img/3.jpg')} style={styles.images} />
      </View>
      <View>
        <Text> Official Store Microsite Banners:</Text>
        <Image source={require('./img/4.png')} style={styles.images} />
      </View>
      <View>
        <Text>Deals Banner</Text>
        <Image source={require('./img/5.png')} style={styles.images} />
      </View>
    </ScrollView>
  )
}

export default FlashSale