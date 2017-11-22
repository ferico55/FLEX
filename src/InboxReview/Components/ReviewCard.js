import React, { Component } from 'react'
import {
  StyleSheet,
  Text,
  View,
  Image,
  TouchableOpacity,
  Dimensions,
  ActivityIndicator,
  TextInput,
} from 'react-native'
import moment from 'moment'
import entities from 'entities'
import Navigator from 'native-navigation'
import {
  ReactInteractionHelper,
  TKPReactURLManager,
  ReactNetworkManager,
  ReactTPRoutes,
} from 'NativeModules'

import RatingStars from '../../RatingStars'
import ReplyComponent from '../Components/ReplyComponent'
import ReviewCardHeader from '../Components/ReviewCardHeader'
import ImageRow from '../Components/ImageRow'

const styles = StyleSheet.create({
  separator: {
    height: 1,
    flex: 1,
    borderTopWidth: 1,
    borderColor: '#rgb(224,224,224)',
  },
  mutedText: {
    color: 'rgba(0,0,0,0.54)',
  },
  reviewFooterContainer: {
    height: 44,
    paddingHorizontal: 8,
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'center',
  },
  seeReplyText: {
    fontWeight: '500',
    fontSize: 12,
    color: 'rgba(0,0,0,0.54)',
  },
  helpCount: {
    marginLeft: 6,
    fontSize: 12,
    color: 'rgba(0,0,0,0.38)',
  },
  imageContainer: {
    marginRight: 8,
  },
  moreContainer: {
    alignItems: 'center',
    justifyContent: 'center',
    height: 20,
    width: 20,
  },
  mainContainer: {
    backgroundColor: 'white',
    paddingTop: 16,
    borderWidth: 1,
    borderColor: 'rgb(224,224,224)',
  },
})

class ReviewCard extends Component {
  constructor(props) {
    super(props)
    this.state = {
      isReviewExpanded: false,
      isLoading: false,
      isLiked: this.props.item.isLiked,
      likeCount: this.props.item.likeCount,
      isReplyShown: false,
      isLoadingResponse: false,
      response: '',
      userID: this.props.userID,
    }
  }

  getLikeRect = resolve => {
    this.likeSection.measure((fx, fy, w, h, px, py) => {
      const rect = {
        x: 0,
        y: py - 8,
        w,
        h,
      }
      resolve(rect)
    })
  }

  getLikeTag = () => this.likeTag

  getReviewText = () => {
    let text = entities.decodeHTML(this.props.item.review_data.review_message)
    let expandButton = null
    if (text.length > 50 && !this.state.isReviewExpanded) {
      text = `${text.substring(0, 50)}...`
      expandButton = (
        <Text
          onPress={() => {
            this.setState({
              isReviewExpanded: true,
            })
          }}
          style={{ color: 'rgb(66,181,73)' }}
        >
          {'Selengkapnya'}
        </Text>
      )
    }
    return (
      <Text>
        {text}
        {expandButton}
      </Text>
    )
  }

  getReviewerName = item => {
    if (item.review_data.review_anonymity && !this.props.isSensorDisabled) {
      return `${this.props.userData.full_name.substring(
        0,
        1,
      )}***${this.props.userData.full_name.substring(
        this.props.userData.full_name.length - 1,
        this.props.userData.full_name.length,
      )}`
    }
    return this.props.userData.full_name
  }

  handleLikeButtonClick = () => {
    if (this.props.userID === 0) {
      ReactInteractionHelper.ensureLogin((userID, shopID) => {
        this.props.onActionDone(userID, shopID)
      })
      return
    }
    this.setState({
      isLoading: true,
    })

    const params = {
      action: 'event_like_dislike_review',
      review_id: this.props.item.review_id,
      like_status: this.state.isLiked ? 3 : 1, // 1 like, 2 dislike, 3 reset
      product_id: this.props.item.product_data.product_id,
      shop_id: this.props.item.product_data.shop_id,
    }

    ReactNetworkManager.request({
      method: 'POST',
      baseUrl: TKPReactURLManager.v4Url,
      path: '/reputationapp/review/api/v1/likedislike',
      params,
    })
      .then(response => {
        this.setState({
          isLoading: false,
          isLiked: response.data.like_status === 1,
          likeCount:
            response.data.total_like !== undefined
              ? response.data.total_like
              : this.state.likeCount,
        })
      })
      .catch(_ => {
        this.setState({
          isLoading: false,
        })
        ReactInteractionHelper.showDangerAlert('Terjadi kesalahan pada server')
      })
  }

