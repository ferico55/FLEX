import React, { PureComponent } from 'react'
import {
  StyleSheet,
  Text,
  View,
  Image,
  TouchableOpacity,
  ScrollView,
  TextInput,
  Switch,
  Dimensions,
  Alert,
  DeviceEventEmitter,
  ActivityIndicator,
  Keyboard,
} from 'react-native'
import Navigator from 'native-navigation'
import {
  ReactInteractionHelper,
  TKPReactURLManager,
  ReactNetworkManager,
  ReactFileUploader,
  ReactOnboardingHelper,
} from 'NativeModules'
import entities from 'entities'

import { bindActionCreators } from 'redux'
import { connect } from 'react-redux'
import * as Actions from '../Redux/Actions'
import RatingStars from '../../RatingStars'
import ImageRow from '../Components/ImageRow'

function mapStateToProps(state) {
  return {
    ...state.uploadImageReducer,
    ...state.inboxReviewReducer,
  }
}

function mapDispatchToProps(dispatch) {
  return bindActionCreators(Actions, dispatch)
}

const styles = StyleSheet.create({
  sectionTitle: {
    fontSize: 15,
    fontWeight: '500',
    lineHeight: 22,
    color: 'rgba(0,0,0,0.7)',
  },
  mutedText: { color: 'rgba(0,0,0,0.54)' },
  ratingContainer: {
    marginTop: 26,
    flexDirection: 'row',
    alignItems: 'center',
  },
  sectionContainer: {
    marginTop: 8,
    borderWidth: 1,
    borderColor: 'rgb(224,224,224)',
    backgroundColor: 'white',
    paddingVertical: 16,
    paddingHorizontal: 8,
  },
  inputUlasan: {
    marginTop: 8,
    marginBottom: 5,
    borderBottomWidth: 1,
    paddingBottom: 2,
    borderColor: 'rgb(224,224,224)',
    color: 'rgba(0,0,0,0.7)',
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
  switchContainer: {
    marginTop: 7,
    marginBottom: 3,
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'space-between',
  },
  actionButtonText: {
    color: 'rgba(0,0,0,0.28)',
    fontWeight: '500',
    fontSize: 14,
  },
  actionButtonContainer: {
    marginVertical: 16,
    borderRadius: 3,
    marginHorizontal: 8,
    backgroundColor: 'rgb(224,224,224)',
    flex: 1,
    height: 52,
    alignItems: 'center',
    justifyContent: 'center',
  },
  greenPointer: {
    width: 5,
    height: 5,
    borderRadius: 5,
    marginRight: 8,
    marginTop: 9,
    backgroundColor: 'rgb(66,181,73)',
  },
  helpTitle: {
    fontSize: 15,
    lineHeight: 22,
    color: 'rgba(0,0,0,0.54)',
  },
  helpContent: {
    color: 'rgba(0,0,0,0.38)',
    fontSize: 15,
    marginRight: 8,
    lineHeight: 22,
  },
  itemContainer: {
    flexDirection: 'row',
    alignItems: 'flex-start',
  },
  productName: {
    marginLeft: 8,
    color: 'rgba(0,0,0,0.7)',
    fontSize: 16,
    lineHeight: 18,
    fontWeight: '500',
  },
})

class ProductReviewFormPage extends PureComponent {
  constructor(props) {
    super(props)
    this.state = {
      isHelpExpanded: false,
      rating: this.props.review.review_has_reviewed
        ? this.props.review.review_data.review_rating
        : 0,
      isShareToFacebook: false,
      isAnnon: this.props.review.review_has_reviewed
        ? this.props.review.review_data.review_anonymity
        : false,
      review: this.props.review.review_has_reviewed
        ? this.props.review.review_data.review_message
        : '',
      isInputEnabled: true,
      postKey: '',
      imageObjects: {},
      isLoading: false,
      uploadingImage: 0,
      isChangeRequired: this.props.review.review_has_reviewed,
    }

    this.onboardingTag = [0, 0, 0]
    this.onboardingState = -1
    this.onboardingTitle = [
      'Tulis Ulasan dengan Baik',
      'Bagikan ke Facebook',
      'Pilih Profil Ulasan',
    ]
    this.onboardingMessage = [
      'Pelajari tips ini untuk menulis ulasan dengan baik dan balas ulasan pembeli.',
      'Bagikan ulasan Anda secara otomatis ke Facebook.',
      'Pilih profil yang akan ditampilkan pada ulasan. Anda dapat mengubah profil menjadi anonim.',
    ]
    DeviceEventEmitter.addListener('REMOVE_CURRENT_IMAGE', () => {
      this.setState({ isChangeRequired: false })
    })
  }

  componentWillMount() {
    this.props.removeAllImages()
  }

  componentDidMount() {
    const images = this.props.review.review_data.review_image_url.map(
      image => ({
        uri: image.uri_large,
        attachment_id: image.attachment_id,
      }),
    )
    const descriptions = this.props.review.review_data.review_image_url.map(
      image => image.description,
    )
    this.props.addUploadedImages(images, descriptions)

    DeviceEventEmitter.addListener('SET_INVOICE', () => {
      Navigator.pop()
    })
  }

  getRatingText = () => {
    switch (this.state.rating) {
      case 1:
        return 'Sangat Buruk'
      case 2:
        return 'Buruk'
      case 3:
        return 'Cukup'
      case 4:
        return 'Baik'
      case 5:
        return 'Sangat Baik'
      default:
        return 'Beri Peringkat'
    }
  }

  getAnnonName = () =>
    `${this.props.authInfo.full_name.substring(
      0,
      1,
    )}***${this.props.authInfo.full_name.substring(
      this.props.authInfo.full_name.length - 1,
      this.props.authInfo.full_name.length,
    )}`

  getInputText = () => {
    if (this.state.review.replace(new RegExp(' ', 'g'), '').length === 0) {
      return 'Minimal 20 karakter'
    } else if (
      this.state.review.replace(new RegExp(' ', 'g'), '').length < 20
    ) {
      return `${20 -
        this.state.review.replace(new RegExp(' ', 'g'), '')
          .length} karakter lagi`
    }
    return 'Hebat!'
  }

  refreshListView = () => {
    this.props.setParams(
      this.props.params[this.props.invoicePageIndex],
      this.props.invoicePageIndex,
    )
  }

  defaultImageHolder = () => {
    let width = (Dimensions.get('window').width - 60) / 5
    if (width > 75) {
      width = 75
    }
    return (
      <TouchableOpacity onPress={this.handleDefaultImagePress}>
        <View style={[styles.imageContainer, { width, height: width }]}>
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
  }

  skipReview = () => {
    const params = {
      product_id: this.props.review.product_data.product_id,
      reputation_id: this.props.reputationId,
      shop_id: this.props.merchantShopID,
    }
    ReactNetworkManager.request({
      method: 'POST',
      baseUrl: TKPReactURLManager.v4Url,
      path: '/reputationapp/review/api/v1/skip',
      params,
    })
      .then(response => {
        if (response.data.is_success === 1) {
          if (!this.props.isLast) {
            ReactInteractionHelper.showSuccessAlert(
              'Anda berhasil melewati ulasan ini',
            )
          }
          this.setState(
            {
              isLoading: false,
            },
            () => {
              Navigator.pop()
            },
          )
          try {
            this.refreshListView()
            DeviceEventEmitter.emit('REFRESH_INVOICE_DETAIL', this.props.isLast)
          } catch (e) {
            console.log(e)
          }
        } else {
          ReactInteractionHelper.showDangerAlert(response.message_error[0])
        }
        this.props.enableInteraction()
      })
      .catch(error => {
        console.log(error)
        ReactInteractionHelper.showDangerAlert('Anda gagal melewati ulasan ini')
      })
  }

  generateHost = imageData => {
    ReactNetworkManager.request({
      method: 'GET',
      baseUrl: TKPReactURLManager.v4Url,
      path: '/v4/action/generate-host/generate_host.pl',
      params: {
        new_add: 1,
      },
    })
      .then(response => {
        this.setState(
          {
            generatedHost: response.data.generated_host,
            uploadingImage: imageData.imageIds.length,
          },
          () => {
            this.uploadAllImage(imageData.imageIds)
          },
        )
      })
      .catch(error => {
        this.props.enableInteraction()
        ReactInteractionHelper.showDangerAlert('Terjadi kesalahan pada server')
        this.setState({
          isInputEnabled: true,
          isLoading: false,
        })
        console.log(error)
      })
  }

  sleep = ms => new Promise(resolve => setTimeout(resolve, ms))

  generateImageArray = () => {
    const images = {}
    const imageIds = []
    this.props.selectedImages.forEach((image, index) => {
      if (image === 'default') {
        return
      }
      const id = image.attachment_id
        ? image.attachment_id
        : Math.round(
            `${new Date().getTime()}${Math.floor(Math.random() * 100)}`,
          )

      images[id] = {
        is_deleted: '0',
        file_desc: this.props.imageDescriptions[index]
          ? this.props.imageDescriptions[index].replace(
              new RegExp(' ', 'g'),
              '',
            )
          : '',
        attachment_id: image.attachment_id ? `${image.attachment_id}` : '0',
      }

      imageIds.push(id)
    })
    return {
      images,
      imageIds,
    }
  }

  generateRemovedImageArray = () => {
    const imageObject = {}
    this.props.review.review_data.review_image_url
      .filter(image => {
        for (let i = 0; i < this.props.selectedImages.length; i++) {
          if (
            this.props.selectedImages[i].attachment_id === image.attachment_id
          ) {
            return false
          }
        }
        return true
      })
      .map(image => {
        imageObject[image.attachment_id] = {
          is_deleted: '1',
          file_desc: '',
          attachment_id: `${image.attachment_id}`,
        }
        return image
      })

    return imageObject
  }

  validateReview = () => {
    const imageData = this.generateImageArray()
    const imageIds = imageData.imageIds.join('~')
    const images = imageData.images

    const params = {
      product_id: this.props.review.product_data.product_id,
      shop_id: this.props.merchantShopID,
      has_product_review_photo: imageIds.length > 0 ? 1 : 0,
      product_review_photo_all: imageIds,
      product_review_photo_obj: JSON.stringify(images),
      review_id: this.props.review.review_id,
      reputation_id: this.props.reputationId,
      review_message: this.state.review.trim(),
      rate_quality: this.state.rating,
      user_id: this.props.authInfo.user_id,
      anonymous: this.state.isAnnon,
    }

    ReactNetworkManager.request({
      method: 'POST',
      baseUrl: TKPReactURLManager.v4Url,
      path: '/reputationapp/review/api/v1/insert/validate',
      params,
    })
      .then(response => {
        if (response.data.is_success === 1) {
          this.setState({
            postKey: response.data.post_key,
          })
          if (imageIds.length > 0) {
            this.generateHost(imageData)
          }
        } else {
          this.props.enableInteraction()
          this.setState({
            isLoading: false,
            isInputEnabled: true,
          })
          ReactInteractionHelper.showDangerAlert(response.message_error[0])
          return
        }

        if (imageIds.length === 0) {
          if (!this.props.isLast) {
            ReactInteractionHelper.showSuccessAlert(
              'Anda telah berhasil mengisi ulasan',
            )
          }
          this.setState(
            {
              isLoading: false,
            },
            () => {
              Navigator.pop()
            },
          )
          try {
            this.props.enableInteraction()
            this.refreshListView()
            DeviceEventEmitter.emit('REFRESH_INVOICE_DETAIL', this.props.isLast)
          } catch (e) {
            console.log(e)
          }
        }
      })
      .catch(error => {
        this.props.enableInteraction()
        this.setState({
          isLoading: false,
          isInputEnabled: true,
        })
        ReactInteractionHelper.showDangerAlert('Terjadi kesalahan pada server')
        console.log(error)
      })
  }

  uploadAllImage = imageIds => {
    const host = `https://${this.state.generatedHost.upload_host}`
    let uploadingImage = imageIds.length
    const imageObjects = {}

    if (this.props.selectedImages.length === 0) {
      if (!this.props.review.review_has_reviewed) {
        this.submitReview(imageIds, imageObjects)
      } else {
        this.submitEditReview(imageIds, imageObjects)
      }
    }

    this.props.selectedImages.forEach((item, index) => {
      if (item === 'default') {
        return
      }

      if (item.attachment_id && item.attachment_id !== 0) {
        uploadingImage -= 1

        if (uploadingImage === 0) {
          if (!this.props.review.review_has_reviewed) {
            this.submitReview(imageIds, imageObjects)
          } else {
            this.submitEditReview(imageIds, imageObjects)
          }
        }
        return
      }

      const imageId = imageIds[index]
      ReactFileUploader.uploadImage(host, item.uri, `${imageId}`)
        .then(imageObject => {
          imageObjects[imageId] = imageObject

          uploadingImage -= 1
          if (uploadingImage === 0) {
            if (!this.props.review.review_has_reviewed) {
              this.submitReview(imageIds, imageObjects)
            } else {
              this.submitEditReview(imageIds, imageObjects)
            }
          }
        })
        .catch(error => {
          this.props.enableInteraction()
          this.setState({
            isLoading: false,
            isInputEnabled: true,
          })
          ReactInteractionHelper.showDangerAlert(
            'Gagal upload gambar, harap coba kembali',
          )
          console.log(error)
        })
    })
  }

  submitEditReview = (imageIds, imageObjects) => {
    const params = {
      post_key: this.state.postKey,
      has_product_review_photo: imageIds.length > 0 ? 1 : 0,
      file_uploaded: JSON.stringify(imageObjects),
      reputation_id: this.props.reputationId,
      product_id: this.props.review.product_data.product_id,
      shop_id: this.props.merchantShopID,
    }

    ReactNetworkManager.request({
      method: 'POST',
      baseUrl: TKPReactURLManager.v4Url,
      path: '/reputationapp/review/api/v1/edit/submit',
      params,
    })
      .then(response => {
        if (response.data.is_success === 1) {
          if (!this.props.isLast) {
            ReactInteractionHelper.showSuccessAlert(
              'Anda telah berhasil mengubah ulasan',
            )
          }
          this.setState(
            {
              isLoading: false,
            },
            () => {
              Navigator.pop()
            },
          )
          try {
            this.refreshListView()
            DeviceEventEmitter.emit('REFRESH_INVOICE_DETAIL', false)
          } catch (e) {
            console.log(e)
          }
        } else {
          this.setState({
            isLoading: false,
            isInputEnabled: true,
          })
          ReactInteractionHelper.showDangerAlert(response.message_error[0])
        }
        this.props.enableInteraction()
      })
      .catch(error => {
        this.props.enableInteraction()
        console.log(error)
        this.setState({
          isLoading: false,
          isInputEnabled: true,
        })
        ReactInteractionHelper.showDangerAlert('Terjadi kesalahan pada server')
      })
  }

  submitReview = (imageIds, imageObjects) => {
    const params = {
      post_key: this.state.postKey,
      has_product_review_photo: imageIds.length > 0 ? 1 : 0,
      file_uploaded: JSON.stringify(imageObjects),
    }

    ReactNetworkManager.request({
      method: 'POST',
      baseUrl: TKPReactURLManager.v4Url,
      path: '/reputationapp/review/api/v1/insert/submit',
      params,
    })
      .then(response => {
        if (response.data.is_success === 1) {
          if (!this.props.isLast) {
            ReactInteractionHelper.showSuccessAlert(
              'Anda telah berhasil mengisi ulasan',
            )
          }
          this.setState(
            {
              isLoading: false,
            },
            () => {
              Navigator.pop()
            },
          )
          try {
            this.refreshListView()
            DeviceEventEmitter.emit('REFRESH_INVOICE_DETAIL', this.props.isLast)
          } catch (e) {
            console.log(e)
          }
        } else {
          this.setState({
            isLoading: false,
            isInputEnabled: true,
          })
          ReactInteractionHelper.showDangerAlert(response.message_error[0])
        }
        this.props.enableInteraction()
      })
      .catch(error => {
        this.props.enableInteraction()
        console.log(error)
        this.setState({
          isLoading: false,
          isInputEnabled: true,
        })
        ReactInteractionHelper.showDangerAlert('Terjadi kesalahan pada server')
      })
  }

  postReview = () => {
    this.setState(
      {
        isInputEnabled: false,
        isLoading: true,
      },
      () => {
        this.props.disableInteraction()
        if (!this.props.review.review_has_reviewed) {
          this.validateReview()
        } else {
          this.validateEditReview()
        }
      },
    )
  }

  validateEditReview = () => {
    const imageData = this.generateImageArray()
    const prevImageIds = this.props.review.review_data.review_image_url
      .map(image => image.attachment_id)
      .filter(id => !imageData.imageIds.includes(id))
    const imageIds = imageData.imageIds.concat(prevImageIds).join('~')
    const images = {
      ...imageData.images,
      ...this.generateRemovedImageArray(),
    }
    imageData.images = images

    const params = {
      product_id: this.props.review.product_data.product_id,
      shop_id: this.props.merchantShopID,
      has_product_review_photo: imageIds.length > 0 ? 1 : 0,
      product_review_photo_all: imageIds,
      product_review_photo_obj: JSON.stringify(images),
      review_id: this.props.review.review_id,
      reputation_id: this.props.reputationId,
      review_message: this.state.review.trim(),
      rate_quality: this.state.rating,
      user_id: this.props.authInfo.user_id,
      anonymous: this.state.isAnnon ? 1 : 0,
    }

    ReactNetworkManager.request({
      method: 'POST',
      baseUrl: TKPReactURLManager.v4Url,
      path: '/reputationapp/review/api/v1/edit/validate',
      params,
    })
      .then(response => {
        if (response.data.is_success === 1) {
          this.setState({
            postKey: response.data.post_key,
          })
        } else {
          this.props.enableInteraction()
          this.setState({
            isLoading: false,
            isInputEnabled: true,
          })
          ReactInteractionHelper.showDangerAlert(response.message_error[0])
          return
        }

        if (response.data.post_key === '') {
          if (!this.props.isLast) {
            ReactInteractionHelper.showSuccessAlert(
              'Anda telah berhasil mengubah ulasan',
            )
          }
          this.setState(
            {
              isLoading: false,
            },
            () => {
              Navigator.pop()
            },
          )
          try {
            this.props.enableInteraction()
            this.refreshListView()
            DeviceEventEmitter.emit('REFRESH_INVOICE_DETAIL', false)
          } catch (e) {
            console.log(e)
          }
        } else {
          this.generateHost(imageData)
        }
      })
      .catch(error => {
        this.props.enableInteraction()
        this.setState({
          isLoading: false,
          isInputEnabled: true,
        })
        ReactInteractionHelper.showDangerAlert('Terjadi kesalahan pada server')
        console.log(error)
      })
  }

  handleRightPress = () => {
    const showAlert = keyboardListener => {
      Alert.alert(
        'Lewati Ulasan',
        'Produk ini sudah pernah Anda beli sebelumnya, Anda dapat melewati ulasan produk ini',
        [
          {
            text: 'Batal',
            onPress: () => {
              if (keyboardListener) {
                keyboardListener.remove()
              }
            },
          },
          {
            text: 'Lewati',
            onPress: () => {
              this.skipReview()
              if (keyboardListener) {
                keyboardListener.remove()
              }
            },
          },
        ],
      )
    }
    if (!this.refs.textInput.isFocused()) {
      showAlert()
      return
    }

    const keyboardHideListener = Keyboard.addListener('keyboardDidHide', () => {
      showAlert(keyboardHideListener)
    })
    Keyboard.dismiss()
  }

  validateInput = () => {
    if (this.state.rating === 0) {
      return false
    }
    return !this.state.isChangeRequired
  }

  showOnboarding = index => {
    if (index < 0 || index > 2) {
      return
    }
    this.props.disableOnboardingScroll()
    this.onboardingState = index

    if (index === 1) {
      this.scrollView.scrollToEnd({ animated: false })
    } else if (index === 0) {
      this.scrollView.scrollTo({ x: 0, y: 0, animated: false })
    }

    const target = this.onboardingTag[index]
    setTimeout(() => {
      ReactOnboardingHelper.showInboxOnboarding(
        {
          title: this.onboardingTitle[index],
          message: this.onboardingMessage[index],
          currentStep: index + 1,
          totalStep: 3,
          anchor: target,
        },
        status => {
          switch (status) {
            case -1:
              // cancel
              this.props.enableOnboardingScroll()
              break
            case 0:
              this.onboardingState -= 1
              this.showOnboarding(this.onboardingState)
              // prev
              break
            default:
              if (index === 2) {
                this.props.enableOnboardingScroll()
                ReactOnboardingHelper.disableOnboarding(
                  'review_form_onboarding',
                  `${this.props.authInfo.user_id}`,
                )
              }
              this.onboardingState += 1
              this.showOnboarding(this.onboardingState)
          }
        },
      )
    }, 200)
  }

  handleLayout = (event, index) => {
    this.onboardingTag[index] = event.target
    if (index === 0 && this.onboardingState === -1) {
      this.onboardingState = 0
      setTimeout(() => {
        ReactOnboardingHelper.getOnboardingStatus(
          'review_form_onboarding',
          `${this.props.authInfo.user_id}`,
          isOnboardingShown => {
            if (!isOnboardingShown) {
              this.setState(
                {
                  isHelpExpanded: true,
                },
                () => {
                  this.showOnboarding(0)
                },
              )
            }
          },
        )
      }, 100)
    }
  }

  handleDefaultImagePress = () => {
    if (!this.state.isInputEnabled) {
      return
    }

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

      const c = this.props.selectedImages.filter(v => v !== 'default').length
      if (c > 0) {
        Navigator.push('ImageUploadPage')
        this.setState({
          isChangeRequired: false,
        })
      }
    })
  }

  renderItem = item => {
    if (item.item === 'default') {
      return this.defaultImageHolder()
    }
    let width = (Dimensions.get('window').width - 60) / 5
    if (width > 75) {
      width = 75
    }
    return (
      <TouchableOpacity
        key={item.index}
        onPress={() => {
          if (!this.state.isInputEnabled) {
            return
          }
          this.props.updatePreviewImage(item.item.uri, item.index)
          Navigator.push('ImageUploadPage')
        }}
      >
        <View
          style={[
            styles.imageContainer,
            {
              marginRight: item.index === 4 ? 0 : 8,
              width,
              height: width,
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

  render() {
    const skipButton = this.props.review.review_is_skippable
      ? [
          {
            title: 'Lewati',
            foregroundColor: 'rgb(0,0,0,0.54)',
          },
        ]
      : []
    return (
      <Navigator.Config
        title="Ulasan Produk"
        onRightPress={_ => this.handleRightPress()}
        rightButtons={skipButton}
      >
        <ScrollView
          style={{ backgroundColor: '#f1f1f1', flex: 1 }}
          ref={scrollView => {
            this.scrollView = scrollView
          }}
        >
          <View style={styles.sectionContainer}>
            <View style={styles.itemContainer}>
              <Image
                source={{
                  uri:
                    this.props.review.product_data.product_status === 0
                      ? 'icon_product_deleted'
                      : this.props.review.product_data.product_image_url,
                }}
                style={{ width: 52, height: 52, borderRadius: 3 }}
              />
              <Text style={styles.productName}>
                {this.props.review.product_data.product_status === 0 ? (
                  'Produk telah dihapus'
                ) : (
                  entities.decodeHTML(
                    this.props.review.product_data.product_name,
                  )
                )}
              </Text>
            </View>
          </View>
          <View style={styles.sectionContainer}>
            <Text style={styles.sectionTitle}>{'Kualitas Produk'}</Text>
            <View style={styles.ratingContainer}>
              <RatingStars
                ref={rating => {
                  this.rating = rating
                }}
                enabled={this.state.isInputEnabled}
                rating={this.state.rating}
                onStarPressed={rating => {
                  this.setState({ rating, isChangeRequired: false })
                }}
              />
              <Text style={[styles.mutedText, { marginLeft: 8 }]}>
                {this.getRatingText()}
              </Text>
            </View>
          </View>

          <View
            onLayout={event => {
              this.handleLayout(event, 0)
            }}
            style={{ marginTop: 8 }}
          >
            <TouchableOpacity
              onPress={() => {
                this.setState({ isHelpExpanded: !this.state.isHelpExpanded })
              }}
            >
              <View
                style={[
                  styles.sectionContainer,
                  { flexDirection: 'row', alignItems: 'center', marginTop: 0 },
                ]}
              >
                <Image
                  source={{ uri: 'icon_bulb' }}
                  style={{
                    width: 16,
                    height: 19,
                    marginLeft: 2,
                    marginRight: 8,
                  }}
                />
                <Text style={styles.sectionTitle}>{'Tips Menulis Ulasan'}</Text>
                <View style={{ flex: 1 }} />
                {this.state.isHelpExpanded && (
                  <Image
                    source={{ uri: 'icon_up_green' }}
                    style={{ width: 14, height: 9 }}
                  />
                )}
                {!this.state.isHelpExpanded && (
                  <Image
                    source={{ uri: 'icon_down_green' }}
                    style={{ width: 14, height: 9 }}
                  />
                )}
              </View>
            </TouchableOpacity>
            {this.state.isHelpExpanded && (
              <View
                style={[
                  styles.sectionContainer,
                  { marginTop: 0, paddingTop: 8 },
                ]}
              >
                <View
                  style={{ flexDirection: 'row', alignItems: 'flex-start' }}
                >
                  <View style={styles.greenPointer} />
                  <View>
                    <Text style={styles.helpTitle}>
                      {'Kesesuaian dengan deskripsi'}
                    </Text>
                    <Text style={styles.helpContent}>
                      {
                        '"Ukuran dan warna sesuai dengan foto dan deskripsi produk yang dijual"'
                      }
                    </Text>
                  </View>
                </View>

                <View
                  style={{
                    flexDirection: 'row',
                    alignItems: 'flex-start',
                    marginTop: 8,
                  }}
                >
                  <View style={styles.greenPointer} />
                  <View>
                    <Text style={styles.helpTitle}>{'Fungsional Produk'}</Text>
                    <Text style={styles.helpContent}>
                      {
                        '"Produk bekerja dengan baik, tidak cepat rusak walau sudah dipakai berkali-kali"'
                      }
                    </Text>
                  </View>
                </View>

                <View
                  style={{
                    flexDirection: 'row',
                    alignItems: 'flex-start',
                    marginTop: 8,
                  }}
                >
                  <View style={styles.greenPointer} />
                  <View>
                    <Text style={styles.helpTitle}>{'Rekomendasi Produk'}</Text>
                    <Text style={styles.helpContent}>
                      {
                        '"Saya senang produknya dipaketkan dengan rapi dan tidak ada cacat. Recommended"'
                      }
                    </Text>
                  </View>
                </View>
              </View>
            )}
          </View>

          <View style={styles.sectionContainer}>
            <Text style={[styles.mutedText, { fontSize: 12, lineHeight: 18 }]}>
              {'Ulasan Produk'}
            </Text>
            <TextInput
              ref="textInput"
              style={styles.inputUlasan}
              placeholder="Tulis ulasan produk Anda"
              value={this.state.review}
              editable={this.state.isInputEnabled}
              onChangeText={value => {
                this.setState({ review: value, isChangeRequired: false })
              }}
              multiline
            />
            <Text style={[styles.mutedText, { fontSize: 12 }]}>
              {this.getInputText()}
            </Text>
          </View>

          <View style={styles.sectionContainer}>
            <View style={{ flexDirection: 'row', alignItems: 'center' }}>
              <Text style={styles.sectionTitle}>{'Upload Gambar Produk'}</Text>
              <TouchableOpacity
                onPress={() => {
                  ReactInteractionHelper.showAlternativeTooltip(
                    'Upload Gambar Produk',
                    'Anda dapat mengupload 5 gambar dengan format.JPG, .JPEG, .PNG. Maksimal ukuran gambar 8 MB',
                    'icon_image',
                    'Tutup',
                  )
                }}
              >
                <Image
                  source={{ uri: 'icon_information' }}
                  style={{ width: 16, height: 16, marginLeft: 4 }}
                />
              </TouchableOpacity>
            </View>
            <ImageRow
              style={{ marginTop: 16 }}
              selectedImages={this.props.selectedImages}
              renderImage={this.renderItem}
            />
          </View>

          <View
            style={styles.sectionContainer}
            onLayout={event => {
              this.handleLayout(event, 1)
            }}
          >
            <View style={styles.switchContainer}>
              <Text
                style={[styles.mutedText, { fontSize: 17, lineHeight: 25 }]}
              >
                {'Bagikan ke Facebook'}
              </Text>
              <Switch
                disabled={this.props.review.product_data.product_status === 0}
                value={this.state.isShareToFacebook}
                onValueChange={value =>
                  this.setState({ isShareToFacebook: value })}
              />
            </View>
          </View>
          <View
            onLayout={event => {
              this.handleLayout(event, 2)
            }}
            style={[styles.sectionContainer, { marginTop: 1 }]}
          >
            <View style={styles.switchContainer}>
              <View>
                <Text
                  style={[styles.mutedText, { fontSize: 17, lineHeight: 25 }]}
                >
                  {'Anonim'}
                </Text>
                <Text style={{ color: 'rgba(0,0,0,0.38)', fontSize: 12 }}>
                  {'Profil ditampilkan sebagai '}
                  {this.getAnnonName()}
                </Text>
              </View>
              <Switch
                value={this.state.isAnnon}
                onValueChange={value =>
                  this.setState({ isAnnon: value, isChangeRequired: false })}
              />
            </View>
          </View>

          <TouchableOpacity
            onPress={() => {
              if (this.validateInput() && this.state.isInputEnabled) {
                this.setState({
                  isInputEnabled: false,
                })
                if (
                  this.state.isShareToFacebook &&
                  this.props.review.product_data.product_status !== 0
                ) {
                  ReactInteractionHelper.shareToFacebook(
                    this.state.review,
                    `${this.props.review.product_data.product_id}`,
                    this.props.review.product_data.product_page_url,
                    () => {
                      this.setState(
                        {
                          isLoading: true,
                        },
                        () => {
                          this.postReview()
                        },
                      )
                    },
                  )
                } else {
                  this.postReview()
                }
              }
            }}
          >
            <View
              style={[
                styles.actionButtonContainer,
                {
                  backgroundColor:
                    this.validateInput() && this.state.isInputEnabled
                      ? 'rgb(66,181,73)'
                      : 'rgb(224,224,224)',
                },
              ]}
            >
              {this.state.isLoading && (
                <ActivityIndicator
                  animating
                  style={{ height: 44 }}
                  size="small"
                />
              )}
              {!this.state.isLoading && (
                <Text
                  style={[
                    styles.actionButtonText,
                    {
                      color: this.validateInput()
                        ? 'white'
                        : 'rgba(0,0,0,0.28)',
                    },
                  ]}
                >
                  {'Kirim'}
                </Text>
              )}
            </View>
          </TouchableOpacity>
        </ScrollView>
      </Navigator.Config>
    )
  }
}

export default connect(mapStateToProps, mapDispatchToProps)(
  ProductReviewFormPage,
)
