import React, { PureComponent } from 'react'
import {
  StyleSheet,
  Image,
  View,
  FlatList,
  TouchableOpacity,
  Text,
  TextInput,
  ActivityIndicator,
  DeviceEventEmitter,
  Dimensions,
} from 'react-native'
import entities from 'entities'
import Navigator from 'native-navigation'
import moment from 'moment'
import { bindActionCreators } from 'redux'
import { ReactTPRoutes, ReactInteractionHelper } from 'NativeModules'
import { connect } from 'react-redux'
import DeviceInfo from 'react-native-device-info'
import Rx from 'rxjs/Rx'

import NoResultView from '../../NoResultView'
import DynamicSizeImage from '../Components/DynamicSizeImage'
import FilterButton from '../Components/FilterButton'
import * as Actions from '../Redux/Actions'

const styles = StyleSheet.create({
  wrapper: {
    backgroundColor: '#F1F1F1',
  },
  searchInput: {
    paddingVertical: 9,
    paddingLeft: 48,
    flex: 1,
    height: 40,
    borderColor: 'rgb(224,224,224)',
    backgroundColor: 'white',
    borderWidth: 1,
  },
  imagePlaceholder: {
    width: 18,
    height: 18,
    position: 'absolute',
    top: 20.5,
    left: 24,
  },
  mutedText: {
    color: 'rgba(0,0,0,0.38)',
  },
  invoiceContainer: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'space-between',
  },
  redBadge: {
    alignSelf: 'center',
    width: 8,
    height: 8,
    backgroundColor: 'rgb(240,23,19)',
    borderRadius: 8,
  },
  shopName: {
    fontSize: 15,
    color: 'rgba(0,0,0,0.7)',
    lineHeight: 22,
  },
  separator: {
    height: 1,
    backgroundColor: '#f1f1f1',
    width: '100%',
  },
  actionContainer: {
    padding: 16,
    paddingRight: 8,
    flexDirection: 'row',
    justifyContent: 'flex-end',
    alignItems: 'center',
  },
  actionText: {
    color: 'rgb(66,181,73)',
    fontSize: 15,
    fontWeight: '500',
  },
  filterContainer: {
    position: 'absolute',
    zIndex: 100,
    bottom: 8,
    alignSelf: 'center',
  },
  sectionTitleText: {
    fontSize: 13,
    color: 'rgba(0,0,0,0.54)',
    lineHeight: 19,
    fontWeight: '500',
  },
  searchContainer: {
    padding: 8,
    borderRadius: 3,
    borderBottomWidth: 1,
    borderColor: 'rgb(224,224,224)',
  },
  sectionHeaderContainer: {
    height: 28,
    paddingLeft: 8,
    justifyContent: 'center',
    backgroundColor: '#f1f1f1',
  },
  invoiceText: {
    fontSize: 13,
    fontWeight: '500',
    lineHeight: 21,
    color: 'rgba(0,0,0,0.54)',
  },
  deadlineContainer: {
    paddingHorizontal: 8,
    borderRadius: 3,
    height: 18,
    backgroundColor: 'rgb(0,188,212)',
    justifyContent: 'center',
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
  redDot: {
    width: 8,
    height: 8,
    marginLeft: 3,
    backgroundColor: 'rgb(240, 23, 19)',
    borderRadius: 4,
  },
})

function mapStateToProps(state) {
  return {
    ...state.inboxReviewReducer,
  }
}

function mapDispatchToProps(dispatch) {
  return bindActionCreators(Actions, dispatch)
}

class ReviewPage extends PureComponent {
  constructor(props) {
    super(props)
    this.state = {
      dataSource: [],
      page: 1,
      isLoading: false,
      timeFilter: 1,
      status: this.props.status,
      pageIndex: this.props.pageIndex,
      role: this.props.role,
      selectedInvoice: 0,
    }

    this.loadData$ = new Rx.Subject()
  }

  componentDidMount() {
    this.props.setParams(
      {
        page: 1,
        per_page: 12,
        role: this.props.role,
        time_filter: 1,
        status: this.props.status,
        keyword: this.state.keyword,
      },
      this.props.pageIndex,
    )

    this.subscriptionLoadData = this.loadData$
      .debounceTime(1000)
      .subscribe(() => {
        const params = this.props.params[this.props.pageIndex]
        this.props.updateParams(
          params,
          { page: params.page + 1 },
          this.props.pageIndex,
        )
      })
  }

  handleRefresh = () => {
    const params = {
      ...this.props.params[this.props.pageIndex],
      keyword: this.state.keyword,
    }
    this.props.resetInvoice()
    this.props.setParams(params, this.props.pageIndex)
  }

