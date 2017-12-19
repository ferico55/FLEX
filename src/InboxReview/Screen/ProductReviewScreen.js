import React, { Component } from 'react'
import {
  StyleSheet,
  Text,
  FlatList,
  SectionList,
  View,
  ProgressViewIOS,
  Image,
  ActivityIndicator,
  TouchableOpacity,
  RefreshControl,
  Dimensions,
} from 'react-native'

import Navigator from 'native-navigation'
import {
  TKPReactURLManager,
  ReactNetworkManager,
  ReactInteractionHelper,
  ReactOnboardingHelper,
} from 'NativeModules'
import Rx from 'rxjs/Rx'
import DeviceInfo from 'react-native-device-info'
import PropTypes from 'prop-types'
import { bindActionCreators } from 'redux'
import { connect } from 'react-redux'

import ReviewCard from '../Components/ReviewCard'
import RatingStars from '../../RatingStars'
import NoResultView from '../../NoResultView'
import * as Actions from '../Redux/Actions'

function mapStateToProps(state) {
  return {
    ...state.inboxReviewReducer,
  }
}

function mapDispatchToProps(dispatch) {
  return bindActionCreators(Actions, dispatch)
}

const styles = StyleSheet.create({
  starContainer: {
    flexDirection: 'row',
    justifyContent: 'center',
    paddingHorizontal: 8,
    flex: 1,
    alignItems: 'center',
    marginBottom: 3,
  },
  selectionContainer: {
    paddingHorizontal: 12,
    paddingVertical: 7,
    backgroundColor: 'white',
    borderRadius: 3,
    marginRight: 8,
    flexDirection: 'row',
    alignItems: 'center',
    borderWidth: 1,
    borderColor: 'rgb(224,224,224)',
  },
  selectionText: {
    fontSize: 12,
    lineHeight: 18,
    color: 'rgb(66, 181, 73)',
    fontWeight: '500',
  },
  ratingContainer: {
    fontSize: 32,
    lineHeight: 33,
    color: 'rgb(74,74,74)',
    fontWeight: '600',
    marginBottom: 8,
  },
  verticalSeparator: {
    backgroundColor: 'rgb(224,224,224)',
    width: 1,
    height: '100%',
  },
  centering: {
    alignItems: 'center',
    justifyContent: 'center',
    padding: 8,
  },
  selectedStar: {
    borderWidth: 1,
    borderColor: 'rgb(66,181,73)',
  },
})

class ProductReviewScreen extends Component {
  constructor(props) {
    super(props)
    this.state = {
      isError: false,
      isLoading: true,
      isLoadingHeader: true,
      isLoadingHelpful: true,
      selection: ['Semua', 1, 2, 3, 4, 5],
      headerData: null,
      selectedStar: 0,
      page: 1,
      ownerData: null,
      authInfo: this.props.authInfo,
      productData: null,
      reviews: [
        { data: [], title: 'Ulasan Paling Membantu' },
        { data: [], title: 'Semua Ulasan' },
      ],
    }

    this.loadReviews$ = new Rx.Subject()
    this.onboardingTitle = ['Filter Ulasan', 'Terbantu dengan Ulasan']
    this.onboardingMessage = [
      'Lihat ulasan dari pembeli berdasarkan jumlah bintang yang diberikan.',
      'Tap tombol like jika ulasan tersebut membantu Anda.',
    ]
    this.onboardingRefs = [0, 0]
    this.onboardingTags = [0, 0]
    this.onboardingState = -1
  }

  componentDidMount() {
    this.loadData()
    this.props.disableOnboardingScroll()

    this.subscriptionLoadData = this.loadReviews$
      .debounceTime(1000)
      .subscribe(page => {
        this.loadReviews(page)
      })
  }

  startOnboarding = () => {
    if (this.onboardingState > -1) {
      return
    }

    this.onboardingState = 0
    this.showOnboarding(this.onboardingTags[0], 0)
  }

