import React from 'react'
import {
  StyleSheet,
  Text,
  TouchableOpacity,
  View,
  FlatList,
  Image,
  ActivityIndicator,
  NativeEventEmitter,
  Clipboard,
  ActionSheetIOS,
  Dimensions,
} from 'react-native'
import DeviceInfo from 'react-native-device-info'
import {
  TKPReactURLManager,
  ReactNetworkManager,
  EventManager,
  ReactInteractionHelper,
  ReactPopoverHelper,
  TKPReactAnalytics,
} from 'NativeModules'
import Rx from 'rxjs/Rx'

import PreAnimatedImage from './PreAnimatedImage'
import NoResultView from './NoResultView'
import {
  GA_EVENT_NAME_USER_INTERACTION_HOMEPAGE,
  GA_EVENT_CATEGORY_HOMEPAGE,
  GA_EVENT_ACTION_PROMO_CLICK_COPY_CODE,
  GA_EVENT_ACTION_PROMO_FILTER_PROMO,
  GA_EVENT_ACTION_PROMO_CLICK_PROMO_INFO,
  GA_EVENT_ACTION_PROMO_LOAD_SEE_MORE,
} from './analytics/AnalyticsString'

const nativeTabEmitter = new NativeEventEmitter(EventManager)

const monthNames = [
  'Januari',
  'Februari',
  'Maret',
  'April',
  'Mei',
  'Juni',
  'Juli',
  'Agustus',
  'September',
  'Oktober',
  'November',
  'Desember',
]

const styles = StyleSheet.create({
  container: {
    flexDirection: 'column',
    backgroundColor: '#F1F1F1',
    padding: 5,
    flex: 1,
  },
  text: {
    fontSize: 12,
  },
  photoContainer: {
    flexDirection: 'column',
    backgroundColor: '#F1F1F1',
    padding: 5,
    flex: DeviceInfo.isTablet() ? 1 : 0,
  },
  photo: {
    resizeMode: 'cover',
    aspectRatio: 1.91,
    justifyContent: 'center',
  },
  wrapper: {
    backgroundColor: '#F1F1F1',
    paddingTop: 5,
    paddingHorizontal: 5,
  },
  centering: {
    alignItems: 'center',
    justifyContent: 'center',
    padding: 8,
  },
  textWrapper: {
    flexDirection: 'column',
    justifyContent: 'space-between',
    backgroundColor: 'white',
  },
  detailText: {
    color: '#66b573',
    fontSize: 14,
    fontWeight: '600',
  },
  actionWrapper: {
    borderTopWidth: 1,
    borderColor: 'rgba(0,0,0,0.12)',
    paddingVertical: 20,
    paddingRight: 15,
    alignItems: 'flex-end',
  },
  greyText: {
    color: 'rgba(0,0,0,0.38)',
  },
  promoWrapper: {
    paddingLeft: 18,
    paddingTop: 13,
    paddingBottom: 22,
    paddingRight: 20,
  },
  copyButton: {
    borderColor: 'rgb(224,224,224)',
    borderWidth: 1,
    borderRadius: 3,
    paddingHorizontal: 10,
    height: 30,
    justifyContent: 'center',
  },
  stopwatch: {
    marginRight: 11,
    marginTop: 4,
    width: 24,
    height: 26,
  },
  coupon: {
    marginRight: 11,
    marginTop: 10,
    width: 25,
    height: 14,
  },
  info: {
    marginLeft: 5,
    height: 14,
    width: 14,
  },
  dropDownWrapper: {
    margin: 5,
    padding: 13,
    backgroundColor: 'white',
    flexDirection: 'row',
    justifyContent: 'space-between',
  },
  subtitle: {
    fontSize: 12,
  },
})

class Promo extends React.PureComponent {
  constructor(props) {
    super(props)
    this.state = {
      dataSource: [],
      page: 1,
      isLoading: false,
      isError: false,
      isErrorOnScroll: false,
      selectedCategory: 0,
    }

    this.loadData$ = new Rx.Subject()
  }

