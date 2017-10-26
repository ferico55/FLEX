import React from 'react'
import {
  View,
  Image,
  StyleSheet,
  Dimensions,
  Platform,
  TouchableWithoutFeedback,
} from 'react-native'
import { ReactTPRoutes, TKPReactAnalytics } from 'NativeModules'

const { width } = Dimensions.get('window')

const handleBannerTap = (banner, appUrl) => {
  let label = ''

  switch (banner.positions) {
    case 1:
      label = 'Main Square'
      break
    case 2:
      label = 'Top Long Rectangle'
      break
    case 3:
      label = 'Bottom Long Rectangle'
      break
    default:
      break
  }
  TKPReactAnalytics.trackEvent({
    name: 'clickOSMicrosite',
    category: 'Promo - Banner',
    action: 'Click',
    label: `Banner - ${label} - ${banner.destination_url}`,
  })

  ReactTPRoutes.navigate(appUrl)
}

const MainBanner = ({ dataMainBanners }) => {
  const bannersImage = dataMainBanners.images
  // remapping array position
  const arrImages = bannersImage.reduceRight(
    (prev, curr) => prev.concat(curr),
    [],
  )

  return (
    <View style={styles.mainBannerContainer}>
      {arrImages.map(
        (image, idx) =>
          idx === 0 ? null : (
            <TouchableWithoutFeedback
              key={image.image_id}
              onPress={() => handleBannerTap(image, image.destination_url_apps)}
            >
              <Image
                source={{ uri: image.file_url }}
                style={
                  idx === 1 ? (
                    styles.mainBannerImageBig
                  ) : (
                      styles.mainBannerImageSmall
                    )
                }
              />
            </TouchableWithoutFeedback>
          ),
      )}
    </View>
  )
}

const styles = StyleSheet.create({
  mainBannerContainer: {
    flex: 1,
    width,
    paddingRight: 15,
    paddingLeft: 15,
    marginBottom: 10,
    flexDirection: 'column',
    justifyContent: 'center',
    alignItems: 'center',
    backgroundColor: '#F8F8F8',
  },
  mainBannerImageBig: {
    width: width - 30,
    height: Math.round(width * .7),
    marginBottom: 10,
    ...Platform.select({
      ios: {
        resizeMode: 'contain',
      },
      android: {
        borderWidth: 1,
        borderRadius: 3,
        borderColor: '#E0E0E0',
        overlayColor: '#FFF',
      },
    }),
  },
  mainBannerImageSmall: {
    width: width - 30,
    height: Math.round(width * 0.7) / 2,
    marginBottom: 10,
    ...Platform.select({
      ios: {
        resizeMode: 'contain',
      },
      android: {
        borderWidth: 1,
        borderRadius: 3,
        borderColor: '#E0E0E0',
        overlayColor: '#FFF',
      },
    }),
  },
})

export default MainBanner
