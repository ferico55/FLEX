import React from 'react'
import { View, Text, Image, StyleSheet, Dimensions } from 'react-native'
import iconUSP from './img/icon-usp.png'
import iconCheck from './img/icon-gcheck.png'

const OfficialStoreIntro = () => {
  const uspText = [
    'Produk dari Brand Resmi',
    'Penawaran Ekslusif',
    'Pelayanan Berkualitas',
    'Cicilan 0% Gratis Biaya Admin',
  ]

  const { width } = Dimensions.get('window')
  const maxWidth = width > 320 ? 118 : 100

  return (
    <View style={styles.osIntro}>
      <View style={styles.osIntroInner}>
        <Image source={iconUSP} style={styles.osIntroImage} />
        <View style={styles.osIntroTextWrap}>
          <Text style={styles.uspHeading}>
            {'Official Store Tokopedia'.toUpperCase()}
          </Text>
          <View
            style={{
              flexDirection: 'row',
              alignItems: 'flex-start',
              flexWrap: 'wrap',
            }}
          >
            {uspText.map((usp, idx) => (
              <View
                key={idx}
                style={
                  idx === 3 ? (
                    [{ width: '50%', maxWidth }, styles.uspTextWrap]
                  ) : (
                      [{ width: '50%', maxWidth }, styles.uspTextWrap]
                    )
                }
              >
                <Image
                  source={iconCheck}
                  style={{
                    width: 10,
                    height: 15,
                    resizeMode: 'contain',
                    marginRight: 5,
                  }}
                />
                <Text
                  numberOfLines={2}
                  ellipsizeMode={'tail'}
                  style={styles.uspText}
                >
                  {usp}
                </Text>
              </View>
            ))}
          </View>
        </View>
      </View>
    </View>
  )
}

const styles = StyleSheet.create({
  osIntro: {
    flex: 1,
    backgroundColor: '#FFF',
    marginBottom: 20,
    padding: 10,
    borderBottomWidth: 1,
    borderColor: '#E0E0E0',
  },
  osIntroInner: {
    flexDirection: 'row',
    alignItems: 'center',
  },
  osIntroImage: {
    flex: 1 / 3,
    justifyContent: 'center',
    alignItems: 'center',
    height: 70,
    resizeMode: 'contain',
  },
  osIntroTextWrap: {
    flex: 1,
  },
  uspHeading: {
    fontSize: 16,
    fontWeight: '700',
    color: '#42B549',
    fontStyle: 'italic',
    marginBottom: 5,
  },
  uspTextWrap: {
    flexDirection: 'row',
    alignItems: 'flex-start',
    marginBottom: 3,
    marginRight: 10,
  },
  uspText: {
    fontSize: 10,
    lineHeight: 12,
  },
})

export default OfficialStoreIntro