  handleReplyOptionClick = event => {
    ReactInteractionHelper.showPopover(['Hapus'], event.target, index => {
      if (index === 0) {
        this.postDeleteResponse()
      }
    })
  }

  handlePostResponse = () => {
    if (this.state.response.replace(new RegExp(' ', 'g'), '').length < 5) {
      return
    }
    const params = {
      review_id: this.props.item.review_id,
      reputation_id: this.props.item.review_data.reputation_id,
      product_id: this.props.item.product_data.product_id,
      shop_id: this.props.merchantShopID,
      response_message: this.state.response,
      action: 'insert_reputation_review_response',
    }

    this.setState({
      isLoadingResponse: true,
    })

    ReactNetworkManager.request({
      method: 'POST',
      baseUrl: TKPReactURLManager.v4Url,
      path: '/reputationapp/review/api/v1/response/insert',
      params,
    })
      .then(response => {
        this.setState({
          isLoadingResponse: false,
        })
        if (response.data.is_success === 1) {
          this.props.onActionDone()
        } else {
          ReactInteractionHelper.showDangerAlert('Anda gagal memberi balasan')
        }
      })
      .catch(_ => {
        this.setState({
          isLoadingResponse: false,
        })
        ReactInteractionHelper.showDangerAlert('Terjadi kesalahan pada server')
      })
  }

  handleShowPopover = event => {
    this.props.showPopover(event.target)
  }

  postDeleteResponse = () => {
    const params = {
      review_id: this.props.item.review_id,
      product_id: this.props.item.product_data.product_id,
      shop_id: this.props.merchantShopID,
      reputation_id: this.props.item.review_data.reputation_id,
      action: 'input_comment_review',
    }

    this.setState({
      isLoadingResponse: true,
    })

    ReactNetworkManager.request({
      method: 'POST',
      baseUrl: TKPReactURLManager.v4Url,
      path: '/reputationapp/review/api/v1/response/delete',
      params,
    })
      .then(response => {
        this.setState({
          isLoadingResponse: false,
        })
        if (response.data.is_success === 1) {
          this.props.onActionDone()
        } else {
          ReactInteractionHelper.showDangerAlert('Anda Gagal menghapus ulasan')
        }
      })
      .catch(_ => {
        this.setState({
          isLoadingResponse: false,
        })
        ReactInteractionHelper.showDangerAlert('Terjadi kesalahan pada server')
      })
  }

