import React, { PureComponent } from 'react'
import {
  StyleSheet,
  Text,
  TouchableOpacity,
  View,
  FlatList,
  Image,
  ActivityIndicator,
  NativeEventEmitter,
  Dimensions,
} from 'react-native'
import DeviceInfo from 'react-native-device-info'
import Rx from 'rxjs'
import {
  TKPReactURLManager,
  ReactNetworkManager,
  TKPReactAnalytics,
  EventManager,
  ReactUserManager,
  ReactInteractionHelper,
} from 'NativeModules'

import NoResult from './unify/NoResult'

import {
  GA_EVENT_NAME_USER_INTERACTION_HOMEPAGE,
  GA_EVENT_CATEGORY_HOMEPAGE,
  GA_EVENT_ACTION_PROMO_CLICK_COPY_CODE,
  GA_EVENT_ACTION_HOTLIST_LOAD_SEE_MORE,
} from './analytics/AnalyticsString'

const nativeTabEmitter = new NativeEventEmitter(EventManager)

const styles = StyleSheet.create({
  container: {
    flexDirection: 'column',
    backgroundColor: '#e1e1e1',
    padding: 5,
    flex: 1,
  },
  text: {
    fontSize: 12,
  },
  photoContainer: {
    flexDirection: 'column',
    backgroundColor: '#e1e1e1',
    padding: 5,
    flex: DeviceInfo.isTablet() ? 1 : 0,
  },
  photo: {
    resizeMode: 'cover',
    aspectRatio: 1.91,
  },
  wrapper: {
    backgroundColor: '#e1e1e1',
    paddingTop: 5,
    paddingLeft: 5,
    paddingRight: 5,
  },
  centering: {
    alignItems: 'center',
    justifyContent: 'center',
    padding: 8,
  },
  textWrapper: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    backgroundColor: 'white',
    padding: 5,
  },
  textStartFrom: {
    color: '#c8c7cc',
    fontSize: 12,
    marginRight: 5,
  },
  textPrice: {
    color: '#ff5722',
    fontSize: 12,
  },
  button: {
    backgroundColor: '#42b549',
    minWidth: 100,
    alignItems: 'center',
    padding: 8,
    borderWidth: 1,
    borderColor: '#42b549',
    borderRadius: 3,
  },
  buttonTitle: {
    color: 'white',
  },
})

class Hotlist extends PureComponent {
  constructor(props) {
    super(props)
    this.state = {
      dataSource: [],
      page: 1,
      isLoading: true,
      isError: false,
      isErrorOnScroll: false,
      isLoadingPullRefresh: false,
      isLoadingOnScroll: false,
    }

    this.loadData$ = new Rx.Subject()
  }

  componentDidMount() {
    this.loadData()
    this.subscription = nativeTabEmitter.addListener('HotlistScrollToTop', () =>
      this.backToTop(this.flatList)
    )
    this.subscriptionLoadData = this.loadData$
      .debounceTime(1000)
      .subscribe(page => {
        this.loadData(page)
      })
  }

  componentWillUnmount() {
    this.subscription.remove()
    this.subscriptionLoadData.unsubscribe()
  }

  onRefresh = () => {
    this.state = {
      dataSource: [],
      page: 1,
      isLoadingPullRefresh: true,
    }

    this.loadData()
  }

  backToTop = flatList => {
    let error = null
    try {
      flatList.scrollToIndex({ index: 0 })
    } catch (err) {
      error = err
    }
    return error
  }

  loadingIndicator = () => {
    if (!this.state.isLoadingPullRefresh) {
      return (
        <ActivityIndicator
          animating
          style={[styles.centering, { height: 44, marginBottom: 20 }]}
          size="small"
        />
      )
    }

    return null
  }

