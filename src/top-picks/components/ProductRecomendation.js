import React from 'react'
import { ScrollView, View, Image, StyleSheet, Text } from 'react-native'
import { ReactTPRoutes, TKPReactAnalytics } from 'NativeModules'
import TKPTouchable from '../common/TKPTouchable'

const styles = StyleSheet.create({
  brandImage: {
    height: 120,
    width: 120,
    resizeMode: 'contain',
  },
  brandWrapper: {
    marginHorizontal: 5,
    borderRadius: 3,
  },
  prodRecWrapper: {
    borderTopWidth: 1,
    borderColor: '#e0e0e0',
    backgroundColor: 'white',
    marginTop: 12,
    paddingLeft: 10,
    alignItems: 'center',
  },
  text: {
    fontSize: 14,
    color: 'rgba(0,0,0,.7)',
    fontWeight: 'bold',
  },
})

const ProductRecomendation = ({ data }) => (
  <View style={styles.prodRecWrapper}>
    <View style={{ paddingVertical: 12, alignSelf: 'flex-start' }}>
      <Text style={styles.text}>Mungkin Anda Suka</Text>
    </View>
    <ScrollView
      horizontal
      showsHorizontalScrollIndicator={false}
      style={{ paddingBottom: 12 }}
    >
      {data.map((product, i) => (
        <TKPTouchable
          key={i}
          onPress={() => {
            ReactTPRoutes.navigate(product.applink)
          }}
        >
          <View style={styles.brandWrapper}>
            <Image
              source={{ uri: product.image_url_mobile }}
              style={styles.brandImage}
              cache="default"
            />
          </View>
        </TKPTouchable>
      ))}
    </ScrollView>
  </View>
)

export default ProductRecomendation
