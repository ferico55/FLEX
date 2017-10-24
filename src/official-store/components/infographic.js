import React from 'react'
import { View, StyleSheet, Image, Text, Dimensions } from 'react-native'
import OriginalImage from './img/icon-original.png'
import ServiceImage from './img/icon-service.png'
import PromotionImage from './img/icon-promotion.png'
import QualityImage from './img/icon-free-installment.png'

const { width } = Dimensions.get('window')
const scale = width / 375

const infographic = () => {
  const infoContent = [
    {
      name: 'Produk dari Brand Resmi',
      desc:
        'Semua produk di Official Store Tokopedia merupakan produk langsung dari brand-brand pilihan.',
      img: OriginalImage,
    },
    {
      name: 'Pelayanan Berkualitas untuk Anda',
      desc:
        'Tim Customer Care kami selalu siap untuk melayani Anda selama 24/7.',
      img: ServiceImage,
    },
    {
      name: 'Penawaran Promo Ekslusif',
      desc:
        'Dapatkan penawaran ekslusif mulai dari diskon, cashback, hingga buy 1 get 1 free.',
      img: PromotionImage,
    },
    {
      name: 'Cicilan 0% Gratis Biaya Admin',
      desc:
        'Cicilan bunga 0% dan bebas biaya admin untuk tenor 3, 6, 12, 18, sampai 24 bulan.',
      img: QualityImage,
    },
  ]

  return (
    <View style={styles.osInfographic}>
      {infoContent.map((info, idx) => (
        <View style={styles.osInfoContent} key={idx}>
          <View style={styles.osInfoImgWrap}>
            <Image source={info.img} style={styles.osInfoImg} />
          </View>
          <View style={styles.osInfoContentText}>
            <View>
              <Text style={styles.osInfoHeading}>{info.name}</Text>
            </View>
            <View style={styles.osInfoContentPara}>
              <Text
                ellipsizeMode='tail'
                numberOfLines={3}
                style={styles.osInfoContentParaText}
              >
                {info.desc}
              </Text>
            </View>
          </View>
        </View>
      ))}
    </View>
  )
}

const styles = StyleSheet.create({
  osInfographic: {
    backgroundColor: '#FFF',
    marginTop: 20,
    paddingRight: 10,
    paddingBottom: 10,
    paddingLeft: 10,
    borderTopWidth: 1,
    borderColor: '#E0E0E0',
    width,
  },
  osInfoContent: {
    display: 'flex',
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'space-between',
  },
  osInfoImgWrap: {
    display: 'flex',
    flexDirection: 'row',
    width: 80,
    justifyContent: 'center',
  },
  osInfoImg: {
    width: 75,
    resizeMode: 'contain',
  },
  osInfoContentText: {
    flex: 1,
    paddingLeft: 10,
  },
  osInfoHeading: {
    fontSize: Math.round(scale * 14),
    fontWeight: '600',
    marginTop: 5,
  },
  osInfoContentPara: {
    marginTop: 5,
    margin: 0,
  },
  osInfoContentParaText: {
    fontSize: 12,
    lineHeight: 16,
    textAlign: 'auto',
  },
})

export default infographic