  renderActionSection = () => {
    if (
      this.props.item.review_is_skipped ||
      !this.props.item.review_has_reviewed
    ) {
      return null
    }
    if (this.state.isLoadingResponse) {
      return (
        <View>
          <View style={styles.separator} />
          <View
            style={{ paddingLeft: 30, paddingRight: 8, paddingVertical: 16 }}
          >
            <ActivityIndicator
              animating
              style={[styles.centering, { height: 19 }]}
              size="small"
            />
          </View>
        </View>
      )
    } else if (
      this.props.item.review_data.review_response.response_by !== 0 &&
      this.props.item.review_data.review_response.response_message !== '' &&
      this.state.isReplyShown
    ) {
      return (
        <ReplyComponent
          item={this.props.item}
          merchantShopID={this.props.merchantShopID}
          userID={this.props.userID}
          shopName={this.props.shopName}
          isReplyDisabled={this.props.isReplyDisabled}
          handleReplyOptionClick={this.handleReplyOptionClick}
        />
      )
    } else if (
      this.props.shopID === this.props.merchantShopID &&
      !this.props.isReplyDisabled &&
      (this.props.item.review_data.review_response.response_by === 0 ||
        this.props.item.review_data.review_response.response_message === '')
    ) {
      return (
        <View>
          <View style={styles.separator} />
          <View
            style={{
              backgroundColor: 'rgb(247,247,247)',
              padding: 8,
              flexDirection: 'row',
              alignItems: 'center',
              borderWidth: 1,
              borderColor: 'rgb(224,224,224)',
            }}
          >
            <TextInput
              style={{
                flex: 1,
                borderColor: 'rgb(224,224,224)',
                borderRadius: 16,
                borderWidth: 1,
                paddingVertical: 6,
                paddingHorizontal: 8,
                backgroundColor: 'white',
                fontSize: 14,
                color: 'rgba(0,0,0,0.7)',
                lineHeight: 23,
              }}
              multiline
              numberOfLines={1}
              placeholder="Tulis Balasan"
              returnKeyType="done"
              onChangeText={text => this.setState({ response: text })}
              onFocus={this.props.onFocus}
            />
            <TouchableOpacity onPress={this.handlePostResponse}>
              <Image
                source={{
                  uri:
                    this.state.response.replace(new RegExp(' ', 'g'), '')
                      .length < 5
                      ? 'icon_send_disabled'
                      : 'icon_send',
                }}
                style={{ width: 21, height: 18, marginLeft: 16 }}
              />
            </TouchableOpacity>
          </View>
        </View>
      )
    }
    return null
  }

  renderImage = item => {
    let width = (Dimensions.get('window').width - 60) / 5
    if (width > 75) {
      width = 75
    }
    return (
      <TouchableOpacity
        key={item.index}
        onPress={() => {
          Navigator.present('ImageDetailPage', {
            uri: item.item.uri_large,
            description: item.item.description,
          })
        }}
      >
        <View style={{ marginRight: item.index === 4 ? 0 : 8 }}>
          <Image
            resizeMode="contain"
            source={{ uri: item.item.uri_thumbnail }}
            style={{
              flex: 1,
              borderRadius: 3,
              backgroundColor: '#f1f1f1',
              width,
              height: width,
            }}
          />
        </View>
      </TouchableOpacity>
    )
  }

  renderFooter = () => {
    let likeSection
    if (this.props.isLikeHidden) {
      likeSection = null
    } else if (this.state.isLoading) {
      likeSection = (
        <ActivityIndicator
          animating
          style={[styles.centering, { height: 16 }]}
          size="small"
        />
      )
    } else {
      let likeText
      if (this.state.isLiked) {
        if (this.state.likeCount === 1) {
          likeText = 'Anda terbantu'
        } else {
          likeText = `Anda dan ${this.state.likeCount - 1} orang terbantu`
        }
      } else if (this.state.likeCount === 0) {
        likeText = 'Terbantu?'
      } else {
        likeText = `${this.state.likeCount} orang terbantu`
      }
      likeSection = (
        <View
          ref={v => {
            this.likeSection = v
          }}
          style={{
            flexDirection: 'row',
            alignItems: 'center',
          }}
        >
          <Image
            source={{
              uri: this.state.isLiked
                ? 'icon_thumb_up_active'
                : 'icon_thumb_up',
            }}
            style={{ width: 19, height: 19, marginTop: -3 }}
          />
          <Text style={styles.helpCount}>{likeText}</Text>
        </View>
      )
    }

    let showReplySection = null
    if (
      this.props.item.review_data.review_response.response_by !== 0 &&
      this.props.item.review_data.review_response.response_message !== ''
    ) {
      showReplySection = (
        <TouchableOpacity
          onPress={() => {
            this.setState({
              isReplyShown: !this.state.isReplyShown,
            })
          }}
        >
          <View
            style={{
              flexDirection: 'row',
              alignItems: 'center',
            }}
          >
            <Text style={styles.seeReplyText}>{`${this.state.isReplyShown
              ? 'Tutup'
              : 'Lihat'} Balasan`}</Text>
            <Image
              source={{
                uri: this.state.isReplyShown
                  ? 'icon_arrow_up'
                  : 'icon_arrow_down',
              }}
              style={{ width: 14, height: 9, marginLeft: 5 }}
            />
          </View>
        </TouchableOpacity>
      )
    }

    if (showReplySection === null && this.props.isLikeHidden) {
      return null
    }
    return (
      <View
        style={styles.reviewFooterContainer}
        onLayout={event => {
          this.likeTag = event.target
        }}
      >
        <TouchableOpacity onPress={this.handleLikeButtonClick}>
          {likeSection}
        </TouchableOpacity>
        <View style={{ flex: 1 }} />
        {showReplySection}
      </View>
    )
  }

