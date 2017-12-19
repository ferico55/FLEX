import React, { PureComponent } from 'react'
import {
  StyleSheet,
  Text,
  View,
  Image,
  FlatList,
  TouchableOpacity,
  ActivityIndicator,
  Alert,
  DeviceEventEmitter,
  findNodeHandle,
  RefreshControl,
} from 'react-native'
import Navigator from 'native-navigation'
import entities from 'entities'
import {
  TKPReactURLManager,
  ReactNetworkManager,
  ReactInteractionHelper,
  ReactTPRoutes,
} from 'NativeModules'
import PropTypes from 'prop-types'
import DeviceInfo from 'react-native-device-info'

import { bindActionCreators } from 'redux'
import { connect } from 'react-redux'
import { KeyboardAwareScrollView } from 'react-native-keyboard-aware-scroll-view'

import * as Actions from '../Redux/Actions'
import NoResultView from '../../NoResultView'
import ReviewCard from '../Components/ReviewCard'
import FavoriteButton from '../Components/FavoriteButton'
import ReviewReminder from '../Components/ReviewReminder'
import DynamicSizeImage from '../Components/DynamicSizeImage'
import ShopRatingSelection from '../Components/ShopRatingSelection'
import ReputationModal from '../Components/ReputationModal'

function mapStateToProps(state) {
  return {
    ...state.inboxReviewReducer,
  }
}

function mapDispatchToProps(dispatch) {
  return bindActionCreators(Actions, dispatch)
}

const styles = StyleSheet.create({
  mutedText: {
    color: 'rgba(0,0,0,0.54)',
  },
  title: {
    color: 'rgba(0,0,0,0.7)',
    fontSize: 16,
    lineHeight: 21,
    marginBottom: 2,
  },
  revieweeScoreContainer: {
    flexDirection: 'row',
    justifyContent: 'center',
    alignItems: 'center',
    borderBottomWidth: 1,
    borderColor: 'rgb(224,224,224)',
  },
  revieweeText: {
    marginVertical: 9,
    fontSize: 12,
    color: 'rgba(0,0,0,0.38)',
  },
  separator: {
    height: 1,
    flex: 1,
    borderTopWidth: 1,
    borderColor: '#rgb(224,224,224)',
  },
  revieweeScoreImage: {
    width: 16,
    height: 16,
    marginLeft: 6,
    resizeMode: 'contain',
  },
  loadingIndicator: {
    width: 16,
    height: 16,
    marginVertical: 28,
    alignSelf: 'center',
  },
  reviewHeaderContainer: {
    paddingVertical: 16,
    paddingHorizontal: 8,
    flexDirection: 'row',
    borderBottomWidth: 1,
    borderColor: 'rgb(224,224,224)',
  },
  buyerBadge: {
    height: 18,
    borderRadius: 3,
    borderWidth: 1,
    borderColor: 'rgb(66,181,73)',
    paddingHorizontal: 2,
    flexDirection: 'row',
    alignItems: 'center',
  },
  noResultContainer: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
    backgroundColor: 'white',
  },
})

class InvoiceDetailScreen extends PureComponent {
  constructor(props) {
    super(props)

    this.state = {
      dataSource: [],
      isLoading: false,
      isError: false,
      isRefreshing: false,
      selectedImages: ['thumb_product', 'thumb_product'],
      userData: {},
      isLoadingReputation: false,
      isEditing: false,
      reputationId: 0,
      isVisible: false,
      buttonRect: {},
      modalVisible: false,
      topOffset: 0,
      item: this.props.item,
      actionsLeft:
        (this.props.item &&
          !this.props.item.isNotification &&
          this.props.item.reputation_data.reviewer_score) === 0
          ? 1
          : 0,
      isNotification: this.props.item ? this.props.item.isNotification : false,
    }

    this.item = this.props.item
  }

  componentDidMount() {
    if (!this.state.isNotification) {
      this.loadData()
    }

    DeviceEventEmitter.addListener('REFRESH_INVOICE_DETAIL', isLast => {
      if (!this.props.item) {
        return
      }
      this.loadData()
      if (isLast) {
        this.showCompleteNotification()
      }
    })

    DeviceEventEmitter.addListener('SET_INVOICE', () => {
      setTimeout(() => {
        this.loadData()
      }, 150)

      if (this.props.item !== null) {
        this.item = this.props.item
      }
    })

    DeviceEventEmitter.addListener('REVIEW_NOTIFICATION', () => {
      this.handleRefresh()
    })
  }

