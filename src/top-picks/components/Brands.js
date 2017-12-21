import React from 'react'
import { ScrollView, View, Image, StyleSheet, Text } from 'react-native'
import { ReactTPRoutes, TKPReactAnalytics } from 'NativeModules'
import TKPTouchable from '../common/TKPTouchable'

const styles = StyleSheet.create({
  brandImage: {
    height: 80,
    width: 80,
    resizeMode: 'contain',
  },
  brandWrapper: {
    marginHorizontal: 5,
    borderWidth: 1,
    borderColor: '#e0e0e0',
    borderRadius: 3,
  },
  brandContainer: {
    borderTopWidth: 1,
    borderBottomWidth: 1,
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

const Brands = ({ data }) => (
  <View style={styles.brandContainer}>
    <View style={{ paddingVertical: 12, alignSelf: 'flex-start' }}>
      <Text style={styles.text}>Brand Rekomendasi</Text>
    </View>
    <ScrollView
      horizontal
      showsHorizontalScrollIndicator={false}
      style={{ paddingBottom: 12 }}
    >
      {data.map((brand, i) => (
        <TKPTouchable
          key={i}
          onPress={() => {
            ReactTPRoutes.navigate(brand.applink)
          }}
        >
          <View style={styles.brandWrapper}>
            <Image
              source={{ uri: brand.image_url_mobile }}
              style={styles.brandImage}
              cache="default"
            />
          </View>
        </TKPTouchable>
      ))}
    </ScrollView>
  </View>
)

export default Brands