  showOnboarding = (target, index) => {
    if (index !== this.onboardingState) {
      return
    }
    if (index < 0 || index > 1) {
      return
    }
    ReactOnboardingHelper.showInboxOnboarding(
      {
        title: this.onboardingTitle[index],
        message: this.onboardingMessage[index],
        currentStep: index + 1,
        totalStep: 2,
        anchor: index === 0 ? target : this.onboardingRefs[index].getLikeTag(),
      },
      status => {
        switch (status) {
          case 1:
            // next
            if (this.onboardingState === 1) {
              this.props.enableOnboardingScroll()
              ReactOnboardingHelper.disableOnboarding(
                'product_onboarding',
                `${this.state.authInfo ? this.state.authInfo.user_id : 0}`,
              )
            }
            this.onboardingState += 1
            this.showOnboarding(
              this.onboardingTags[this.onboardingState],
              this.onboardingState,
            )
            break
          case 0:
            // prev
            this.onboardingState -= 1
            this.showOnboarding(
              this.onboardingTags[this.onboardingState],
              this.onboardingState,
            )
            break
          default:
            this.props.enableOnboardingScroll()
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
    this.setState({
      reviews: [
        { data: [], title: 'Ulasan Paling Membantu' },
        { data: [], title: 'Semua Ulasan' },
      ],
      page: 1,
      ownerData: null,
      productData: null,
    })
    this.loadData()
  }

  loadReviews = (page = 1) => {
    if (page === -1) {
      this.setState({
        isLoading: false,
      })
      return
    }

    const params = {
      product_id: this.props.productID,
      page,
      per_page: 8,
      rating: this.state.selectedStar,
    }

    Rx.Observable
      .fromPromise(
        ReactNetworkManager.request({
          method: 'GET',
          baseUrl: TKPReactURLManager.v4Url,
          path: '/reputationapp/review/api/v1/product',
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
        const list = response.data.list.map(item => ({
          likeCount: item.likeCount,
          isLiked: item.isLiked,
          reputation_id: item.reputation_id,
          review_id: item.review_id,
          review_has_reviewed: true,
          review_is_skipped: false,
          review_is_editable: false,
          is_reportable: item.is_reportable,
          review_data: {
            review_id: item.review_id,
            reputation_id: 0,
            review_title: item.review_title,
            review_message: item.review_message,
            review_rating: item.product_rating,
            review_image_url: item.review_image_attachment,
            review_create_time: item.review_create_time,
            review_anonymity: item.review_anonymous,
            review_response: {
              ...item.review_response,
              response_create_time: item.review_response.response_time,
            },
          },
          product_data: {
            ...response.data.product,
            product_id: `${response.data.product.product_id}`,
            shop_id: `${response.data.owner.shop.shop_id}`,
            product_status: 1,
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
            reviews: [
              ...this.state.reviews.slice(0, 1),
              {
                data: this.state.reviews[1].data.concat(reviews.data.list),
                title: 'Semua Ulasan',
              },
            ],
            page:
              reviews.data.paging.uri_next === '' ? -1 : this.state.page + 1,
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

  loadMostHelpful = () => {
    Rx.Observable
      .fromPromise(
        ReactNetworkManager.request({
          method: 'GET',
          baseUrl: TKPReactURLManager.v4Url,
          path: '/reputationapp/review/api/v1/mosthelpful',
          params: {
            product_id: this.props.productID,
          },
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
        const list = response.data.list.map(item => ({
          likeCount: item.likeCount,
          isLiked: item.isLiked,
          reputation_id: item.reputation_id,
          review_id: item.review_id,
          review_has_reviewed: true,
          review_is_skipped: false,
          review_is_editable: false,
          is_reportable: item.is_reportable,
          review_data: {
            review_id: item.review_id,
            reputation_id: 0,
            review_title: item.review_title,
            review_message: item.review_message,
            review_rating: item.product_rating,
            review_image_url: item.review_image_attachment,
            review_anonymity: item.review_anonymous,
            review_create_time: item.review_create_time,
            review_response: {
              ...item.review_response,
              response_create_time: item.review_response.response_time,
            },
          },
          product_data: {
            ...response.data.product,
            product_id: `${response.data.product.product_id}`,
            shop_id: `${response.data.owner.shop.shop_id}`,
            product_status: 1,
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
            isLoadingHelpful: false,
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
            reviews: [
              {
                data: reviews.data.list,
                title: 'Ulasan Paling Membantu',
              },
              ...this.state.reviews.slice(1, 2),
            ],
          })
        },
        err => {
          console.log(err)
          this.setState({
            isLoadingHelpful: false,
          })
          ReactInteractionHelper.showDangerAlert(
            'Terjadi gangguan pada koneksi.',
          )
        },
      )
  }

  loadData = () => {
    this.setState({
      isLoading: true,
      isLoadingHeader: true,
      isLoadingHelpful: true,
    })

    ReactNetworkManager.request({
      method: 'GET',
      baseUrl: TKPReactURLManager.v4Url,
      path: '/reputationapp/review/api/v1/rating',
      params: {
        product_id: this.props.productID,
      },
    })
      .then(response => {
        if (response.data) {
          this.setState({
            headerData: response.data,
            isLoadingHeader: false,
          })
        } else {
          ReactInteractionHelper.showDangerAlert(response.message_error[0])
        }
      })
      .catch(err => {
        console.log(err)
        ReactInteractionHelper.showDangerAlert('Terjadi gangguan pada koneksi.')
      })

    this.loadMostHelpful()
    this.loadReviews(1)
  }

  renderStars = _ => {
    let stars = []
    const detail = this.state.headerData.detail
    if (!detail) {
      for (let i = 5; i > 0; i--) {
        stars.push(
          <View key={i} style={styles.starContainer}>
            <RatingStars enabled={false} iconSize={8} rating={i} spacing={2} />
            <ProgressViewIOS
              style={{ flex: 1, marginLeft: 8, marginRight: 5 }}
              progressViewStyle="bar"
              progress={0}
              progressTintColor="rgb(255,194,0)"
              trackTintColor="rgb(224,224,224)"
            />
            <Text style={{ fontSize: 11, color: 'rgba(0,0,0,0.38)', width: 8 }}>
              {0}
            </Text>
          </View>,
        )
      }
    } else {
      let width = 8
      const reviewCounts = detail.map(star => star.total_review)
      let max = Math.max.apply(null, reviewCounts)
      while (max / 8 > 1) {
        width += 8
        max /= 8
      }

      stars = detail.map((star, i) => {
        let percentage = star.percentage.replace(',', '.').replace('%', '')
        percentage = parseFloat(percentage) / 100.0
        return (
          <View key={i} style={styles.starContainer}>
            <RatingStars
              enabled={false}
              iconSize={8}
              rating={star.rate}
              spacing={2}
            />
            <ProgressViewIOS
              style={{ flex: 1, marginLeft: 8, marginRight: 5 }}
              progressViewStyle="bar"
              progress={percentage}
              progressTintColor="rgb(255,194,0)"
              trackTintColor="rgb(224,224,224)"
            />
            <Text style={{ fontSize: 11, color: 'rgba(0,0,0,0.38)', width }}>
              {star.total_review}
            </Text>
          </View>
        )
      })
    }

    return stars
  }

  renderSelection = item => (
    <TouchableOpacity
      onPress={() => {
        if (this.state.isLoading) {
          return
        }
        this.setState(
          {
            isLoading: true,
            selectedStar: item.index,
            reviews: [
              ...this.state.reviews.slice(0, 1),
              { data: [], title: 'Semua Ulasan' },
            ],
          },
          () => {
            this.loadReviews(1, item.index)
          },
        )
      }}
    >
      <View
        style={[
          styles.selectionContainer,
          item.index === this.state.selectedStar ? styles.selectedStar : null,
          {
            marginLeft: item.item === 'Semua' && !DeviceInfo.isTablet() ? 8 : 0,
            width: DeviceInfo.isTablet() ? 80 : 'auto',
            justifyContent: 'center',
          },
        ]}
      >
        <Text
          style={[
            styles.selectionText,
            {
              color:
                item.index === this.state.selectedStar
                  ? 'rgb(66,181,73)'
                  : 'rgba(0,0,0,0.54)',
            },
          ]}
        >
          {item.item}
        </Text>
        {item.item !== 'Semua' && (
          <Image
            source={{
              uri:
                item.index === this.state.selectedStar
                  ? 'icon_star_active'
                  : 'icon_star',
            }}
            style={{ width: 10, height: 10, marginLeft: 7 }}
          />
        )}
      </View>
    </TouchableOpacity>
  )

  renderItem = item => {
    if (
      item.section.title === 'Ulasan Paling Membantu' &&
      this.state.selectedStar !== 0
    ) {
      return null
    }
    return (
      <View
        style={{
          backgroundColor: 'white',
          marginHorizontal: DeviceInfo.isTablet() ? 114 : 0,
        }}
        onLayout={event => {
          this.onboardingTags[1] = event.target
        }}
      >
        <ReviewCard
          item={item.item}
          ref={v => {
            if (this.onboardingRefs[1] === 0) {
              this.onboardingRefs[1] = v
            }
          }}
          userID={
            this.state.authInfo ? parseInt(this.state.authInfo.user_id) : 0
          }
          shopID={
            this.state.authInfo ? parseInt(this.state.authInfo.shop_id) : 0
          }
          merchantShopID={this.state.ownerData.shop.shop_id}
          userData={item.item.user}
          isLikeHidden={false}
          isSensorDisabled={
            this.state.authInfo &&
            parseInt(this.state.authInfo.shop_id) ===
              this.state.ownerData.shop.shop_id
          }
          isReplyDisabled
          shopName={this.state.ownerData.shop.shop_name}
          onActionDone={this.handleActionDone}
          style={{ borderRadius: 3 }}
          isOptionHidden={item.item.is_reportable === 0}
          showPopover={target => {
            const options = ['Laporkan']
            ReactInteractionHelper.showPopover(options, target, index => {
              if (index === 0) {
                Navigator.push('ReportReviewScreen', {
                  data: item.item,
                  shopID: this.state.ownerData.shop.shop_id,
                })
              }
            })
          }}
          isHeaderHidden
        />
      </View>
    )
  }

  renderSeparatorView = item => {
    if (
      item.section.title === 'Ulasan Paling Membantu' &&
      this.state.selectedStar !== 0
    ) {
      return null
    }
    return <View style={{ marginTop: 8 }} />
  }

  renderSectionHeader = item => {
    if (
      (item.section.title === 'Ulasan Paling Membantu' &&
        this.state.selectedStar !== 0) ||
      item.section.data.length === 0
    ) {
      return null
    }
    return (
      <View
        style={{
          backgroundColor: 'rgb(242,242,242)',
          paddingBottom: 16,
          paddingTop: 8,
          paddingHorizontal: DeviceInfo.isTablet() ? 114 : 8,
        }}
      >
        <Text
          style={{
            fontSize: 13,
            fontWeight: '600',
            lineHeight: 19,
            color: 'rgba(0,0,0,0.54)',
          }}
        >
          {item.section.title}
        </Text>
        {item.section.title === 'Ulasan Paling Membantu' &&
        this.state.isLoadingHelpful && (
          <ActivityIndicator
            animating
            style={[styles.centering, { height: 44 }]}
            size="small"
          />
        )}
      </View>
    )
  }

  renderSectionFooter = () => <View style={{ height: 8 }} />

  renderFooter = () => {
    if (this.state.isError && this.state.reviews[1].data.length === 0) {
      return (
        <NoResultView
          titleText="Kendala koneksi internet"
          onRefresh={() => {
            this.loadData()
          }}
        />
      )
    } else if (
      !this.state.isLoading &&
      this.state.reviews[1].data.length === 0
    ) {
      return (
        <NoResultView
          isPreHidden
          titleText="Belum ada ulasan"
          subtitleText=" "
          isButtonHidden
        />
      )
    } else if (this.state.page === -1 && !this.state.isLoading) {
      return null
    }

    return (
      <ActivityIndicator
        animating
        style={[styles.centering, { height: 44 }]}
        size="small"
      />
    )
  }

  renderHeader = () => {
    if (this.state.isLoadingHeader) {
      return (
        <View style={{ flex: 1, backgroundColor: 'white', padding: 36 }}>
          <ActivityIndicator
            animating
            style={[styles.centering, { height: 44 }]}
            size="small"
          />
        </View>
      )
    }
    return (
      <View style={{ flex: 1, backgroundColor: 'white' }}>
        <View
          style={{
            flexDirection: 'row',
            flex: 1,
            borderBottomWidth: 1,
            borderColor: 'rgb(224,224,224)',
            paddingHorizontal: DeviceInfo.isTablet() ? 114 : 0,
          }}
        >
          <View
            style={{
              paddingVertical: 16,
              paddingHorizontal: 8,
              alignItems: 'center',
            }}
          >
            <Text style={styles.ratingContainer}>
              {this.state.headerData.rating_score}
              <Text style={{ fontSize: 14, color: 'rgb(74,74,74)' }}>
                {'/5'}
              </Text>
            </Text>
            <RatingStars
              enabled={false}
              iconSize={14}
              rating={Math.round(this.state.headerData.rating_score)}
              spacing={3}
            />
            <Text
              style={{ marginTop: 8, fontSize: 12, color: 'rgba(0,0,0,0.38)' }}
            >
              {`${this.state.headerData.total_review} Ulasan`}
            </Text>
          </View>
          <View style={styles.verticalSeparator} />
          <View style={{ paddingVertical: 16, paddingRight: 8, flex: 1 }}>
            {this.renderStars()}
          </View>
        </View>

        <View
          style={{
            backgroundColor: 'rgb(242,242,242)',
            paddingHorizontal: DeviceInfo.isTablet() ? 114 : 0,
          }}
          ref={v => {
            this.onboardingRefs[0] = v
          }}
          onLayout={event => {
            this.onboardingTags[0] = event.target
            if (this.onboardingTags[0] === 0) {
              return
            }
            ReactOnboardingHelper.getOnboardingStatus(
              'product_onboarding',
              `${this.state.authInfo ? this.state.authInfo.user_id : 0}`,
              isOnboardingShown => {
                if (!isOnboardingShown) {
                  this.startOnboarding()
                } else {
                  this.props.enableOnboardingScroll()
                }
              },
            )
          }}
        >
          <FlatList
            scrollEnabled={this.props.isOnboardingScrollEnabled}
            style={{ marginVertical: 8, flex: 1 }}
            renderItem={this.renderSelection}
            horizontal
            keyExtractor={item => item}
            data={this.state.selection}
          />
        </View>
      </View>
    )
  }

  render() {
    return (
      <Navigator.Config title="Ulasan">
        <SectionList
          style={{ flex: 1, backgroundColor: 'rgb(242,242,242)' }}
          extraData={this.state.headerData}
          scrollEnabled={this.props.isOnboardingScrollEnabled}
          ListHeaderComponent={this.renderHeader}
          sections={this.state.reviews}
          renderItem={this.renderItem}
          renderSectionHeader={this.renderSectionHeader}
          ItemSeparatorComponent={this.renderSeparatorView}
          ListFooterComponent={this.renderFooter}
          renderSectionFooter={this.renderSectionFooter}
          refreshing={false}
          keyExtractor={item => item.review_id}
          refreshControl={
            <RefreshControl refreshing={false} onRefresh={this.handleRefresh} />
          }
          onScroll={({
            nativeEvent: { contentOffset: { y }, contentSize: { height } },
          }) => {
            const windowHeight = Dimensions.get('window').height
            if (windowHeight + y >= height) {
              if (!this.state.isLoading) {
                if (this.state.isError) {
                  this.setState(
                    {
                      isLoading: true,
                    },
                    () => {
                      this.loadReviews$.next(this.state.page)
                    },
                  )
                } else {
                  this.setState(
                    {
                      isLoading: true,
                    },
                    () => {
                      this.loadReviews(this.state.page)
                    },
                  )
                }
              }
            }
          }}
        />
      </Navigator.Config>
    )
  }
}

ProductReviewScreen.propTypes = {
  authInfo: PropTypes.object,
  productID: PropTypes.string.isRequired,
}

ProductReviewScreen.defaultProps = {
  authInfo: null,
}

export default connect(mapStateToProps, mapDispatchToProps)(ProductReviewScreen)
