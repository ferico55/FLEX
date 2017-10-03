import React from 'react'
import { StyleSheet, Text, View, Image } from 'react-native'
import BigGreenButton from '../Components/BigGreenButton'
import cactusImg from '../Icon/cactus.png'

const styles = StyleSheet.create({
  container: {
    flex: 1,
    justifyContent: 'center',
    paddingHorizontal: 40,
  },
  image: {
    width: 250,
    height: 150,
    marginBottom: 10,
    alignSelf: 'center',
  },
  titleLabel: {
    color: 'black',
    textAlign: 'center',
    marginBottom: 5,
  },
  descLabel: {
    color: 'grey',
    textAlign: 'center',
    fontSize: 11,
    marginBottom: 20,
  },
})

const NoResultView = ({ title, desc, buttonTitle, buttonAction }) => (
  <View style={styles.container}>
    <Image style={styles.image} source={cactusImg} />
    <Text style={styles.titleLabel}>{title}</Text>
    <Text style={styles.descLabel}>{desc}</Text>
    {buttonAction && (
      <BigGreenButton
        title={buttonTitle}
        buttonAction={buttonAction}
        disabled={false}
      />
    )}
  </View>
)

export default NoResultView
