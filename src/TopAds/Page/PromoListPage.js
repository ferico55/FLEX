import Navigator from 'native-navigation'
import React, { Component } from 'react'
import {
  StyleSheet,
  View,
  TouchableOpacity,
  FlatList,
  RefreshControl,
  AlertIOS,
  Animated,
} from 'react-native'
import { bindActionCreators } from 'redux'
import { connect } from 'react-redux'

import color from '../Helper/Color'
import DateSettingsButton from '../Components/DateSettingsButton'
import NoResultView from '../Components/NoResultView'
import PromoInfoCell from '../Components/PromoInfoCell'
import SearchBar from '../Components/SearchBar'

import * as PromoListActions from '../Redux/Actions/PromoListActions'
import * as FilterActions from '../Redux/Actions/FilterActions'
import * as PromoDetailActions from '../Redux/Actions/PromoDetailActions'

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

  renderItem = (item, adType) => (
    <TouchableOpacity onPress={() => this.cellSelected(item)}>
      <View>
        {item.index == 0 ? <View style={styles.separator} /> : null}
        <PromoInfoCell isLoading={false} ad={item.item} adType={adType} />
        <View style={styles.separator} />
      </View>
    </TouchableOpacity>
  )
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
        : 'Promosikan produk Anda agar lebih mudah ditemukan pembeli untuk mendapatkan lebih banyak pengunjung dan meningkatkan penjualan.'
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
          scrollEventThrottle={1}
          onScroll={Animated.event(
            [{ nativeEvent: { contentOffset: { y: this.state.scrollAnim } } }],
            {
              useNativeDriver: true,
            },
          )}
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
        title={this.props.promoListType == 0 ? 'Grup' : 'Produk'}
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
      AlertIOS.alert(
        'Tambah Promo Tidak Tersedia',
        'Saat ini tambah promo hanya bisa dilakukan dari komputer.',
        [{ text: 'OK' }],
      )
    } else {
      Navigator.push('FilterPage', {
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
    })
  }
  cellSelected = item => {
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
      AlertIOS.alert(
        'Tambah Promo Tidak Tersedia',
        'Saat ini tambah promo hanya bisa dilakukan dari komputer.',
        [{ text: 'OK' }],
      )
    }
  }
}

export default connect(mapStateToProps, mapDispatchToProps)(PromoListPage)
