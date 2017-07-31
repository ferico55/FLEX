import React from 'react'
import { Text, View, StyleSheet } from 'react-native'

const seo = () => {
  return (
    <View style={styles.seoContainer}>
      <View style={styles.seoContent}>
        <Text style={styles.seoHeading}>Belanja Produk Original & Branded di Official Store Tokopedia</Text>
        <View style={styles.seoPara}>
          <Text>Temukan aneka produk original dari brand resmi asli Indonesia dan Internasional. Di Official Store Tokopedia, anda bisa mendapatkan semua produk berkualitas dengan harga terbaik. Semua produk yang anda beli, dijual dan dikirim langsung oleh toko resmi. Produk di jamin asli / original, berkualitas tinggi, bergaransi resmi dan pelayanan terbaik. Belanja online di Official Store Tokopedia, anda bisa mendapatkan aneka penawaran langsung dari toko-toko resmi di Tokopedia.</Text>
        </View>
        <View style={styles.seoPara}>
          <Text>Promo menarik di Official Store antara lain diskon produk baru, promo bundling, free gifts atau gratis produk, crazy deals, buy one get one, cicilan, cashback hingga gratis ongkir / bebas biaya pengiriman. Terdapat berbagai promo berjalan lainnya untuk mendapatkan barang-barang branded ori dengan harga lebih murah. Belanja online di Official Store Tokopedia lebih hemat dan terpercaya dengan harga terjangkau untuk semua jenis produk. Anda bisa mendapatkan berbagai produk resmi bergaransi & terlengkap seperti elektronik, produk kesehatan, fashion & pakaian, handphone  dan gadget, hobi dan mainan, produk bayi dan balita hingga produk investasi.</Text>
        </View >
        <View style={styles.seoPara}>
          <Text>Belanja produk branded di Official Store Tokopedia, anda dapat menggunakan berbagai metode pembayaran seperti kartu kredit, bank transfer & mobile banking, Tokocash yang praktis, aman dan nyaman. Untuk anda yang ingin selalu up to date dengan produk-produk branded / original tanah air dan brand international, cek selalu Official Store Tokopedia. Dapatkan berbagai barang trendy, unik dan asli terbaru lebih cepat, dengan harga terjangkau dan lengkap hanya di Official Store.</Text>
        </View>
      </View>
    </View>
  )
}

const styles = StyleSheet.create({
  seoContainer: {
    paddingHorizontal: 10,
    backgroundColor: '#fff',
  },
  seoContent: {
    borderTopWidth: 1,
    borderColor: '#e0e0e0',
    borderStyle: 'solid',
  },
  seoHeading: {
    fontWeight: '600',
    marginTop: 20,
  },
  seoPara: {
    marginVertical: 11,
  }
})

export default seo