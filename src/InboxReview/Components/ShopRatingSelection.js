import React, { Component } from 'react'
import {
  StyleSheet,
  Text,
  View,
  TouchableOpacity,
  Image,
  ActivityIndicator,
  Alert,
} from 'react-native'

import {
  TKPReactURLManager,
  ReactNetworkManager,
  ReactInteractionHelper,
  TKPReactAnalytics,
} from 'NativeModules'
import entities from 'entities'
import PropTypes from 'prop-types'

const styles = StyleSheet.create({
  scoreContainer: {
    marginTop: 8,
    flexDirection: 'row',
    justifyContent: 'center',
  },
  scoreInnerContainer: {
    paddingTop: 5,
    paddingBottom: 8,
    paddingHorizontal: 16,
    alignItems: 'center',
  },
  lockedText: {
    textAlign: 'center',
    marginBottom: 16,
    paddingHorizontal: 8,
    lineHeight: 21,
  },
  mutedText: {
    color: 'rgba(0,0,0,0.54)',
  },
  scoreText: {
    marginTop: 8,
    fontSize: 12,
    color: 'rgba(0,0,0,0.38)',
  },
  editText: {
    position: 'absolute',
    right: 8,
    top: -16,
    color: 'rgb(66, 181, 73)',
    fontWeight: '500',
  },
  lockedContainer: {
    flex: 1,
    backgroundColor: '#f1f1f1',
    flexDirection: 'row',
    alignItems: 'center',
    paddingVertical: 3,
    justifyContent: 'center',
    borderBottomWidth: 1,
    borderColor: 'rgb(224,224,224)',
  },
  lockedImage: {
    width: 12,
    height: 16,
    resizeMode: 'contain',
    marginRight: 5,
  },
  lockText: {
    textAlign: 'center',
    lineHeight: 21,
    fontSize: 12,
    fontWeight: '500',
  },
})

class ShopRatingSelection extends Component {
  constructor(props) {
    super(props)
    this.state = {
      isLoadingReputation: false,
      isShopFavorited: false,
    }
  }

  handleReputationClick = value => {
    if (value === this.props.reviewerScore) {
      return
    }
    if (this.props.reviewerScore !== 0 && value < this.props.reviewerScore) {
      Alert.alert('Maaf, Anda tidak bisa melakukan penurunan nilai')
      return
    }
    let text
    switch (value) {
      case -1:
        text = 'Kecewa'
        break
      case 1:
        text = 'Netral'
        break
      case 2:
        text = 'Puas'
        break
    }
    Alert.alert(
      '',
      `Beri penilaian ${text} pada ${this.props.revieweeRoleID === 1
        ? 'Pembeli'
        : 'Toko'} ini?`,
      [
        { text: 'Batal' },
        { text: 'Kirim', onPress: () => this.postReputation(value) },
      ],
    )
  }

  postReputation = value => {
    let label = ''
    switch (value) {
      case -1:
        label = 'dissatisfied'
        break
      case 1:
        label = 'neutral'
        break
      case 2:
        label = 'satisfied'
        break
    }
    TKPReactAnalytics.trackEvent({
      name: 'clickReview',
      category: 'inbox review',
      action: 'click reputation',
      label,
    })

    this.setState({
      isLoadingReputation: true,
    })
    const params = {
      buyer_seller: this.props.revieweeRoleID === 1 ? 2 : 1,
      reputation_id: this.props.reputationID,
      reputation_score: value,
    }
    ReactNetworkManager.request({
      method: 'POST',
      baseUrl: TKPReactURLManager.v4Url,
      path: '/reputationapp/reputation/api/v1/insert',
      params,
    })
      .then(response => {
        this.setState(
          {
            isLoadingReputation: false,
            isEditing: false,
          },
          () => {
            if (response.data.is_success === 1) {
              this.props.reviewerScore = value
              this.props.ratingChanged(value)
              if (!this.props.isLast) {
                ReactInteractionHelper.showSuccessAlert(
                  'Anda berhasil memberikan Penilaian',
                )
              }
            } else {
              ReactInteractionHelper.showDangerAlert(response.message_error[0])
            }
          },
        )
      })
      .catch(error => {
        this.setState({
          isLoadingReputation: false,
        })
        ReactInteractionHelper.showDangerAlert(
          'Anda gagal memberikan penilaian',
        )
        console.log(error)
      })
  }

