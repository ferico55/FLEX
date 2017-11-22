import React, { Component } from 'react'
import {
  StyleSheet,
  View,
  FlatList,
  ActivityIndicator,
  NativeEventEmitter,
  Dimensions,
} from 'react-native'

import {
  TKPReactURLManager,
  ReactNetworkManager,
  ReactInteractionHelper,
  EventManager,
  ReactOnboardingHelper,
} from 'NativeModules'
import Navigator from 'native-navigation'
import Rx from 'rxjs/Rx'
import DeviceInfo from 'react-native-device-info'

import ReviewCard from '../Components/ReviewCard'
import NoResultView from '../../NoResultView'

const nativeTabEmitter = new NativeEventEmitter(EventManager)
const styles = StyleSheet.create({})

class ShopReviewPage extends Component {
  constructor(props) {
    super(props)
    this.state = {
      isLoading: true,
      reviewList: [],
      page: 1,
      isError: false,
      ownerData: null,
      productData: null,
      authInfo: this.props.authInfo,
    }

    this.onboardingState = -1
    this.loadData$ = new Rx.Subject()
    this.onboardingRef = 0
  }

  componentDidMount() {
    this.loadData()

    this.subscription = nativeTabEmitter.addListener('shouldRefresh', () => {
      this.handleRefresh()
    })

    this.subscriptionLoadData = this.loadData$
      .debounceTime(1000)
      .subscribe(page => {
        this.loadData(page)
      })
  }

  showOnboarding = () => {
    if (this.onboardingState === 0) {
      return
    }
    this.onboardingState = 0
    ReactOnboardingHelper.showShopOnboarding(
      {
        title: 'Terbantu dengan Ulasan',
        message: 'Tap tombol like jika ulasan tersebut membantu Anda.',
        currentStep: 1,
        totalStep: 1,
        anchor: this.onboardingRef.getLikeTag(),
      },
      status => {
        switch (status) {
          case 1:
            ReactOnboardingHelper.disableOnboarding(
              'review_shop_onboarding',
              `${this.state.authInfo ? this.state.authInfo.user_id : 0}`,
            )
            // done
            break
          default:
          // cancel
        }
      },
    )
  }

  handleActionDone = (userID, shopID) => {
    this.setState(
      {
        authInfo: {
          ...this.state.authInfo,
          user_id: userID,
          shop_id: shopID,
        },
      },
      () => {
        this.handleRefresh()
      },
    )
  }

  handleRefresh = () => {
    this.setState(
      {
        reviewList: [],
        page: 1,
      },
      () => {
        this.loadData()
      },
    )
  }

  loadData = (page = 1) => {
    if (page < 1) {
      return
    }
    this.setState({
      isLoading: true,
    })
    const params = {
      shop_domain: this.props.shopDomain,
      shop_id: this.props.shopID,
      page,
      per_page: 8,
    }

    Rx.Observable
      .fromPromise(
        ReactNetworkManager.request({
          method: 'GET',
          baseUrl: TKPReactURLManager.v4Url,
          path: '/reputationapp/review/api/v1/shop',
          params,
        }),
      )
      .flatMap(reviews => {
        const reviewIds = reviews.data.list.map(item => item.review_id)
        if (reviewIds.length === 0) {
          return Rx.Observable.of(reviews)
        }

        return Rx.Observable
          .fromPromise(
            ReactNetworkManager.request({
              method: 'GET',
              baseUrl: TKPReactURLManager.v4Url,
              path: '/reputationapp/review/api/v1/likedislike',
              params: {
                review_ids: reviewIds.join('~'),
              },
            }),
          )
          .map(response => {
            const result = reviews.data.list.map(item => {
              const likeData = response.data.list.find(
                like => like.review_id === item.review_id,
              )

              return {
                ...item,
                likeCount: likeData.total_like,
                isLiked: likeData.like_status === 1,
              }
            })
            return {
              ...reviews,
              data: {
                ...reviews.data,
                list: result,
              },
            }
          })
      })
      .map(response => {
        console.log(response)
        const list = response.data.list.map(item => ({
          likeCount: item.likeCount,
          isLiked: item.isLiked,
          reputation_id: item.reputation_id,
          review_id: item.review_id,
          review_has_reviewed: true,
          review_is_skipped: false,
          review_is_editable: false,
          review_data: {
            review_id: item.review_id,
            reputation_id: 0,
            review_title: item.review_title,
            review_message: item.review_message,
            review_rating: item.product_rating,
            review_anonymity: item.review_anonymous,
            review_image_url: item.review_image_attachment,
            review_create_time: item.review_create_time,
            review_response: {
              ...item.review_response,
              response_create_time: item.review_response.response_time,
              response_by: response.data.owner.user.user_id,
            },
          },
          is_reportable: item.is_reportable,
          product_data: {
            ...item.product,
            product_status: item.product.product_name === '' ? 0 : 1,
            product_id: `${item.product.product_id}`,
            shop_id: `${response.data.owner.shop.shop_id}`,
          },
          user: item.user,
        }))

        return {
          ...response,
          data: {
            ...response.data,
            list,
          },
        }
      })
      .subscribe(
        reviews => {
          this.setState({
            isLoading: false,
            isError: false,
            ownerData: {
              shop: {
                ...reviews.data.owner.shop,
                shop_id: `${reviews.data.owner.shop.shop_id}`,
              },
              user: {
                ...reviews.data.owner.user,
                user_id: `${reviews.data.owner.user.user_id}`,
              },
            },
            productData: reviews.data.product,
            reviewList: this.state.reviewList.concat(reviews.data.list),
            page: reviews.data.paging.uri_next === '' ? -1 : page + 1,
          })
        },
        err => {
          console.log(err)
          this.setState({
            isError: true,
            isLoading: false,
          })
          ReactInteractionHelper.showDangerAlert(
            'Terjadi gangguan pada koneksi.',
          )
        },
      )
  }