  render() {
    const isSameYear = moment
      .unix(this.props.item.review_data.review_create_time.unix_timestamp)
      .utcOffset(0)
      .isSame(moment(), 'year')
    const dateFormat = isSameYear ? 'D MMM' : 'D MMM YYYY'
    return (
      <View style={[styles.mainContainer, this.props.style]}>
        <ReviewCardHeader
          item={this.props.item}
          shopID={this.props.shopID}
          isHeaderHidden={this.props.isHeaderHidden}
        />
        {this.props.item.review_has_reviewed &&
        !this.props.item.review_is_skipped && (
          <View>
            <View
              style={{
                paddingTop: this.props.isHeaderHidden ? 0 : 16,
                paddingHorizontal: 8,
              }}
            >
              <View
                style={{
                  flexDirection: 'row',
                  justifyContent: 'space-between',
                  alignItems: 'center',
                }}
              >
                <RatingStars
                  enabled={false}
                  iconSize={20}
                  rating={this.props.item.review_data.review_rating}
                />
                {!this.props.isOptionHidden && (
                  <TouchableOpacity
                    ref={button => {
                      this.optionButton = button
                    }}
                    onPress={this.handleShowPopover}
                  >
                    <View style={styles.moreContainer}>
                      <Image
                        source={{ uri: 'icon_more_grey' }}
                        style={{ height: 3, width: 13 }}
                      />
                    </View>
                  </TouchableOpacity>
                )}
              </View>
              <TouchableOpacity
                onPress={() => {
                  if (
                    this.props.item.review_data.review_anonymity &&
                    !this.props.isSensorDisabled
                  ) {
                    return
                  }
                  ReactTPRoutes.navigate(
                    `tokopedia://user/${this.props.userData.user_id}`,
                  )
                }}
              >
                <Text style={{ marginTop: 16, color: 'rgba(0,0,0,0.54)' }}>
                  {'Oleh '}
                  <Text style={{ color: 'rgba(0,0,0,0.7)', fontWeight: '500' }}>
                    {this.getReviewerName(this.props.item)}
                  </Text>
                </Text>
              </TouchableOpacity>
              <Text style={{ fontSize: 12, color: 'rgba(0,0,0,0.38)' }}>
                {moment
                  .unix(
                    this.props.item.review_data.review_create_time
                      .unix_timestamp,
                  )
                  .utcOffset(0)
                  .format(dateFormat)}
                {this.props.item.review_data.review_update_time &&
                  this.props.item.review_data.review_update_time
                    .unix_timestamp !== '' &&
                  ' (Diubah)'}
              </Text>
              <Text
                style={[
                  styles.mutedText,
                  { marginTop: 8, lineHeight: 21, fontSize: 15 },
                ]}
              >
                {this.getReviewText(this.props.item)}
              </Text>
              <ImageRow
                selectedImages={this.props.item.review_data.review_image_url}
                style={{ marginTop: 16 }}
                renderImage={this.renderImage}
              />
            </View>
            <View style={[styles.separator, { marginTop: 16 }]} />
            {this.renderFooter()}
          </View>
        )}
        {this.renderActionSection()}
      </View>
    )
  }
}

export default ReviewCard