  getActionLeftCount = () => {
    let count = this.state.dataSource.reduce(
      (value, item) =>
        value + (item.review_has_reviewed || item.review_is_skipped ? 0 : 1),
      0,
    )

    if (
      this.item &&
      this.item.reputation_data.reviewer_score === 0 &&
      !this.item.reputation_data.is_locked
    ) {
      count += 1
    }

    return count
  }

  refreshListView = () => {
    this.props.setParams(
      this.props.params[this.props.invoicePageIndex],
      this.props.invoicePageIndex,
    )
  }

  showCompleteNotification = () => {
    const text = `Ulasan untuk ${this.item.reviewee_data
      .reviewee_name} sudah selesai`
    ReactInteractionHelper.showSuccessAlert(text)
    if (DeviceInfo.isTablet()) {
      this.props.resetInvoice()
    } else {
      Navigator.pop()
    }
  }

  checkAction = isReputation => {
    let count = this.getActionLeftCount()
    if (isReputation) {
      count -= 1
    }

    if (count <= 0) {
      const text = `Ulasan untuk ${this.props.item.reviewee_data
        .reviewee_name} sudah selesai`
      ReactInteractionHelper.showSuccessAlert(text)
      if (DeviceInfo.isTablet()) {
        this.props.resetInvoice()
      } else {
        Navigator.pop()
      }
    }
  }

  loadData = () => {
    if (!this.props.item || this.state.isLoading) {
      return
    }
    this.setState(
      {
        isLoading: true,
        dataSource: [],
      },
      () => {
        if (!this.props.item) {
          return
        }
        ReactNetworkManager.request({
          method: 'GET',
          baseUrl: TKPReactURLManager.v4Url,
          path: '/reputationapp/review/api/v1/list',
          params: {
            reputation_id: this.props.item.reputation_id,
            role: this.props.item.reviewee_data.reviewee_role_id === 1 ? 2 : 1,
          },
        })
          .then(result => {
            const inboxData = result.data.review_inbox_data.map(data => ({
              ...data,
              product_data: {
                ...data.product_data,
                shop_id: `${data.product_data.shop_id}`,
              },
              review_data: {
                ...data.review_data,
                review_response: {
                  ...data.review_data.review_response,
                  response_by: `${data.review_data.review_response
                    .response_by}`,
                },
              },
            }))
            const response = {
              ...result,
              data: {
                ...result.data,
                shop_data: {
                  ...result.data.shop_data,
                  shop_id: `${result.data.shop_data.shop_id}`,
                  shop_user_id: `${result.data.shop_data.shop_user_id}`,
                },
                user_data: {
                  ...result.data.user_data,
                  user_id: `${result.data.user_data.user_id}`,
                },
                review_inbox_data: inboxData,
              },
            }
            this.setState({
              isLoading: false,
              reputationId: response.data.reputation_id,
              dataSource: this.state.dataSource.concat(
                response.data.review_inbox_data,
              ),
              isError: false,
              isNotification: false,
              userData: response.data.user_data,
            })
          })
          .catch(error => {
            console.log(error)
            this.setState({
              isLoading: false,
              isError: true,
              isNotification: false,
            })
            ReactInteractionHelper.showDangerAlert(
              'Terjadi gangguan pada koneksi.',
            )
          })
      },
    )
  }

  navigateToDetail = (uri, isSeller) => {
    const parts = uri.split('/')
    const id = parts[parts.length - 1]

    if (isSeller) {
      ReactTPRoutes.navigate(`tokopedia://${id}`)
    } else {
      ReactTPRoutes.navigate(`tkpd-internal://user/${id}`)
    }
  }

  handleRefresh = () => {
    if (!this.props.item) {
      return
    }
    this.setState(
      {
        dataSource: [],
        isLoading: false,
      },
      () => {
        const params = {
          ...this.props.params[this.props.invoicePageIndex],
          reputation_id: this.props.item.reputation_id,
        }
        ReactNetworkManager.request({
          method: 'GET',
          baseUrl: TKPReactURLManager.v4Url,
          path: '/reputationapp/reputation/api/v1/inbox',
          params,
        })
          .then(response => {
            const item = {
              ...response.data.inbox_reputation[0],
              shop_id: `${response.data.inbox_reputation[0].shop_id}`,
              user_id: `${response.data.inbox_reputation[0].user_id}`,
            }
            this.item = item
            this.props.setInvoice(item, this.props.invoicePageIndex)
            this.loadData()
          })
          .catch(error => {
            console.log(error)
            this.setState({
              isRefreshing: false,
            })
            ReactInteractionHelper.showDangerAlert(
              'Terjadi gangguan pada koneksi.',
            )
          })
      },
    )
  }