  renderSeparatorView = () => <View style={{ marginTop: 8 }} />

  renderFooter = () => {
    if (this.state.isLoading) {
      return (
        <ActivityIndicator
          animating
          style={[styles.centering, { height: 44 }]}
          size="small"
        />
      )
    } else if (this.state.isError && this.state.reviewList.length === 0) {
      return (
        <NoResultView
          titleText="Kendala koneksi internet"
          onRefresh={() => {
            this.handleRefresh()
          }}
        />
      )
    } else if (!this.state.isLoading && this.state.reviewList.length === 0) {
      return (
        <NoResultView
          isPreHidden
          titleText="Belum ada ulasan"
          subtitleText=" "
          isButtonHidden
        />
      )
    }
    return null
  }

  renderItem = item => (
    <View
      style={{
        backgroundColor: 'white',
        marginHorizontal: DeviceInfo.isTablet() ? 114 : 0,
      }}
      onLayout={() => {
        if (this.onboardingRef === 0) {
          return
        }
        ReactOnboardingHelper.getOnboardingStatus(
          'review_shop_onboarding',
          `${this.state.authInfo ? this.state.authInfo.user_id : 0}`,
          isOnboardingShown => {
            if (!isOnboardingShown) {
              this.showOnboarding()
            }
          },
        )
      }}
    >
      <ReviewCard
        ref={v => {
          if (this.onboardingRef === 0) {
            this.onboardingRef = v
          }
        }}
        item={item.item}
        userID={this.state.authInfo ? parseInt(this.state.authInfo.user_id) : 0}
        shopID={this.state.authInfo ? parseInt(this.state.authInfo.shop_id) : 0}
        merchantShopID={this.state.ownerData.shop.shop_id}
        userData={item.item.user}
        isLikeHidden={false}
        isReplyDisabled
        shopName={this.state.ownerData.shop.shop_name}
        onActionDone={this.handleActionDone}
        isSensorDisabled={
          this.state.authInfo &&
          this.state.authInfo.shop_id === this.state.ownerData.shop.shop_id
        }
        style={{ borderRadius: 3 }}
        isOptionHidden={item.item.is_reportable === 0}
        showPopover={target => {
          const options = ['Laporkan']
          ReactInteractionHelper.showPopover(options, target, index => {
            if (index === 0) {
              Navigator.push('ReportReviewPage', {
                data: item.item,
                shopID: this.state.ownerData.shop.shop_id,
              })
            }
          })
        }}
      />
    </View>
  )

  renderHeader = () => <View style={{ marginTop: 8 }} />

  render() {
    return (
      <View style={{ flex: 1, backgroundColor: 'rgb(242,242,242)' }}>
        <FlatList
          style={{ flex: 1, backgroundColor: 'rgb(242,242,242)' }}
          renderItem={this.renderItem}
          data={this.state.reviewList}
          refreshing={false}
          onRefresh={this.handleRefresh}
          keyExtractor={item => item.review_id}
          ListFooterComponent={this.renderFooter}
          ListHeaderComponent={this.renderHeader}
          ItemSeparatorComponent={this.renderSeparatorView}
          scrollEventThrottle={200}
          onScroll={({
            nativeEvent: { contentOffset: { y }, contentSize: { height } },
          }) => {
            const windowHeight = Dimensions.get('window').height
            if (windowHeight + y >= height) {
              if (!this.state.isLoading) {
                if (this.state.isErrorOnScroll) {
                  this.loadData$.next(this.state.page)
                } else {
                  this.loadData(this.state.page)
                }
              }
            }
          }}
        />
      </View>
    )
  }
}

export default ShopReviewPage