  loadData(page = 1) {
    this.setState(
      {
        isLoadingOnScroll: true,
      },
      () => {
        ReactNetworkManager.request({
          method: 'GET',
          baseUrl: TKPReactURLManager.v4Url,
          path: '/v4/hotlist/get_hotlist.pl',
          params: { page: this.state.page, limit: 10, os_type: 2 },
        })
          .then(response => {
            if (page > this.state.page) {
              return
            }

            ReactUserManager.userIsLogin((error, isLogin) => {
              TKPReactAnalytics.moEngageEvent('Hotlist_Screen_Launched', {
                logged_in_status: isLogin,
              })
            })

            this.setState({
              dataSource: this.state.dataSource.concat(response.data.list),
              page: this.state.page + 1,
              isLoading: false,
              isError: false,
              isErrorOnScroll: false,
              isLoadingPullRefresh: false,
              isLoadingOnScroll: false,
            })
          })
          .catch(() => {
            ReactInteractionHelper.showDangerAlert('Tidak ada koneksi internet')

            if (this.state.page > 1) {
              this.setState({
                isLoading: false,
                isError: false,
                isLoadingOnScroll: false,
                isErrorOnScroll: true,
              })
            } else {
              this.setState({
                isLoading: false,
                isError: true,
                isLoadingOnScroll: false,
                isErrorOnScroll: false,
              })
            }
          })
      },
    )
  }

  renderItem = item => (
    <TouchableOpacity
      onPress={() => {
        TKPReactAnalytics.trackEvent({
          name: 'clickHotlist',
          category: 'Hotlist',
          action: 'Click',
          label: item.item.key,
        })

        ReactUserManager.userIsLogin((error, isLogin) => {
          TKPReactAnalytics.moEngageEvent('Clicked_Hotlist_Item', {
            logged_in_status: isLogin,
            hotlist_name: item.item.title,
          })
        })

        this.props.navigation.navigate('tproutes', { url: item.item.url })
      }}
      style={styles.photoContainer}
    >
      <Image source={{ uri: item.item.image_url_600 }} style={styles.photo} />
      <View style={styles.textWrapper}>
        <Text style={{ fontSize: 12, flexShrink: 1 }}>{item.item.title}</Text>
        <View style={{ flexDirection: 'row' }}>
          <Text style={styles.textStartFrom}>Mulai dari</Text>
          <Text style={styles.textPrice}>{item.item.price_start}</Text>
        </View>
      </View>
    </TouchableOpacity>
  )

  render() {
    if (this.state.isLoading) {
      return (
        <View
          style={{ flex: 1, alignItems: 'center', justifyContent: 'center' }}
        >
          <ActivityIndicator animating={this.state.isLoading} size={'small'} />
        </View>
      )
    }

    if (this.state.isError) {
      return (
        <NoResult
          onButtonPress={() => this.loadData(this.state.page)}
          title={'Terjadi kendala pada server'}
          subtitle={'Harap coba lagi'}
          buttonTitle={'Coba Lagi'}
        />
      )
    }

    return (
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
            if (!this.state.isLoadingOnScroll) {
              if (this.state.isErrorOnScroll) {
                // debounce
                this.loadData$.next(this.state.page)
              } else {
                TKPReactAnalytics.trackEvent({
                  name: GA_EVENT_NAME_USER_INTERACTION_HOMEPAGE,
                  category: GA_EVENT_CATEGORY_HOMEPAGE,
                  action: GA_EVENT_ACTION_HOTLIST_LOAD_SEE_MORE,
                  label: '',
                })
                this.loadData(this.state.page)
              }
            }
          }
        }}
        ListFooterComponent={this.loadingIndicator.bind(this)}
        keyExtractor={(item, index) => index}
        data={this.state.dataSource}
        onRefresh={() => this.onRefresh()}
        numColumns={DeviceInfo.isTablet() ? 2 : 1}
        refreshing={this.state.isLoadingPullRefresh}
        renderItem={this.renderItem}
      />
    )
  }
}

module.exports = Hotlist