  listFooterComponent = () => {
    if (
      this.props.errorStatus[this.props.pageIndex] &&
      this.props.reviewLists[this.props.pageIndex].length === 0
    ) {
      return (
        <NoResultView
          titleText="Kendala koneksi internet"
          onRefresh={() => {
            this.handleRefresh()
          }}
        />
      )
    }
    if (
      !this.props.loadingStatus[this.props.pageIndex] &&
      this.props.reviewLists[this.props.pageIndex].length === 0 &&
      this.props.params[this.props.pageIndex].page === -1
    ) {
      if (
        !this.props.params[this.props.pageIndex].keyword &&
        this.props.params[this.props.pageIndex].time_filter === 1
      ) {
        if (this.props.pageIndex === 2) {
          return (
            <NoResultView
              titleText="Belum ada ulasan dari pembeli."
              subtitleText="Pastikan Produk Anda sudah terjual."
              buttonText="Lihat Toko Saya"
              onRefresh={() => {
                ReactTPRoutes.navigate(
                  `tokopedia://shop/${this.props.authInfo.shop_id}`,
                )
              }}
            />
          )
        }
        return (
          <NoResultView
            titleText="Ulasan Anda masih kosong"
            subtitleText=""
            buttonText="Mulai Cari Produk"
            onRefresh={() => {
              ReactInteractionHelper.dismiss(() => {
                ReactTPRoutes.navigate('hot')
              })
            }}
          />
        )
      }
      return (
        <NoResultView
          titleText="Hasil pencarian tidak ditemukan"
          subtitleText=""
          buttonText="Lihat Semua Ulasan"
          onRefresh={() => {
            this.textInput.setNativeProps({ text: '' })
            this.props.resetInvoice()
            this.props.setParams(
              {
                ...this.props.params[this.props.pageIndex],
                time_filter: 1,
                score_filter: 0,
                keyword: '',
              },
              this.props.pageIndex,
            )
          }}
        />
      )
    }
    if (
      !this.props.loadingStatus[this.props.pageIndex] &&
      this.props.params[this.props.pageIndex].page === -1
    ) {
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

  handleSearch = _ => {
    this.props.resetInvoice()
    this.props.setParams(
      {
        ...this.props.params[this.props.pageIndex],
        keyword: this.state.keyword,
      },
      this.props.pageIndex,
    )
  }

  listHeader = () => (
    <View style={styles.searchContainer}>
      <TextInput
        ref={input => {
          this.textInput = input
        }}
        onChangeText={value => {
          this.setState({ keyword: value })
        }}
        blurOnSubmit
        onSubmitEditing={this.handleSearch}
        returnKeyType="search"
        inlineImageLeft="icon_search"
        style={styles.searchInput}
        placeholder={
          this.state.role === 1 ? (
            'Cari toko atau invoice'
          ) : (
            'Cari invoice atau pembeli'
          )
        }
      />
      <Image source={{ uri: 'icon_search' }} style={styles.imagePlaceholder} />
    </View>
  )

  handleFilter = () => {
    Navigator.present('ReviewFilterPage', {
      pageIndex: this.props.pageIndex,
      keyword: this.state.keyword,
    })
  }

  formatDate = date => date.get

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
      )
    }