  componentDidMount() {
    this.loadData()
    this.stickyIds = []

    this.subscription = nativeTabEmitter.addListener(
      'HotlistScrollToTop',
      () => {
        if (this.flatList) {
          this.flatList.scrollToOffset({ offset: 0, animated: true })
        }
      },
    )

    this.subscriptionLoadData = this.loadData$
      .debounceTime(1000)
      .subscribe(page => {
        this.loadData(page)
      })
  }

  componentWillUnmount() {
    this.subscription.remove()
    this.aliveSubscription.unsubscribe()
  }

  getPromoPeriod = (startDateString, endDateString) => {
    const startDate = new Date(startDateString)
    const endDate = new Date(endDateString)
    let period = startDate.getDate()
    if (startDate.getMonth() !== endDate.getMonth()) {
      period += ` ${monthNames[startDate.getMonth()]}`
    }
    if (startDate.getFullYear() !== endDate.getFullYear()) {
      period += ` ${startDate.getFullYear()}`
    }

    period += ` - ${endDate.getDate()} ${monthNames[
      endDate.getMonth()
    ]} ${endDate.getFullYear()}`
    return period
  }

  getCategoryID = index => {
    switch (index) {
      case 0:
        return 0
      case 1:
        return 2
      case 2:
        return 8
      case 3:
        return 3
      case 4:
        return 4
      default:
        return 0
    }
  }

  dropdownText = () => {
    switch (this.state.selectedCategory) {
      case 0:
        return 'Semua Promo'
      case 1:
        return 'Jual Beli Online'
      case 2:
        return 'Official Store'
      case 3:
        return 'Pulsa'
      case 4:
        return 'Tiket'
      default:
        return ''
    }
  }

  copyPromoCode = kodepromo => {
    TKPReactAnalytics.trackEvent({
      name: GA_EVENT_NAME_USER_INTERACTION_HOMEPAGE,
      category: GA_EVENT_CATEGORY_HOMEPAGE,
      action: GA_EVENT_ACTION_PROMO_CLICK_COPY_CODE,
      label: kodepromo,
    })
    Clipboard.setString(kodepromo)
    ReactInteractionHelper.showStickyAlert('Kode Promo berhasil disalin')
  }

  handleRefresh = () => {
    this.state = {
      dataSource: [],
      page: 1,
      isLoading: false,
      selectedCategory: this.state.selectedCategory,
    }

    this.loadData()
  }