  separatorView = () => <View style={{ marginTop: 8 }} />

  loadingIndicator = () => {
    if (this.state.isLoading) {
      return (
        <ActivityIndicator
          animating
          style={[styles.centering, { height: 44 }]}
          size="small"
        />
      )
    } else if (this.state.dataSource.length === 0 && this.state.isError) {
      return (
        <NoResultView
          titleText="Kendala koneksi internet"
          onRefresh={() => {
            this.handleRefresh()
          }}
        />
      )
    }
    return null
  }

  renderItem = item => {
    if (item.item.review_has_reviewed) {
      let options = []
      if (item.item.product_data.product_status !== 0) {
        options = ['Bagikan', ...options]
      }
      if (this.props.authInfo.shop_id === this.props.item.shop_id) {
        options = ['Laporkan', ...options]
      } else if (item.item.review_is_editable) {
        options = ['Edit', ...options]
      }
      return (
        <ReviewCard
          item={item.item}
          userID={this.props.authInfo.user_id}
          shopID={this.props.authInfo.shop_id}
          merchantShopID={this.props.item.shop_id}
          userData={this.state.userData}
          isLikeHidden
          isSensorDisabled={
            this.props.authInfo.shop_id === this.props.item.shop_id
          }
          shopName={
            this.props.authInfo.shop_id === this.props.item.shop_id ? (
              this.props.authInfo.shop_name
            ) : (
              entities.decodeHTML(this.props.item.reviewee_data.reviewee_name)
            )
          }
          onActionDone={this.handleRefresh}
          isOptionHidden={options.length === 0}
          showPopover={target => {
            ReactInteractionHelper.showPopover(options, target, index => {
              if (index === 0) {
                if (this.props.authInfo.shop_id === this.props.item.shop_id) {
                  Navigator.push('ReportReviewScreen', {
                    data: item.item,
                    shopID: this.props.item.shop_id,
                  })
                  return
                } else if (item.item.review_is_editable) {
                  Navigator.push('ProductReviewFormScreen', {
                    review: item.item,
                    reputationId: this.state.reputationId,
                    authInfo: this.props.authInfo,
                    merchantShopID: this.props.item.shop_id,
                    invoicePageIndex: this.props.invoicePageIndex,
                    isLast: this.getActionLeftCount() === 1,
                  })
                  return
                }
              }
              ReactInteractionHelper.share(
                item.item.product_data.product_page_url,
                `product/${item.item.product_data.product_id}`,
                `${item.item.product_data.product_name} | Tokopedia`,
                target,
              )
            })
          }}
          onFocus={event => {
            const node = findNodeHandle(event.target)
            this.refs.scrollView.scrollToFocusedInput(node)
          }}
        />
      )
    }
    return (
      <TouchableOpacity
        onPress={() => {
          if (
            !item.item.review_has_reviewed &&
            item.item.product_data.shop_id !== this.props.authInfo.shop_id
          ) {
            Navigator.push('ProductReviewFormScreen', {
              review: item.item,
              reputationId: this.state.reputationId,
              authInfo: this.props.authInfo,
              merchantShopID: this.props.item.shop_id,
              invoicePageIndex: this.props.invoicePageIndex,
              isLast: this.getActionLeftCount() === 1,
            })
          }
          // ignore other
        }}
      >
        <ReviewCard
          item={item.item}
          userID={this.props.authInfo.user_id}
          shopID={this.props.authInfo.shop_id}
          merchantShopID={this.props.item.shop_id}
          userData={this.state.userData}
          isLikeHidden
          isSensorDisabled={
            this.props.authInfo.shop_id === this.props.item.shop_id
          }
          shopName={
            this.props.authInfo.shop_id === this.props.item.shop_id ? (
              this.props.authInfo.shop_name
            ) : (
              entities.decodeHTML(this.props.item.reviewee_data.reviewee_name)
            )
          }
        />
      </TouchableOpacity>
    )
  }

  handleModalClose = () => {
    this.setState({
      modalVisible: false,
    })
  }