    return (
      <DynamicSizeImage
        uri={revieweeData.reviewee_shop_badge.reputation_badge_url}
        height={18}
      />
    )
  }

  renderItem = (item, _) => {
    item = item.item
    const isSameYear = moment
      .unix(item.order_data.create_time_unix)
      .utcOffset(0)
      .isSame(moment(), 'year')

    const dateFormat = isSameYear ? 'D MMM' : 'D MMM YYYY'
    return (
      <View
        style={{
          backgroundColor: DeviceInfo.isTablet() ? 'white' : '#f1f1f1',
          paddingTop: DeviceInfo.isTablet() ? 8 : 0,
        }}
      >
        <TouchableOpacity
          onPress={() => {
            if (this.props.isInteractionBlocked) {
              return
            }
            this.props.setInvoice(item, this.props.pageIndex)
            if (DeviceInfo.isTablet()) {
              this.setState(
                {
                  selectedInvoice: item.inbox_id,
                },
                () => {
                  DeviceEventEmitter.emit('SET_INVOICE')
                },
              )
            } else {
              Navigator.push('InvoiceDetailPage', {
                authInfo: this.props.authInfo,
                invoicePageIndex: this.props.pageIndex,
              })
            }
          }}
        >
          <View
            style={[
              {
                backgroundColor: 'white',
                flex: 1,
                borderWidth: 1,
                borderColor: 'rgb(224,224,224)',
              },
              DeviceInfo.isTablet()
                ? {
                    marginHorizontal: 8,
                    borderRadius: 3,
                  }
                : null,
              this.props.item &&
              this.props.item.inbox_id === item.inbox_id &&
              DeviceInfo.isTablet()
                ? {
                    backgroundColor: 'rgb(243,254,243)',
                  }
                : null,
            ]}
          >
            <View
              style={{
                margin: 8,
              }}
            >
              <View style={styles.invoiceContainer}>
                <Text style={[styles.mutedText, { fontSize: 11 }]}>
                  {moment
                    .unix(item.order_data.create_time_unix)
                    .utcOffset(0)
                    .format(dateFormat)}
                </Text>
                {item.reputation_data.show_locking_deadline && (
                  <Text style={[styles.mutedText, { fontSize: 11 }]}>
                    {'Batas  penilaian'}
                  </Text>
                )}
              </View>
              <View style={[styles.invoiceContainer, { marginTop: 5 }]}>
                <View style={{ flexDirection: 'row', alignItems: 'center' }}>
                  <Text style={styles.invoiceText}>
                    {item.order_data.invoice_ref_num}
                  </Text>
                  {item.reputation_data.show_bookmark && (
                    <View style={styles.redDot} />
                  )}
                </View>
                {item.reputation_data.show_locking_deadline && (
                  <View
                    style={[
                      styles.deadlineContainer,
                      {
                        backgroundColor:
                          item.reputation_data.locking_deadline_days === 1
                            ? '#EA212D'
                            : item.reputation_data.locking_deadline_days === 2
                              ? '#FEC107'
                              : '#23C4D0',
                      },
                    ]}
                  >
                    <Text style={{ fontSize: 11, color: 'white' }}>
                      {item.reputation_data.locking_deadline_days}
                      {' hari lagi'}
                    </Text>
                  </View>
                )}
              </View>

              <View
                style={{ marginTop: 8, marginBottom: 4, flexDirection: 'row' }}
              >
                <Image
                  source={{ uri: item.reviewee_data.reviewee_picture }}
                  style={{ height: 40, width: 40, borderRadius: 3 }}
                />
                <View style={{ marginLeft: 8 }}>
                  <Text style={styles.shopName}>
                    {entities.decodeHTML(item.reviewee_data.reviewee_name)}
                  </Text>
                  <View>
                    <View style={{ flexDirection: 'row' }}>
                      {this.renderBadge(item.reviewee_data)}
                    </View>
                  </View>
                </View>
              </View>
            </View>
            <View style={styles.separator} />
            <View style={styles.actionContainer}>
              <Text style={styles.actionText}>
                {item.reputation_data.action_message}
              </Text>
              <Image
                source={{ uri: 'icon_caret_next_green' }}
                style={{ height: 13, width: 9, marginLeft: 8 }}
              />
            </View>
          </View>
        </TouchableOpacity>
      </View>
    )
  }

  renderSeparator = () => {
    if (DeviceInfo.isTablet()) {
      return null
    }
    return <View style={{ marginTop: 8 }} />
  }

  renderSectionHeader = item => (
    <View style={styles.sectionHeaderContainer}>
      <Text style={styles.sectionTitleText}>{item.section.title}</Text>
    </View>
  )

  render = () => (
    <View style={{ flex: 1 }}>
      <FlatList
        style={styles.wrapper}
        scrollEnabled={this.props.isOnboardingScrollEnabled}
        onScroll={({
          nativeEvent: { contentOffset: { y }, contentSize: { height } },
        }) => {
          const windowHeight = Dimensions.get('window').height
          if (windowHeight + y >= height) {
            if (!this.props.loadingStatus[this.props.pageIndex]) {
              if (this.props.errorStatus[this.props.pageIndex]) {
                this.loadData$.next()
              } else {
                const params = this.props.params[this.props.pageIndex]
                if (params.page < 1) {
                  this.props.setLastPage(this.props.pageIndex)
                  return
                }
                this.props.updateParams(
                  params,
                  { page: params.page + 1 },
                  this.props.pageIndex,
                )
              }
            }
          }
        }}
        keyExtractor={(item, _) => item.inbox_id}
        ListHeaderComponent={this.listHeader}
        ListFooterComponent={this.listFooterComponent}
        ItemSeparatorComponent={this.renderSeparator}
        data={this.props.reviewLists[this.props.pageIndex]}
        onRefresh={this.handleRefresh}
        refreshing={false}
        renderItem={this.renderItem}
      />

      <View style={styles.filterContainer}>
        <FilterButton onPress={this.handleFilter} />
      </View>
    </View>
  )
}

export default connect(mapStateToProps, mapDispatchToProps)(ReviewPage)
