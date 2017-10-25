import Navigator from 'native-navigation'
import { TKPReactAnalytics } from 'NativeModules'
import React, { Component } from 'react'
import {
  StyleSheet,
  View,
  TouchableOpacity,
  TouchableHighlight,
  FlatList,
  RefreshControl,
  Animated,
  Text,
} from 'react-native'
import Swipeable from 'react-native-swipeable'
import { bindActionCreators } from 'redux'
import { connect } from 'react-redux'
import moment from 'moment'

import color from '../Helper/Color'
import DateSettingsButton from '../Components/DateSettingsButton'
import NoResultView from '../Components/NoResultView'
import PromoInfoCell from '../Components/PromoInfoCell'
import SearchBar from '../Components/SearchBar'

import * as PromoListActions from '../Redux/Actions/PromoListActions'
import * as FilterActions from '../Redux/Actions/FilterActions'
import * as PromoDetailActions from '../Redux/Actions/PromoDetailActions'
import * as AddPromoActions from '../Redux/Actions/AddPromoActions'

const DATEBUTTON_HEIGHT = 64
const DATEBUTTON_HEIGHT_PLUS_OFFSET = DATEBUTTON_HEIGHT + 15
let reduxKey = ''

const AnimatedFlatList = Animated.createAnimatedComponent(FlatList)

function mapStateToProps(state, ownProps) {
  reduxKey = `${ownProps.reduxKey}`
  return {
    ...state.promoListPageReducer[reduxKey],
    promoListType: ownProps.promoListType,
  }
}

function mapDispatchToProps(dispatch) {
  return bindActionCreators(
    {
      ...PromoListActions,
      ...FilterActions,
      ...PromoDetailActions,
      ...AddPromoActions,
    },
    dispatch,
  )
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: color.backgroundGrey,
  },
  defaultView: {
    flex: 1,
  },
  searchbarContainer: {
    height: 50,
    backgroundColor: 'red',
  },
  tableView: {},
  separator: {
    height: 1,
    backgroundColor: color.lineGrey,
  },
})

class PromoListPage extends Component {
  constructor(props) {
    super(props)

    const scrollAnim = new Animated.Value(0)
    const offsetAnim = new Animated.Value(0)

    this.state = {
      searchCancelButtonShown: false,
      scrollAnim,
      offsetAnim,
      clampedScroll: Animated.diffClamp(
        Animated.add(
          scrollAnim.interpolate({
            inputRange: [
              -DATEBUTTON_HEIGHT_PLUS_OFFSET,
              DATEBUTTON_HEIGHT_PLUS_OFFSET,
            ],
            outputRange: [
              -DATEBUTTON_HEIGHT_PLUS_OFFSET,
              DATEBUTTON_HEIGHT_PLUS_OFFSET,
            ],
            extrapolateLeft: 'clamp',
          }),
          offsetAnim,
        ),
        0,
        DATEBUTTON_HEIGHT_PLUS_OFFSET,
      ),
      currentlyOpenSwipeable: null,
    }
  }
  onAppear = () => {
    if (this.props.isNeedRefresh) {
      this.refreshData()
    }
  }
  refreshData = () => {
    if (this.refs.searchBar) {
      this.refs.searchBar.clearText()
      this.closeKeyboard()
    }

    if (this.props.promoListType == 0) {
      this.props.getGroupAds({
        shopId: this.props.authInfo.shop_id,
        startDate: this.props.startDate.format('YYYY-MM-DD'),
        endDate: this.props.endDate.format('YYYY-MM-DD'),
        keyword: '',
        status: this.props.filter.status,
        groupId: this.props.filter.group.group_id,
        page: 1,
        key: reduxKey,
      })
    } else {
      this.props.getProductAds({
        shopId: this.props.authInfo.shop_id,
        startDate: this.props.startDate.format('YYYY-MM-DD'),
        endDate: this.props.endDate.format('YYYY-MM-DD'),
        keyword: '',
        status: this.props.filter.status,
        groupId: this.props.filter.group.group_id,
        page: 1,
        key: reduxKey,
      })
    }
  }
  getData = () => {
    if (this.props.isEndPageReached) {
      return
    }

    if (this.props.promoListType == 0) {
      this.props.getGroupAds({
        shopId: this.props.authInfo.shop_id,
        startDate: this.props.startDate.format('YYYY-MM-DD'),
        endDate: this.props.endDate.format('YYYY-MM-DD'),
        keyword: this.props.keyword,
        status: this.props.filter.status,
        groupId: this.props.filter.group.group_id,
        page: this.props.page,
        key: reduxKey,
      })
    } else {
      this.props.getProductAds({
        shopId: this.props.authInfo.shop_id,
        startDate: this.props.startDate.format('YYYY-MM-DD'),
        endDate: this.props.endDate.format('YYYY-MM-DD'),
        keyword: this.props.keyword,
        status: this.props.filter.status,
        groupId: this.props.filter.group.group_id,
        page: this.props.page,
        key: reduxKey,
      })
    }
  }
  searchData = theKeyword => {
    this.closeKeyboard()

    if (this.props.promoListType == 0) {
      this.props.getGroupAds({
        shopId: this.props.authInfo.shop_id,
        startDate: this.props.startDate.format('YYYY-MM-DD'),
        endDate: this.props.endDate.format('YYYY-MM-DD'),
        keyword: theKeyword,
        status: this.props.filter.status,
        group: this.props.filter.group.group_id,
        page: 1,
        key: reduxKey,
      })
    } else {
      this.props.getProductAds({
        shopId: this.props.authInfo.shop_id,
        startDate: this.props.startDate.format('YYYY-MM-DD'),
        endDate: this.props.endDate.format('YYYY-MM-DD'),
        keyword: theKeyword,
        status: this.props.filter.status,
        group: this.props.filter.group.group_id,
        page: 1,
        key: reduxKey,
      })
    }
  }
  processDate = (dateString, timeString) =>
    `${dateString} - ${timeString.split(' ')[0]} ${timeString.split(' ')[1]}`

