import React, { Component } from 'react'
import { View, StyleSheet, Image, Text, Dimensions } from 'react-native'
import { icons } from '../lib/icons'

const { width } = Dimensions.get('window')
const scale = width / 375
const infoContent = [
  {
    name: 'Produk dari Brand Resmi',
    desc: 'Semua produk di Official Store Tokopedia merupakan produk langsung dari brand-brand pilihan.',
    img: icons.official_brand
  },
  {
    name: 'Pelayanan Berkualitas untuk Anda',
    desc: 'Tim Customer Care kami selalu siap untuk melayani Anda selama 24/7.',
    img: icons.great_service
  },
  {
    name: 'Penawaran Promo Ekslusif',
    desc: 'Dapatkan penawaran ekslusif mulai dari diskon, cashback, hingga buy 1 get 1 free.',
    img: icons.exclusive_promo
  },
  {
    name: 'Cicilan 0% Gratis Biaya Admin',
    desc: 'Cicilan bunga 0% dan bebas biaya admin untuk tenor 3, 6, 12, 18, sampai 24 bulan.',
    img: icons.installment_0
  }
]

const Infographics = () => {
  return (
    <View style={styles.infoContainer}>
      {
        infoContent.map((content, idx) => (
          <View style={styles.contentContainer} key={idx}>
            <View style={styles.contentImageContainer}>
              <Image source={{ uri: content.img }} style={styles.imageStyle} />
            </View>

            <View style={styles.contentTextContainer}>
              <Text style={styles.contentName}>{content.name}</Text>
              <Text style={styles.contentDescription}>{content.desc}</Text>
            </View>
          </View>
        ))
      }
    </View>
  )
}

const styles = StyleSheet.create({
  imageStyle: {
    width: width > 414 ? 120 : 80,
    height: width > 414 ? 120 : 80,
    resizeMode: 'contain',
  },
  infoContainer: {
    width,
    marginTop: 20,
    padding: 10,
    backgroundColor: '#FFF',
    borderTopWidth: 1,
    borderColor: '#E0E0E0',
  },
  contentContainer: {
    width: width - 20,
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'flex-start',
    marginBottom: 5,
  },
  contentImageContainer: {
    alignItems: 'center',
    justifyContent: 'center',
  },
  contentTextContainer: {
    flex: 1,
    paddingLeft: 10,
  },
  contentName: {
    fontSize: Math.round(scale * 14),
    fontWeight: '600',
  },
  contentDescription: {
    lineHeight: width > 414 ? 40 : 20,
    fontSize: Math.round(scale * 12),
  },
})

export default Infographics