  footerComponent = () => {
    if (this.state.page === -1) {
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

  showDropdown = _ => {
    const options = [
      'Semua Promo',
      'Jual Beli Online',
      'Official Store',
      'Pulsa',
      'Tiket',
      'Batal',
    ]
    ActionSheetIOS.showActionSheetWithOptions(
      {
        options,
        cancelButtonIndex: 5,
      },
      index => {
        if (index >= 5) {
          return
        }
        TKPReactAnalytics.trackEvent({
          name: GA_EVENT_NAME_USER_INTERACTION_HOMEPAGE,
          category: GA_EVENT_CATEGORY_HOMEPAGE,
          action: GA_EVENT_ACTION_PROMO_FILTER_PROMO,
          label: options[index],
        })
        this.setState({
          selectedCategory: index,
          page: 1,
          dataSource: [],
        })
        this.loadData(1)
      },
    )
  }

  listHeader = () => (
    <TouchableOpacity onPress={e => this.showDropdown(e)}>
      <View style={styles.dropDownWrapper}>
        <Text style={[styles.greyText, { fontWeight: '600' }]}>
          {this.dropdownText()}
        </Text>
        <Image
          source={{ uri: 'icon_arrow_down_grey' }}
          style={{ width: 14, height: 14, marginTop: 2, marginRight: 2 }}
        />
      </View>
    </TouchableOpacity>
  )

  transformToArray = obj => {
    const arr = []
    const keys = Object.keys(obj)
    keys.forEach(item => {
      arr.push(obj[item])
    })

    return arr
  }

  loadData(page = 1) {
    if (this.state.page === -1) {
      return
    }

    this.setState({
      isLoading: true,
    })

    const params = { page, per_page: 12, categories_exclude: 30 }
    const featuredParams = { categories_exclude: 30, sticky: true }
    if (this.state.selectedCategory !== 0) {
      params.categories = this.getCategoryID(this.state.selectedCategory)
      featuredParams.categories = this.getCategoryID(
        this.state.selectedCategory,
      )
    }

    const promoRequest = Rx.Observable.fromPromise(
      ReactNetworkManager.request({
        method: 'GET',
        baseUrl: TKPReactURLManager.tokopediaUrl,
        path: '/promo/wp-json/wp/v2/posts',
        params,
      }),
    )

    if (page > 1) {
      if (this.aliveSubscription) {
        this.aliveSubscription.unsubscribe()
      }
      this.aliveSubscription = promoRequest.subscribe(
        response => {
          if (response == null) {
            return
          }

          if (
            response.code &&
            response.code === 'rest_post_invalid_page_number' &&
            response.data.status === 400
          ) {
            this.setState({
              page: -1,
              isLoading: false,
              isError: false,
              isErrorOnScroll: false,
            })
            return
          }

          this.setState({
            dataSource: this.state.dataSource.concat(
              response.filter(promo => !this.stickyIds.includes(promo.id)),
            ),
            page: this.state.page + 1,
            isLoading: false,
            isError: false,
            isErrorOnScroll: false,
          })
        },
        () => {
          ReactInteractionHelper.showDangerAlert('Tidak ada koneksi internet')
          this.setState({
            isLoading: false,
            isError: false,
            isErrorOnScroll: true,
          })
        },
      )
    } else {
      const featuredPromoRequest = ReactNetworkManager.request({
        method: 'GET',
        baseUrl: TKPReactURLManager.tokopediaUrl,
        path: '/promo/wp-json/wp/v2/posts',
        params: featuredParams,
      })

      const request = Rx.Observable.zip(featuredPromoRequest, promoRequest)

      this.aliveSubscription = request.subscribe(
        ([featuredPromo, regularPromo]) => {
          this.stickyIds = featuredPromo.map(promo => promo.id)

          const dataSource = featuredPromo.concat(
            regularPromo.filter(promo => !this.stickyIds.includes(promo.id)),
          )

          this.setState({
            dataSource: this.state.dataSource.concat(dataSource),
            page: this.state.page + 1,
            isLoading: false,
            isError: false,
            isErrorOnScroll: false,
          })
        },
        err => {
          ReactInteractionHelper.showDangerAlert('Tidak ada koneksi internet')
          this.setState({
            isLoading: false,
            dataSource: [],
            isError: true,
            isErrorOnScroll: true,
          })
        },
      )
    }
  }
  renderPromoCodes = item => {
    if (item.acf.multiple_promo_code) {
      const numberOfCodes = item.acf.promo_codes.reduce(
        (sum, array) => sum + array.group_code.length,
        0,
      )
      return `${numberOfCodes} Kode Promo`
    }
    return item.meta.promo_code === '' ? 'Tanpa Kode Promo' : 'Kode Promo'
  }

  renderItem = (item, _) => (
    <TouchableOpacity
      onPress={() => {
        this.props.navigation.navigate('tproutes', { url: item.item.link })
      }}
      style={styles.photoContainer}
    >
      <View style={{ borderWidth: 1, borderColor: 'rgba(0,0,0,0.12)' }}>
        <PreAnimatedImage
          source={item.item.meta.thumbnail_image}
          style={styles.photo}
          onLoadEnd={() => {
            this.setNativeProps()
          }}
        />
        <View style={styles.textWrapper}>
          <View style={styles.promoWrapper}>
            <View style={{ flexDirection: 'row' }}>
              <Image
                source={{ uri: 'icon_stopwatch' }}
                style={styles.stopwatch}
              />
              <View style={{ flexDirection: 'column', marginRight: 15 }}>
                <Text style={[styles.greyText, styles.subtitle]}>
                  Periode Promo
                </Text>
                <Text style={{ color: 'rgba(0,0,0,0.7)', fontSize: 14 }}>
                  {this.getPromoPeriod(
                    item.item.meta.start_date,
                    item.item.meta.end_date,
                  )}
                </Text>
              </View>
            </View>

            <View style={{ marginTop: 18, flexDirection: 'row' }}>
              <Image source={{ uri: 'icon_coupon' }} style={styles.coupon} />
              <View style={{ flexDirection: 'column' }}>
                <View style={{ flexDirection: 'row' }}>
                  <Text
                    style={
                      item.item.meta.promo_code === '' ? (
                        [styles.greyText, styles.subtitle, { marginTop: 9 }]
                      ) : (
                        [styles.greyText, styles.subtitle]
                      )
                    }
                    numberOfLines={2}
                  >
                    {this.renderPromoCodes(item.item)}
                  </Text>
                  {item.item.meta.promo_code !== '' && (
                    <TouchableOpacity
                      onPress={() => {
                        TKPReactAnalytics.trackEvent({
                          name: GA_EVENT_NAME_USER_INTERACTION_HOMEPAGE,
                          category: GA_EVENT_CATEGORY_HOMEPAGE,
                          action: GA_EVENT_ACTION_PROMO_CLICK_PROMO_INFO,
                          label: item.item.meta.promo_code,
                        })
                        ReactPopoverHelper.showTooltip(
                          'Kode Promo',
                          'Masukan Kode Promo di halaman pembayaran',
                          'icon_promo',
                          'Tutup',
                        )
                      }}
                    >
                      <Image
                        source={{ uri: 'icon_information' }}
                        resizeMode="contain"
                        style={
                          item.item.meta.promo_code === '' ? (
                            [styles.info, { marginTop: 12 }]
                          ) : (
                            styles.info
                          )
                        }
                      />
                    </TouchableOpacity>
                  )}
                </View>
                <Text style={{ color: 'rgba(255,87,34,1)', fontSize: 14 }}>
                  {item.item.meta.promo_code}
                </Text>
              </View>
              <View style={{ flex: 1 }} />
              {item.item.meta.promo_code !== '' && (
                <TouchableOpacity
                  onPress={() => this.copyPromoCode(item.item.meta.promo_code)}
                >
                  <View style={styles.copyButton}>
                    <Text style={{ color: 'rgba(0,0,0,0.38)' }}>
                      {'Salin Kode'}
                    </Text>
                  </View>
                </TouchableOpacity>
              )}
            </View>
          </View>
        </View>
      </View>
    </TouchableOpacity>
  )

  render() {
    if (this.state.isError) {
      return (
        <View style={{ backgroundColor: '#F1F1F1', flex: 1 }}>
          <NoResultView
            onRefresh={() => {
              this.loadData()
            }}
          />
        </View>
      )
    }

    return (
      <View style={{ backgroundColor: '#F1F1F1', flex: 1 }}>
        <FlatList
          ref={ref => {
            this.flatList = ref
          }}
          style={styles.wrapper}
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
                  TKPReactAnalytics.trackEvent({
                    name: GA_EVENT_NAME_USER_INTERACTION_HOMEPAGE,
                    category: GA_EVENT_CATEGORY_HOMEPAGE,
                    action: GA_EVENT_ACTION_PROMO_LOAD_SEE_MORE,
                    label: '',
                  })
                  this.loadData(this.state.page)
                }
              }
            }
          }}
          ListHeaderComponent={this.listHeader}
          ListFooterComponent={this.footerComponent}
          keyExtractor={item => item.id}
          data={this.state.dataSource}
          onRefresh={this.handleRefresh}
          numColumns={DeviceInfo.isTablet() ? 2 : 1}
          refreshing={false}
          renderItem={this.renderItem}
        />
      </View>
    )
  }
}

export default Promo