  prepDataForEdit = promo => {
    const startDateString =
      this.props.promoListType == 0
        ? this.processDate(promo.group_start_date, promo.group_start_time)
        : this.processDate(promo.ad_start_date, promo.ad_start_time)
    const endDateString =
      this.props.promoListType == 0
        ? this.processDate(promo.group_end_date, promo.group_end_time)
        : this.processDate(promo.ad_end_date, promo.ad_end_time)

    const dailySpentFmt =
      this.props.promoListType == 0
        ? promo.group_price_daily_spent_fmt
        : promo.ad_price_daily_spent_fmt

    const adEndTimeString =
      this.props.promoListType == 0 ? promo.group_end_time : promo.ad_end_time

    this.props.setInitialEditPromo({
      adId: promo.ad_id ? promo.ad_id : promo.group_id,
      productId: this.props.promoType == 1 ? promo.item_id : '',
      status:
        this.props.promoListType == 0 ? promo.group_status : promo.ad_status,
      isGroup: this.props.promoListType == 0,
      groupType: promo.group_id == '' ? 2 : 1,
      existingGroup: {
        group_id: promo.group_id,
        group_name: promo.group_name,
        total_item: promo.total_item,
      },
      maxPrice:
        this.props.promoListType == 0
          ? promo.group_price_bid
          : promo.ad_price_bid,
      budgetType: dailySpentFmt == '' ? 0 : 1,
      budgetPerDay: 0, // no data from here
      scheduleType: adEndTimeString == '' ? 0 : 1,
      startDate: moment(startDateString, 'DD/MM/YYYY - HH:mm A'),
      endDate:
        adEndTimeString == ''
          ? moment()
          : moment(endDateString, 'DD/MM/YYYY - HH:mm A'),
    })

    this.recenterSwipeable()
    this.props.needRefreshPromoList(reduxKey)
  }
  cellAddButtonTapped = promo => {
    this.prepDataForEdit(promo)
    Navigator.push('AddPromoPageStep1', {
      authInfo: this.props.authInfo,
      isEdit: true,
      isDirectEdit: true,
    })
  }
  cellEditPriceButtonTapped = promo => {
    this.prepDataForEdit(promo)
    this.props.getGroupAdDetailEdit(promo.group_id)
    Navigator.push('AddPromoPageStep2', {
      authInfo: this.props.authInfo,
      isEdit: true,
      isDirectEdit: true,
    })
  }

  swipeable = null

  recenterSwipeable = () => {
    const { currentlyOpenSwipeable } = this.state

    if (currentlyOpenSwipeable) {
      currentlyOpenSwipeable.recenter()
    }
  }