  renderBadge = revieweeData => {
    if (revieweeData.reviewee_role_id === 1) {
      // buyer
      const textColor =
        revieweeData.reviewee_buyer_badge.positive_percentage === ''
          ? 'rgb(224, 224, 224)'
          : 'rgb(66, 181, 73)'
      const imgSource =
        revieweeData.reviewee_buyer_badge.positive_percentage === ''
          ? 'icon_smile_grey'
          : 'icon_smile50'
      return (
        <TouchableOpacity
          onPress={() => {
            this.setState({
              modalVisible: true,
            })
          }}
        >
          <View style={[styles.buyerBadge, { borderColor: textColor }]}>
            <Image
              source={{ uri: imgSource }}
              style={{ height: 12, aspectRatio: 1 }}
            />
            {revieweeData.reviewee_buyer_badge.positive_percentage !== '' && (
              <Text style={{ color: textColor, marginLeft: 4, fontSize: 12 }}>
                {revieweeData.reviewee_buyer_badge.positive_percentage}
              </Text>
            )}
          </View>
        </TouchableOpacity>
      )
    }

    return (
      <TouchableOpacity
        onPress={() => {
          this.setState({
            modalVisible: true,
          })
        }}
      >
        <DynamicSizeImage
          uri={revieweeData.reviewee_shop_badge.reputation_badge_url}
          height={18}
        />
      </TouchableOpacity>
    )
  }

  renderReviewerScore = () => {
    let alertText
    let labelText
    let imageUri
    if (this.props.item.reputation_data.reviewee_score_status === 0) {
      alertText = `${this.props.item.reviewee_data.reviewee_role_id === 1
        ? 'Pembeli'
        : 'Penjual'} belum memberikan penilaian`
      labelText = `${this.props.item.reviewee_data.reviewee_role_id === 1
        ? 'Pembeli'
        : 'Penjual'} Belum Menilai`
      imageUri = 'icon_neutral_grey'
    } else if (!this.props.item.reputation_data.show_reviewee_score) {
      labelText = `${this.props.item.reviewee_data.reviewee_role_id === 1
        ? 'Pembeli'
        : 'Penjual'} Sudah Menilai`
      alertText = null
      imageUri = 'icon_order_check'
    } else {
      let scoreName
      switch (this.props.item.reputation_data.reviewee_score) {
        case -1:
          imageUri = 'icon_sad50'
          scoreName = 'Kecewa'
          break
        case 1:
          imageUri = 'icon_neutral50'
          scoreName = 'Netral'
          break
        case 2:
          imageUri = 'icon_smile50'
          scoreName = 'Puas'
          break
        default:
          imageUri = 'icon_neutral25'
      }

      alertText = `Nilai dari ${this.props.item.reviewee_data
        .reviewee_role_id === 1
        ? 'Pembeli'
        : 'Penjual'}: "${scoreName}"`
      labelText = `${this.props.item.reviewee_data.reviewee_role_id === 1
        ? 'Pembeli'
        : 'Penjual'} Menilai`
    }
    return (
      <TouchableOpacity
        onPress={() => {
          if (alertText !== null) {
            Alert.alert(alertText)
          }
        }}
      >
        <View style={styles.revieweeScoreContainer}>
          <Text style={styles.revieweeText}>{labelText}</Text>
          <Image source={{ uri: imageUri }} style={styles.revieweeScoreImage} />
        </View>
      </TouchableOpacity>
    )
  }

