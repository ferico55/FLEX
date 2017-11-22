import React, { PureComponent } from 'react'
import {
  StyleSheet,
  Image,
  View,
  TouchableOpacity,
  Text,
  TextInput,
  DeviceEventEmitter,
} from 'react-native'
import Navigator from 'native-navigation'
import DeviceInfo from 'react-native-device-info'
import { ReactInteractionHelper } from 'NativeModules'
import { KeyboardAwareScrollView } from 'react-native-keyboard-aware-scroll-view'

import { bindActionCreators } from 'redux'
import { connect } from 'react-redux'
import * as Actions from '../Redux/Actions'
import ImageRow from '../Components/ImageRow'

const styles = StyleSheet.create({
  inputDescription: {
    marginTop: 8,
    marginBottom: 5,
    borderBottomWidth: 1,
    paddingBottom: 2,
    borderColor: 'rgb(224,224,224)',
    fontSize: 17,
    lineHeight: 25,
  },
  imageContainer: {
    borderWidth: 1,
    borderColor: 'rgb(224,224,224)',
    padding: 2,
    borderRadius: 3,
    marginRight: 8,
  },
  deleteContainer: {
    width: 32,
    height: 32,
    backgroundColor: 'rgba(0,0,0,0.55)',
    borderRadius: 32,
    alignItems: 'center',
    justifyContent: 'center',
  },
  deleteTouchable: {
    top: 20,
    right: 8,
    zIndex: 100,
    position: 'absolute',
  },
  saveButtonContainer: {
    borderRadius: 3,
    marginTop: 16,
    backgroundColor: 'rgb(66,181,73)',
    height: 52,
    alignItems: 'center',
    justifyContent: 'center',
    marginBottom: 16,
  },
  imagePreview: {
    flex: DeviceInfo.isTablet() ? 1 : 0,
    resizeMode: 'contain',
    aspectRatio: 1,
  },
})

function mapStateToProps(state) {
  return {
    ...state.uploadImageReducer,
  }
}

function mapDispatchToProps(dispatch) {
  return bindActionCreators(Actions, dispatch)
}

class ImageUploadPage extends PureComponent {
  constructor(props) {
    super(props)
    this.state = {
      description: '',
      size: 0,
    }
  }

  componentDidMount() {
    DeviceEventEmitter.addListener('SET_INVOICE', () => {
      Navigator.pop()
    })
  }

  handleLayout = event => {
    this.setState({
      size: event.nativeEvent.layout.width,
    })
  }

  handleDefaultImagePress = () => {
    const count = this.props.selectedImages.filter(v => v !== 'default').length
    ReactInteractionHelper.showImagePicker(5 - count, images => {
      images.forEach(image => {
        if (image === 'small') {
          ReactInteractionHelper.showDangerAlert(
            'Resolusi gambar terlalu kecil, lebar gambar minimal 300 pixel.',
          )
          return
        }
        const img = {
          uri: image,
        }
        this.props.addImage(img)
      })
    })
  }

  defaultImageHolder = () => (
    <TouchableOpacity onPress={this.handleDefaultImagePress}>
      <View
        style={[
          styles.imageContainer,
          {
            width: (this.state.size - 60) / 5,
            height: (this.state.size - 60) / 5,
          },
        ]}
      >
        <View style={{ padding: 8, flex: 1, backgroundColor: '#f1f1f1' }}>
          <Image
            resizeMode="contain"
            source={{ uri: 'icon_add_picture_small' }}
            style={{ flex: 0, aspectRatio: 1, backgroundColor: '#f1f1f1' }}
          />
        </View>
      </View>
    </TouchableOpacity>
  )

  renderItem = item => {
    if (item.item === 'default') {
      return this.defaultImageHolder()
    }
    return (
      <TouchableOpacity
        key={item.index}
        onPress={() => {
          this.props.updatePreviewImage(item.item.uri, item.index)
        }}
      >
        <View
          style={[
            styles.imageContainer,
            {
              marginRight: item.index === 4 ? 0 : 8,
              width: (this.state.size - 60) / 5,
              height: (this.state.size - 60) / 5,
            },
          ]}
        >
          <Image
            resizeMode="center"
            source={{ uri: item.item.uri }}
            style={{
              flex: 1,
              backgroundColor: '#f1f1f1',
            }}
          />
        </View>
      </TouchableOpacity>
    )
  }

  render = () => (
    <Navigator.Config
      title="Upload Gambar"
      onLeftPress={_ => Navigator.pop()}
      onRightPress={_ => this.handleRightPress()}
    >
      <KeyboardAwareScrollView
        onLayout={this.handleLayout}
        style={{ flex: 1, paddingHorizontal: 8 }}
      >
        <View style={{ marginTop: 8 }}>
          <Image
            source={{ uri: this.props.previewImage.uri }}
            style={styles.imagePreview}
          />
        </View>
        <Text
          style={{ marginTop: 16, color: 'rgba(0,0,0,0.54)', fontSize: 12 }}
        >
          {'Keterangan Gambar'}
        </Text>
        <TextInput
          style={styles.inputDescription}
          placeholder="Tulis deskripsi gambar"
          multiline
          editable={this.props.selectedImages.length > 1}
          value={this.props.previewImage.description}
          onChangeText={value => {
            DeviceEventEmitter.emit('REMOVE_CURRENT_IMAGE')
            this.props.changeDescription(value)
          }}
        />
        <View style={{ marginTop: 12, flexDirection: 'row' }}>
          <ImageRow
            selectedImages={this.props.selectedImages}
            renderImage={this.renderItem}
          />
        </View>
        <TouchableOpacity
          onPress={() => {
            Navigator.pop()
          }}
        >
          <View style={styles.saveButtonContainer}>
            <Text style={{ fontSize: 15, lineHeight: 21, color: 'white' }}>
              {'Simpan'}
            </Text>
          </View>
        </TouchableOpacity>

        {this.props.selectedImages.length > 1 && (
          <TouchableOpacity
            style={styles.deleteTouchable}
            onPress={() => {
              DeviceEventEmitter.emit('REMOVE_CURRENT_IMAGE')
              this.props.removeCurrentImage()
            }}
          >
            <View style={styles.deleteContainer}>
              <Image
                style={{ width: 16, height: 18 }}
                source={{ uri: 'icon_trash_white' }}
              />
            </View>
          </TouchableOpacity>
        )}
      </KeyboardAwareScrollView>
    </Navigator.Config>
  )
}

export default connect(mapStateToProps, mapDispatchToProps)(ImageUploadPage)