  renderItem = (item, adType) => {
    if (this.props.promoListType != 0) {
      return (
        <TouchableOpacity onPress={() => this.cellSelected(item)}>
          <View>
            {item.index == 0 && <View style={styles.separator} />}
            <PromoInfoCell isLoading={false} ad={item.item} adType={adType} />
            <View style={styles.separator} />
          </View>
        </TouchableOpacity>
      )
    }

    const rightButtons = [
      <View
        style={{
          flex: 1,
          backgroundColor: color.mainGreen,
        }}
      >
        <TouchableHighlight
          style={{
            width: 110,
            alignItems: 'center',
            justifyContent: 'center',
            flex: 1,
            backgroundColor: color.mainGreen,
          }}
          underlayColor="green"
          onPress={() => this.cellAddButtonTapped(item.item)}
        >
          <Text
            style={{
              fontSize: 10,
              color: 'white',
              backgroundColor: 'transparent',
            }}
          >
            Tambah Produk
          </Text>
        </TouchableHighlight>
      </View>,
      <View
        style={{
          flex: 1,
          backgroundColor: color.mainGreen,
        }}
      >
        <TouchableHighlight
          style={{
            width: 110,
            alignItems: 'center',
            justifyContent: 'center',
            flex: 1,
            backgroundColor: color.mainGreen,
          }}
          underlayColor="green"
          onPress={() => this.cellEditPriceButtonTapped(item.item)}
        >
          <Text
            style={{
              fontSize: 10,
              color: 'white',
              backgroundColor: 'transparent',
            }}
          >
            Ubah Biaya
          </Text>
        </TouchableHighlight>
      </View>,
    ]

    return (
      <Swipeable
        onRef={ref => {
          this.swipeable = ref
        }}
        rightButtonWidth={110}
        rightButtons={rightButtons}
        onRightButtonsOpenRelease={(event, gestureState, swipeable) => {
          if (
            this.state.currentlyOpenSwipeable &&
            this.state.currentlyOpenSwipeable !== swipeable
          ) {
            this.state.currentlyOpenSwipeable.recenter()
          }
          this.setState({
            currentlyOpenSwipeable: swipeable,
          })
        }}
        onRightButtonsCloseRelease={() =>
          this.setState({
            currentlyOpenSwipeable: null,
          })}
      >
        <TouchableOpacity onPress={() => this.cellSelected(item)}>
          <View>
            {item.index == 0 && <View style={styles.separator} />}
            <PromoInfoCell isLoading={false} ad={item.item} adType={adType} />
            <View style={styles.separator} />
          </View>
        </TouchableOpacity>
      </Swipeable>
    )
  }
  renderSeparator = () => <View style={styles.separator} />
  renderNoResult = () => {
    if (!this.props.isNoPromo) {
      return null
    }

    if (this.props.isFailedRequest) {
      return (
        <NoResultView
          title={'Gagal Mendapatkan Data'}
          desc={'Terjadi masalah pada saat pengambilan data'}
          buttonTitle={'Coba Lagi'}
          buttonAction={this.noResultButtonTapped}
        />
      )
    }

    if (this.props.isNoSearchResult || this.props.isFilterApplied) {
      return (
        <NoResultView
          title={'Hasil Tidak Ditemukan'}
          desc={'Silahkan coba lagi atau ganti kata kunci.'}
        />
      )
    }

    const alertTitle =
      this.props.promoListType == 0
        ? 'Grup Promo Anda Kosong'
        : 'Promo Produk Anda Kosong'
    const buttonTitle =
      this.props.promoListType == 0
        ? 'Tambah Grup Promo'
        : 'Tambah Promo Produk'
    const desc =
      this.props.promoListType == 0
        ? 'Gunakan Grup Promo dan nikmati kemudahan mengatur Promo Anda dalam sekali pengaturan.'
        : 'Promosikan produk Anda agar lebih mudah ditemukan pembeli untuk mendapatkan lebih banyak pengunjung dan meningkatkan pembelian.'
    return (
      <NoResultView
        title={alertTitle}
        desc={desc}
        buttonTitle={buttonTitle}
        buttonAction={this.noResultButtonTapped}
      />
    )
  }
  renderContent = () => {
    const placeholder =
      this.props.promoListType == 0 ? 'Cari Grup' : 'Cari Produk'
    return (
      <View style={styles.container}>
        <SearchBar
          ref="searchBar"
          placeholder={placeholder}
          onFocus={this.settingKeyboardCancelButton}
          onSearchButtonPress={keyword => this.searchData(keyword)}
          barTintColor={color.backgroundGrey}
          showsCancelButton={this.state.searchCancelButtonShown}
          onCancelButtonPress={this.onCancelButtonPress}
        />
        {this.props.isNoPromo &&
        (this.props.isNoSearchResult || this.props.isFilterApplied) ? (
          this.renderNoResult()
        ) : (
          this.renderSubContent()
        )}
      </View>
    )
  }
  renderSubContent = () => {
    const { clampedScroll } = this.state
    const dateButtonSizeTranslate = clampedScroll.interpolate({
      inputRange: [0, DATEBUTTON_HEIGHT_PLUS_OFFSET],
      outputRange: [0, -DATEBUTTON_HEIGHT_PLUS_OFFSET],
      extrapolate: 'clamp',
    })
    return (
      <View style={{ flex: 1, overflow: 'hidden' }}>
        <AnimatedFlatList
          contentInset={{
            top: DATEBUTTON_HEIGHT_PLUS_OFFSET,
            left: 0,
            bottom: 0,
            right: 0,
          }}
          contentOffset={{ x: 0, y: -DATEBUTTON_HEIGHT_PLUS_OFFSET }}
          style={styles.tableView}
          keyExtractor={promo => (promo.ad_id ? promo.ad_id : promo.group_id)}
          data={this.props.promoListDataSource}
          renderItem={item => this.renderItem(item, this.props.promoListType)}
          onEndReached={this.getData}
          refreshControl={
            <RefreshControl
              refreshing={this.props.isLoading}
              onRefresh={this.refreshData}
            />
          }
          scrollEventThrottle={16}
          onScroll={Animated.event(
            [{ nativeEvent: { contentOffset: { y: this.state.scrollAnim } } }],
            {
              useNativeDriver: true,
            },
          )}
          onScrollBeginDrag={this.recenterSwipeable}
        />
        <Animated.View
          style={[
            {
              height: DATEBUTTON_HEIGHT,
              backgroundColor: 'white',
              position: 'absolute',
              top: 0,
              left: 0,
              right: 0,
            },
            {
              transform: [{ translateY: dateButtonSizeTranslate }],
            },
          ]}
        >
          <DateSettingsButton
            currentDateRange={{
              startDate: this.props.startDate,
              endDate: this.props.endDate,
            }}
            buttonTapped={this.dateButtonTapped}
          />
        </Animated.View>
      </View>
    )
  }
  render = () => {
    const hasNoPromoAtAll =
      this.props.isNoPromo &&
      (!this.props.isNoSearchResult && !this.props.isFilterApplied)

    const filterImage = {
      uri: 'icon_filter',
      scale: 3,
    }

    const filterButton = {
      image: filterImage,
    }

    const plusImage = {
      uri: 'icon_plus_white',
      scale: 3,
    }

    const plusButton = {
      image: plusImage,
    }

    const buttonArray = hasNoPromoAtAll ? [] : [plusButton, filterButton]

    return (
      <Navigator.Config
        title={this.props.promoListType == 0 ? 'Promo Grup' : 'Promo Produk'}
        onAppear={this.onAppear}
        rightButtons={buttonArray}
        onRightPress={this.navBarButtonTapped}
      >
        {hasNoPromoAtAll ? this.renderNoResult() : this.renderContent()}
      </Navigator.Config>
    )
  }
  navBarButtonTapped = index => {
    if (index == 0) {
      TKPReactAnalytics.trackEvent({
        name: 'topadsios',
        category: 'ta - product',
        action: 'Click',
        label:
          this.props.promoListType === 0
            ? `Add Group Promo`
            : `Add Product Promo`,
      })
      this.props.needRefreshPromoList(reduxKey)
      Navigator.present('AddPromoPage', { authInfo: this.props.authInfo })
    } else {
      Navigator.push('FilterPage', {
        promoType: this.props.promoListType,
        shopId: this.props.authInfo.shop_id,
        reduxKey,
      })
    }
  }
  settingKeyboardCancelButton = () => {
    if (!this.state.searchCancelButtonShown) {
      this.setState({
        searchCancelButtonShown: true,
      })
    }
  }
  onCancelButtonPress = () => {
    this.refreshData()
  }
  closeKeyboard = () => {
    this.refs.searchBar.unFocus()
  }
  dateButtonTapped = () => {
    Navigator.push('DateSettingsPage', {
      changeDateActionId: 'CHANGE_DATE_RANGE_PROMOLIST',
      reduxKey,
      trackerFromGroupPage: this.props.promoListType === 0,
      trackerFromProductPage: this.props.promoListType === 1,
    })
  }
  cellSelected = item => {
    this.recenterSwipeable()
    this.props.needRefreshPromoList(reduxKey)

    const newReduxKey =
      this.props.promoListType == 0
        ? `D${item.item.group_id}`
        : `D${item.item.ad_id}`
    this.props.setInitialDataPromoDetail({
      promoType: this.props.promoListType,
      promo: item.item,
      selectedPresetDateRangeIndex: this.props.selectedPresetDateRangeIndex,
      startDate: this.props.startDate,
      endDate: this.props.endDate,
      key: newReduxKey,
    })

    Navigator.push('PromoDetailPage', {
      authInfo: this.props.authInfo,
      promoType: this.props.promoListType,
      keyword: this.props.keyword,
      reduxKey: newReduxKey,
    })
  }
  noResultButtonTapped = () => {
    if (this.props.isFailedRequest) {
      this.refreshData()
    } else {
      TKPReactAnalytics.trackEvent({
        name: 'topadsios',
        category: 'ta - product',
        action: 'Click',
        label:
          this.props.promoListType === 0
            ? `Add Group Promo`
            : `Add Product Promo`,
      })
      this.props.needRefreshPromoList(reduxKey)
      Navigator.present('AddPromoPage', { authInfo: this.props.authInfo })
    }
  }
}

export default connect(mapStateToProps, mapDispatchToProps)(PromoListPage)
