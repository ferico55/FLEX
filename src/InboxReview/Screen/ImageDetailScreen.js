import React, { PureComponent } from 'react'
import {
  StyleSheet,
  Text,
  View,
  Image,
  StatusBar,
  TouchableOpacity,
  CameraRoll,
} from 'react-native'
import Navigator from 'native-navigation'
import { ReactInteractionHelper } from 'NativeModules'
import PropTypes from 'prop-types'

const styles = StyleSheet.create({
  headerContainer: {
    position: 'absolute',
    top: 33,
    width: '100%',
    paddingHorizontal: 8,
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'space-between',
    zIndex: 100,
  },
  textContainer: {
    position: 'absolute',
    bottom: 0,
    width: '100%',
    zIndex: 101,
  },
  captionText: {
    color: 'white',
    fontSize: 14,
    lineHeight: 21,
    marginHorizontal: 8,
    marginVertical: 16,
    backgroundColor: 'rgba(0,0,0,0)',
  },
})

class ImageDetailScreen extends PureComponent {
  constructor(props) {
    super(props)
    this.state = {
      isReady: false,
    }
  }

  handleDownload = () => {
    CameraRoll.saveToCameraRoll(this.props.uri)
      .then(_ => {
        ReactInteractionHelper.showSuccessAlert(
          'Anda berhasil menyimpan gambar',
        )
      })
      .catch(_ => {
        ReactInteractionHelper.showDangerAlert('Anda gagal menyimpan gambar')
      })
  }

  handleClose = () => {
    Navigator.dismiss()
  }

  handleLayout = () => {
    this.setState(
      {
        isReady: true,
      },
      () => {
        ReactInteractionHelper.hideNavigationBar()
      },
    )
  }

  render() {
    return (
      <Navigator.Config hidden statusBarStyle="light" foregroundColor="white">
        <View
          onLayout={this.handleLayout}
          style={{ flex: 1, backgroundColor: 'black' }}
        >
          <StatusBar backgroundColor="black" barStyle="light-content" />
          <View style={styles.headerContainer}>
            <TouchableOpacity onPress={this.handleClose}>
              <View
                style={{
                  height: 24,
                  width: 24,
                  justifyContent: 'center',
                  alignItems: 'center',
                }}
              >
                <Image
                  source={{ uri: 'icon_cancel_white' }}
                  style={{ width: 16, height: 16 }}
                />
              </View>
            </TouchableOpacity>
            <TouchableOpacity onPress={this.handleDownload}>
              <Image
                source={{ uri: 'icon_download' }}
                style={{ width: 19, height: 24 }}
              />
            </TouchableOpacity>
          </View>
          <View
            style={{ flex: 1, justifyContent: 'center', alignItems: 'center' }}
          >
            <Image
              source={{ uri: this.props.uri }}
              style={{ width: '100%', aspectRatio: 1 }}
            />
          </View>
          {this.props.description !== '' && (
            <View style={styles.textContainer}>
              <Image
                source={{ uri: 'icon_gradient' }}
                style={{ height: '100%', width: '100%', position: 'absolute' }}
              />
              <Text style={styles.captionText}>{this.props.description}</Text>
              <Image />
            </View>
          )}
        </View>
      </Navigator.Config>
    )
  }
}

ImageDetailScreen.propTypes = {
  uri: PropTypes.string.isRequired,
}

export default ImageDetailScreen