  render() {
    const reviewerScore = this.props.reviewerScore
    if (this.state.isLoadingReputation) {
      return (
        <View style={{ paddingTop: 8, paddingHorizontal: 8 }}>
          <Text style={[styles.mutedText, { textAlign: 'center' }]}>
            {'Bagaimana pengalaman Anda bertransaksi dengan '}
            {this.props.revieweeRoleID === 1 ? '' : 'Toko '}
            <Text style={{ color: 'rgba(0,0,0,0.7)', fontWeight: '500' }}>
              {entities.decodeHTML(this.props.revieweeName)}
            </Text>
            {'?'}
          </Text>
          <View style={[styles.scoreContainer, { paddingVertical: 12 }]}>
            <ActivityIndicator isLoading style={styles.loadingIndicator} />
          </View>
        </View>
      )
    }

    if ((reviewerScore === 0 || this.state.isEditing) && !this.props.isLocked) {
      return (
        <View style={{ paddingTop: 8, paddingHorizontal: 8 }}>
          <Text style={[styles.mutedText, { textAlign: 'center' }]}>
            {'Bagaimana pengalaman Anda bertransaksi dengan '}
            {this.props.revieweeRoleID === 1 ? '' : 'Toko '}
            <Text style={{ color: 'rgba(0,0,0,0.7)', fontWeight: '500' }}>
              {entities.decodeHTML(this.props.revieweeName)}
            </Text>
            {'?'}
          </Text>
          <View style={styles.scoreContainer}>
            <TouchableOpacity
              onPress={() => {
                this.handleReputationClick(-1)
              }}
            >
              <View style={styles.scoreInnerContainer}>
                <Image
                  source={{
                    uri:
                      reviewerScore === 0 || reviewerScore !== -1
                        ? 'icon_sad_grey'
                        : 'icon_sad50',
                  }}
                  style={{ width: 40, height: 40 }}
                />
                <Text style={styles.scoreText}>{'Kecewa'}</Text>
              </View>
            </TouchableOpacity>
            <TouchableOpacity
              onPress={() => {
                this.handleReputationClick(1)
              }}
            >
              <View style={styles.scoreInnerContainer}>
                <Image
                  source={{
                    uri:
                      reviewerScore === 0 || reviewerScore !== 1
                        ? 'icon_neutral_grey'
                        : 'icon_neutral50',
                  }}
                  style={{ width: 40, height: 40 }}
                />
                <Text style={styles.scoreText}>{'Netral'}</Text>
              </View>
            </TouchableOpacity>
            <TouchableOpacity
              onPress={() => {
                this.handleReputationClick(2)
              }}
            >
              <View style={styles.scoreInnerContainer}>
                <Image
                  source={{
                    uri:
                      reviewerScore === 0 || reviewerScore !== 2
                        ? 'icon_smile_grey'
                        : 'icon_smile50',
                  }}
                  style={{ width: 40, height: 40 }}
                />
                <Text style={styles.scoreText}>{'Puas'}</Text>
              </View>
            </TouchableOpacity>
          </View>
        </View>
      )
    }

    if (reviewerScore !== 0) {
      let text = ''
      switch (reviewerScore) {
        case -1:
          text = 'Kecewa'
          break
        case 1:
          text = 'Netral'
          break
        case 2:
          text = 'Puas'
          break
        default:
          text = 'Anda belum memberikan Penilaian'
      }
      return (
        <View style={{ marginTop: this.props.isLocked ? 0 : 12 }}>
          <View>
            {this.props.isLocked && (
              <View style={styles.lockedContainer}>
                {!this.props.isAutoScored && (
                  <Image
                    source={{ uri: 'lock_dimmed' }}
                    style={styles.lockedImage}
                  />
                )}
                <Text style={[styles.mutedText, styles.lockText]}>
                  {this.props.isAutoScored &&
                    'Waktu penilaian telah habis, nilai terisi otomatis'}
                  {!this.props.isAutoScored && 'Penilaian telah disimpan'}
                </Text>
              </View>
            )}
            <Text
              style={[
                styles.mutedText,
                { textAlign: 'center', lineHeight: 21 },
              ]}
            >
              {'Penilaian dari Anda'}
            </Text>
            {reviewerScore !== 2 &&
            !this.props.isLocked && (
              <TouchableOpacity
                onPress={() => {
                  this.setState({
                    isEditing: true,
                  })
                }}
              >
                <Text style={styles.editText}>{'Ubah'}</Text>
              </TouchableOpacity>
            )}
          </View>
          <View style={[styles.scoreContainer, { marginTop: 2 }]}>
            <View style={styles.scoreInnerContainer}>
              <Image
                source={{
                  uri:
                    reviewerScore === -1
                      ? 'icon_sad50'
                      : reviewerScore === 1 ? 'icon_neutral50' : 'icon_smile50',
                }}
                style={{ width: 40, height: 40 }}
              />
              <Text style={[styles.scoreText, { marginTop: 4 }]}>{text}</Text>
            </View>
          </View>
        </View>
      )
    }

    return (
      <View>
        <View style={[styles.scoreContainer, { marginTop: 0 }]}>
          <TouchableOpacity
            onPress={() => {
              Alert.alert('Anda telah melewati batas waktu penilaian')
            }}
          >
            <View
              style={[
                styles.scoreInnerContainer,
                { paddingTop: 16, paddingBottom: 5 },
              ]}
            >
              <Image
                source={{ uri: 'lock' }}
                style={{ width: 24, height: 30, resizeMode: 'contain' }}
              />
            </View>
          </TouchableOpacity>
        </View>
        <Text style={[styles.mutedText, styles.lockedText]}>
          {'Waktu Penilaian telah habis, penilaian terkunci.'}
        </Text>
      </View>
    )
  }
}

ShopRatingSelection.propTypes = {
  reviewerScore: PropTypes.number.isRequired,
  revieweeRoleID: PropTypes.number.isRequired,
  reputationID: PropTypes.number.isRequired,
  ratingChanged: PropTypes.func.isRequired,
  isLast: PropTypes.bool,
  revieweeName: PropTypes.string.isRequired,
  isLocked: PropTypes.bool,
  isAutoScored: PropTypes.bool,
}

ShopRatingSelection.defaultProps = {
  isLast: false,
  isLocked: false,
  isAutoScored: false,
}

export default ShopRatingSelection
