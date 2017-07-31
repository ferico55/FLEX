import React from 'react'
import { View, StyleSheet, Image, Text, Dimensions } from 'react-native'
import OriginalImage from './img/icon-original.png'
import ServiceImage from './img/icon-service.png'
import PromotionImage from './img/icon-promotion.png'
import QualityImage from './img/icon-free-installment.png'

const {height, width, fontScale} = Dimensions.get('window');
const scale = width/375

const infographic = () => {
  return (
    <View style={styles.osInfographic}>
      <View style={styles.osInfoContent}>
        <View style={styles.osInfoImgWrap}>
          <Image source={OriginalImage} style={styles.osInfoImg} />
        </View>
        <View style={styles.osInfoContentText}>
          <View>
            <Text style={styles.osInfoHeading}>Produk 100% Asli</Text>
          </View>
          <View style={styles.osInfoContentPara}>
            <Text
              ellipsizeMode='tail'
              numberOfLines={3}
              style={styles.osInfoContentParaText}>Semua produk di Official Store Tokopedia merupakan produk langsung dari brand-brand pilihan.</Text>
          </View>
        </View>
      </View>
       <View style={styles.osInfoContent}>
        <View style={styles.osInfoImgWrap}>
          <Image source={ServiceImage} style={styles.osInfoImg} />
        </View>
        <View style={styles.osInfoContentText}>
          <View>
            <Text style={styles.osInfoHeading}>Pelayanan Berkualitas untuk Anda</Text>
          </View>
          <View style={styles.osInfoContentPara}>
            <Text style={styles.osInfoContentParaText}>Tim Customer Care kami selalu siap untuk melayani Anda selama 24/7.</Text>
          </View>
        </View>
      </View>
      <View style={styles.osInfoContent}>
        <View style={styles.osInfoImgWrap}>
          <Image source={PromotionImage} style={styles.osInfoImg} />
        </View>
        <View style={styles.osInfoContentText}>
          <View>
            <Text style={styles.osInfoHeading}>Penawaran Promo Eksklusif</Text>
          </View>
          <View style={styles.osInfoContentPara}>
            <Text style={styles.osInfoContentParaText}>Dapatkan penawaran eksklusif mulai dari diskon, cashback, hingga buy 1 get 1 free.</Text>
          </View>
        </View>
      </View>
      <View style={styles.osInfoContent}>
        <View style={styles.osInfoImgWrap}>
          <Image source={QualityImage} style={styles.osInfoImg} />
        </View>
        <View style={styles.osInfoContentText}>
          <View>
            <Text style={styles.osInfoHeading}>Cicilan 0%, Gratis Biaya Admin</Text>
          </View>
          <View style={styles.osInfoContentPara}>
            <Text style={styles.osInfoContentParaText}>Cicilan bunga 0% dan bebas biaya admin untuk tenor 3, 6, 12, 18, sampai 24 bulan.</Text>
          </View>
        </View>
      </View> 
    </View>
  )
}

const styles = StyleSheet.create({
  osInfographic: {
    paddingTop: 20,
    paddingRight: 10,
    paddingBottom: 10,
    paddingLeft: 10,
    width: Dimensions.get('window').width,
    backgroundColor: '#fff',
    borderTopWidth: 1,
    borderColor: '#e0e0e0',
  },
  osInfoContent: {
    flex: 1,
    flexDirection: 'row',
    alignItems: 'flex-start',
    justifyContent: 'flex-start',
    marginBottom: 15,

  },
  osInfoImgWrap: {
    flex: 1 / 4,
    width: 89,
  },
  osInfoImg: {
    width: 80,
  },
  osInfoContentText: {
    paddingLeft: 10,
    flex: 3 / 4
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
  }
})

export default infographic