  render() {
    if (this.state.isNotification) {
      return (
        <Navigator.Config
          title={''}
          subtitle={''}
          titleColor="black"
          statusBarAnimation="slide"
          onLeftPress={_ => Navigator.pop()}
        >
          <View style={styles.noResultContainer}>
            <ActivityIndicator animating size="small" />
          </View>
        </Navigator.Config>
      )
    }
    if (!this.props.item) {
      let text = ''
      let image = ''
      switch (this.props.invoicePageIndex) {
        case 1:
          text = 'Lihat ulasan yang sudah Anda berikan kepada penjual'
          image = 'menunggu_ulasan'
          break
        case 2:
          text = 'Lihat penilaian dan ulasan pembeli tentang produk Anda'
          image = 'ulasan_saya'
          break
        default:
          text = 'Beri penilaian dan tulis ulasan untuk produk yang Anda beli'
          image = 'ulasan_pembeli'
          break
      }
      return (
        <Navigator.Config
          title={''}
          subtitle={''}
          titleColor="black"
          statusBarAnimation="slide"
          onLeftPress={_ => Navigator.pop()}
        >
          <View style={styles.noResultContainer}>
            <NoResultView
              isLarge
              subtitleText={text}
              titleText=" "
              imageUri={image}
              isPreHidden
              isButtonHidden
            />
          </View>
        </Navigator.Config>
      )
    }
    return (
      <Navigator.Config
        title={this.props.item.order_data.invoice_ref_num}
        titleFontSize={13}
        subtitle={this.props.item.order_data.create_time_fmt}
        titleColor="black"
        subtitleColor="rgba(0,0,0,0.18)"
        onLeftPress={_ => Navigator.pop()}
      >
        <KeyboardAwareScrollView
          ref="scrollView"
          enableResetScrollToCoords={false}
          style={{ backgroundColor: '#f1f1f1', flex: 1 }}
          horizontal={false}
          keyboardDismissMode="on-drag"
          refreshControl={
            <RefreshControl
              refreshing={this.state.isRefreshing}
              onRefresh={this.handleRefresh}
            />
          }
        >
          <ReputationModal
            onRequestClose={this.handleModalClose}
            visible={this.state.modalVisible}
            reviewee_data={this.props.item.reviewee_data}
          />
          <View style={{ backgroundColor: 'white' }}>
            <TouchableOpacity
              onPress={() => {
                this.navigateToDetail(
                  this.props.item.reviewee_data.reviewee_uri,
                  this.props.item.reviewee_data.reviewee_role_id === 2,
                )
              }}
            >
              <View style={styles.reviewHeaderContainer}>
                <Image
                  style={{ width: 40, height: 40, borderRadius: 3 }}
                  source={{
                    uri: this.props.item.reviewee_data.reviewee_picture,
                  }}
                />
                <View
                  style={{
                    marginLeft: 8,
                    flexDirection: 'column',
                    alignItems: 'flex-start',
                    flex: 1,
                  }}
                >
                  <Text
                    numberOfLines={1}
                    ellipsizeMode="tail"
                    style={styles.title}
                  >
                    {entities.decodeHTML(
                      this.props.item.reviewee_data.reviewee_name,
                    )}
                  </Text>
                  {this.renderBadge(this.props.item.reviewee_data)}
                </View>
                <FavoriteButton
                  shopID={this.props.item.shop_id}
                  roleID={this.props.item.reviewee_data.reviewee_role_id}
                />
              </View>
            </TouchableOpacity>
            {this.props.item.reputation_data.show_locking_deadline &&
            this.props.item.reputation_data.reviewer_score !== 2 && (
              <ReviewReminder
                isEditable={
                  !this.props.item.reputation_data.is_locked &&
                  this.props.item.reputation_data.reviewer_score !== 2 &&
                  this.props.item.reputation_data.reviewer_score !== 0
                }
                day={this.props.item.reputation_data.locking_deadline_days}
              />
            )}
            <ShopRatingSelection
              isEditable
              isLast={this.getActionLeftCount() === 1}
              reviewerScore={this.props.item.reputation_data.reviewer_score}
              isLocked={this.props.item.reputation_data.is_locked}
              isAutoScored={this.props.item.reputation_data.is_auto_scored}
              revieweeRoleID={this.props.item.reviewee_data.reviewee_role_id}
              revieweeName={this.props.item.reviewee_data.reviewee_name}
              reputationID={this.props.item.reputation_id}
              ratingChanged={value => {
                if (this.props.item.reputation_data.reviewer_score === 0) {
                  this.checkAction(true)
                }
                this.refreshListView()
                this.props.item.reputation_data.reviewer_score = value
              }}
            />
            <View style={styles.separator} />
            {this.renderReviewerScore()}
          </View>
          <FlatList
            style={{ marginTop: 8, paddingBottom: 32 }}
            data={this.state.dataSource}
            renderItem={this.renderItem}
            ListFooterComponent={this.loadingIndicator}
            ref={flatList => {
              this.flatList = flatList
            }}
            ItemSeparatorComponent={this.separatorView}
          />
        </KeyboardAwareScrollView>
      </Navigator.Config>
    )
  }
}

InvoiceDetailScreen.propTypes = {
  item: PropTypes.object,
  setParams: PropTypes.func.isRequired,
  params: PropTypes.arrayOf(PropTypes.object).isRequired,
  invoicePageIndex: PropTypes.number.isRequired,
  resetInvoice: PropTypes.func.isRequired,
  authInfo: PropTypes.object.isRequired,
}

InvoiceDetailScreen.defaultProps = {
  item: null,
}

export default connect(mapStateToProps, mapDispatchToProps)(InvoiceDetailScreen)
