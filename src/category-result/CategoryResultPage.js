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
  TouchableWithoutFeedback,
} from 'react-native'

import {
  ReactCategoryResultManager,
  EventManager,
  TKPReactAnalytics,
  ReactTopAdsManager,
  ReactInteractionHelper,
  ReactTPRoutes,
} from 'NativeModules'

import Icon from 'react-native-vector-icons/Ionicons'
import DeviceInfo from 'react-native-device-info'
import PageControl from 'react-native-page-control'
import qs from 'qs'

import GridProductCell from './GridProductCell'
import ListProductCell from './ListProductCell'
import ThumbnailProductCell from './ThumbnailProductCell'
import Banner from './Banner'

const screenWidth = Dimensions.get('window').width

const changeLayoutCellNativeEventEmitter = new NativeEventEmitter(EventManager)

const styles = require('./CategoryResultStylesheet')

class CategoryResultPage extends PureComponent {
  constructor(props) {
    super(props)

    const numColumns = this.numColumns(
      this.props.navigation.state.params.cellType,
    )

    this.state = {
      dataSource: [],
      start: 0,
      isLoading: false,
      isSubCategoryExpanded: false,
      cellType: this.props.navigation.state.params.cellType,
      numColumns,
      refreshing: false,
      bannerAutoplay: true,
      bannerCurrentIndex: 0,
      isErrorShown: false,
    }

    this.props.navigation.state.params.categoryParams.rows = '12'
  }

  componentWillMount() {
    this.subscription = changeLayoutCellNativeEventEmitter.addListener(
      'changeLayoutCell',
      cellType => {
        this.setState({
          cellType,
          numColumns: this.numColumns(cellType),
        })
      },
    )
  }

  componentDidMount() {
    this.loadData()
  }

  componentWillUnmount() {
    this.subscription.remove()
  }

  getParameterByName = (name, url) => {
    const result = qs.parse(url)
    console.log(result)
    return result[name] || null
  }

  getNextPage = uriNextPage => {
    let nextPage = null
    if (uriNextPage) {
      nextPage = Number(this.getParameterByName('start', uriNextPage))
    }
    return nextPage
  }

  handlePageChange = event =>
    this.setState({ bannerCurrentIndex: event.nativeEvent.page })

  handleOnPressBanner = index => {
    const { categoryIntermediaryResult } = this.props.navigation.state.params
    const selectedBanner = categoryIntermediaryResult.banner.images[index]
    TKPReactAnalytics.trackEvent({
      name: 'clickCategory',
      category: `Category Page - ${categoryIntermediaryResult.rootCategoryId}`,
      action: 'Banner Click',
      label: selectedBanner.title,
    })
    this.props.navigation.navigate('tproutes', {
      url: selectedBanner.appLinks,
    })
  }

  handleTopAdsInformationIcon = () => {
    ReactTopAdsManager.showTopAdsInfoActionSheet()
  }

  isCellTypeisThumbnail = () => this.state.cellType === 0

  isCellTypeisGrid = () => this.state.cellType === 1

  numColumns = cellType => {
    if (cellType === 1) {
      return DeviceInfo.isTablet() ? 4 : 2
    }
    return DeviceInfo.isTablet() ? 2 : 1
  }

  isPageReachedEnd = () => this.state.start == null

  handleOnEndReached = () => this.loadData()

  loadData = () => {
    const { categoryResult } = this.props.navigation.state.params
    if (!this.state.isLoading && !this.isPageReachedEnd()) {
      this.setState({
        isLoading: true,
      })

      const requestCategoryResult = ReactCategoryResultManager.getNextPageCategoryResultProductWithCategoryId(
        categoryResult.data.departmentId,
        this.state.start,
        this.props.navigation.state.params.categoryParams,
      ).then(categoryResultResponse => categoryResultResponse)

      const requestTopAds = ReactCategoryResultManager.getNextPageCategoryResultTopAdsWithCategoryId(
        categoryResult.data.departmentId,
        this.state.start / 12,
        this.props.navigation.state.params.topAdsFilter,
      ).then(topAdsResponse => topAdsResponse)

      Promise.all([requestCategoryResult, requestTopAds])
        .then(([categoryResultResponse, topAdsResponse]) => {
          this.setState({
            isErrorShown: false,
          })

          const nextPage = this.getNextPage(
            categoryResultResponse.data.paging._uri_next,
          )
          topAdsResponse.type = 'topAds'

          const topAdsDummy = { data: [], type: 'topAdsDummy' }

          this.setState({
            dataSource: this.state.dataSource
              .concat(topAdsResponse)
              .concat(topAdsDummy)
              .concat(topAdsDummy)
              .concat(topAdsDummy)
              .concat(categoryResultResponse.data.products),
            start: nextPage,
            isLoading: false,
          })
        })
        .catch(error => {
          if (!this.state.isErrorShown) {
            ReactInteractionHelper.showErrorStickyAlert(error.message)
          }
          this.setState({
            isLoading: false,
            isErrorShown: true,
          })
        })
    }
  }

  keyExtractor = (item, index) => index

  isCellTypeIsList = () => this.state.cellType === 2

  renderFooter = () => {
    const loadingView = this.state.isLoading && (
      <ActivityIndicator style={{ height: 50 }} />
    )
    return <View>{loadingView}</View>
  }

  renderHeader = () => {
    const { isSubCategoryExpanded } = this.state
    const { categoryIntermediaryResult } = this.props.navigation.state.params
    const { banner } = categoryIntermediaryResult
    const {
      isRevamp,
      children,
      nonHiddenChildren,
      nonExpandedChildren,
      rootCategoryId,
      headerImage,
    } = categoryIntermediaryResult
    const { categoryResult } = this.props.navigation.state.params
    const expandedArrowIconString = isSubCategoryExpanded
      ? 'ios-arrow-up'
      : 'ios-arrow-down'
    let subCategoriesView = null
    let hideShowView = null

    if (typeof children !== 'undefined') {
      const childrenWillBeShowed = isSubCategoryExpanded
        ? nonHiddenChildren
        : nonExpandedChildren
      const hideShowLabel = isSubCategoryExpanded
        ? 'Sembunyikan Lainnya'
        : 'Lihat Lainnya'
      hideShowView =
        children.length > (isRevamp ? 9 : 6) ? (
          <TouchableOpacity
            onPress={() => {
              TKPReactAnalytics.trackEvent({
                name: 'clickCategory',
                category: `Category Page - ${rootCategoryId}`,
                action: 'Category Breakdown',
                label: 'Lihat Lainnya',
              })
              this.setState({
                isSubCategoryExpanded: !isSubCategoryExpanded,
              })
            }}
            style={styles.hideShowView}
          >
            <Text style={{ fontSize: 12, color: 'rgba(66,181,73,1)' }}>
              {hideShowLabel}
            </Text>
            <Icon
              style={{ marginLeft: 6 }}
              name={expandedArrowIconString}
              size={15}
              color="rgba(66,181,73,1)"
            />
          </TouchableOpacity>
        ) : null

      subCategoriesView = (
        <View
          style={[
            styles.subCategoriesView,
            isRevamp
              ? styles.revampedSubcategoriesView
              : styles.nonRevampedSubcategoriesView,
          ]}
        >
          {childrenWillBeShowed.length > 0 &&
            childrenWillBeShowed.map(
              (child, index) =>
                isRevamp === true ? (
                  <TouchableOpacity
                    key={child.id}
                    style={styles.revampedSubCategoriesButton}
                    onPress={() => {
                      TKPReactAnalytics.trackEvent({
                        name: 'clickCategory',
                        category: `Category Page - ${child.rootCategoryId}`,
                        action: 'Category',
                        label: child.id,
                      })
                      ReactTPRoutes.navigate(
                        `tokopedia://category/${child.id}?categoryName=${escape(
                          child.name,
                        )}`,
                      )
                    }}
                  >
                    <View style={styles.revampedSubCategoriesButtonContainer}>
                      <Image
                        style={styles.subCategoriesImage}
                        key={child.thumbnailImage}
                        source={{ uri: child.thumbnailImage }}
                        resizeMode="contain"
                      />
                      <Text style={styles.revampedSubCategoriesText}>
                        {child.name.toUpperCase()}
                      </Text>
                    </View>
                  </TouchableOpacity>
                ) : (
                  <TouchableOpacity
                    key={child.id}
                    style={styles.nonRevampedSubCategoriesButton}
                    onPress={() => {
                      TKPReactAnalytics.trackEvent({
                        name: 'clickCategory',
                        category: `Category Page - ${child.rootCategoryId}`,
                        action: 'Category',
                        label: child.id,
                      })
                      ReactTPRoutes.navigate(
                        `tokopedia://category/${child.id}?categoryName=${escape(
                          child.name,
                        )}`,
                      )
                    }}
                    activeOpacity={1}
                  >
                    <Text
                      numberOfLines={1}
                      style={styles.nonRevampedSubCategoriesText}
                      key={child.id}
                    >
                      {child.name}
                    </Text>
                    <Icon
                      style={{ paddingRight: 10 }}
                      name="ios-arrow-forward"
                      size={15}
                      color="rgba(0,0,0,0.7)"
                    />
                    {index % 2 === 0 ? (
                      <View style={styles.subCategoryVerticalSeparator} />
                    ) : index !== childrenWillBeShowed.length - 1 ? (
                      <View style={styles.subCategoryHorizontalSeparator} />
                    ) : (
                      <View style={{ position: 'absolute' }} />
                    )}
                  </TouchableOpacity>
                ),
            )}
        </View>
      )
    }

    const headerImageOrBannerView = () => {
      if (isRevamp === true) {
        if (banner.images.length > 0) {
          const numberOfBanners = banner.images.length

          return (
            <View>
              <Banner
                onPageChange={this.handlePageChange}
                onPress={this.handleOnPressBanner}
              >
                {banner.images.map(image => (
                  <Image
                    style={[styles.pageStyle]}
                    source={{ uri: image.imageUrl }}
                    key={image.imageUrl}
                    resizeMode={'cover'}
                  />
                ))}
              </Banner>
              <View
                style={[
                  StyleSheet.absoluteFill,
                  { justifyContent: 'flex-end', marginBottom: 5 },
                ]}
                pointerEvents="box-none"
              >
                <PageControl
                  numberOfPages={numberOfBanners}
                  currentPageIndicatorTintColor="#ff5732"
                  currentPage={this.state.bannerCurrentIndex}
                  indicatorSize={{ width: 8, height: 8 }}
                  indicatorStyle={{ marginLeft: 2 }}
                />
              </View>
            </View>
          )
        } else if (headerImage !== '') {
          return (
            <View
              style={{ height: 150, width: screenWidth, flexDirection: 'row' }}
            >
              <Image
                style={{ flex: 1, marginLeft: -85 }}
                key={headerImage}
                source={{
                  uri: headerImage,
                }}
              />
              <Text style={styles.headerTitle}>
                {categoryIntermediaryResult.name.toUpperCase()}
              </Text>
            </View>
          )
        }
        return null
      }
      return <Text />
    }

    const totalProductsView = (
      <Text
        style={{
          marginLeft: 10,
          fontSize: 14,
          color: 'rgba(0,0,0,0.54)',
          fontWeight: '600',
        }}
      >
        {categoryResult.header.total_data} Produk
      </Text>
    )

    return (
      <View style={{ backgroundColor: '#f1f1f1' }}>
        {headerImageOrBannerView()}
        {subCategoriesView}
        {hideShowView}
        {totalProductsView}
      </View>
    )
  }

  renderProductCell = item => {
    if (item.item.type === 'topAds') {
      if (item.item.data && item.item.data.length > 0) {
        return (
          <View style={{ backgroundColor: 'white' }}>
            <View style={styles.topAdsContainer} />
            <TouchableOpacity
              style={styles.topAdsHeader}
              onPress={this.handleTopAdsInformationIcon}
            >
              <Text style={styles.promotedText}>Promoted</Text>
              <Icon
                style={{ marginLeft: 6 }}
                color="rgba(153,153,153,1)"
                name="ios-information-circle-outline"
                size={13}
              />
            </TouchableOpacity>
            <View style={{ flexDirection: 'row', flexWrap: 'wrap' }}>
              {this.isCellTypeIsList() ? (
                this.renderTopAdsListCell(item)
              ) : (
                this.renderTopAdsSquareCell(item)
              )}
            </View>
            <View style={styles.topAdsBottomMargin} />
          </View>
        )
      }
      return null
    } else if (item.item.type === 'topAdsDummy') {
      return null
    }
    // if not topAds
    if (this.isCellTypeIsList()) {
      return (
        <ListProductCell
          cellData={item.item}
          navigation={this.props.navigation}
          tracker={() => {
            TKPReactAnalytics.trackEvent({
              name: 'clickCategory',
              category: 'Kategori',
              action: 'Click Product',
              label: item.item.product_id,
            })
          }}
          didTapWishlist={isOnWishlist =>
            (item.item.isOnWishlist = isOnWishlist)}
        />
      )
    } else if (this.isCellTypeisGrid()) {
      return (
        <GridProductCell
          cellData={item.item}
          navigation={this.props.navigation}
          tracker={() => {
            TKPReactAnalytics.trackEvent({
              name: 'clickCategory',
              category: 'Kategori',
              action: 'Click Product',
              label: item.item.product_id,
            })
          }}
          didTapWishlist={isOnWishlist =>
            (item.item.isOnWishlist = isOnWishlist)}
        />
      )
    }
    return (
      <ThumbnailProductCell
        cellData={item.item}
        navigation={this.props.navigation}
        tracker={() => {
          TKPReactAnalytics.trackEvent({
            name: 'clickCategory',
            category: 'Kategori',
            action: 'Click Product',
            label: item.item.product_id,
          })
        }}
        didTapWishlist={isOnWishlist => (item.item.isOnWishlist = isOnWishlist)}
      />
    )
  }

  renderTopAdsSquareCell = item =>
    item.item.data.map(child => (
      <GridProductCell
        key={child.id}
        cellData={child}
        isTopAds
        navigation={this.props.navigation}
        tracker={() => {
          TKPReactAnalytics.trackPromoClickWithDictionary({
            name: child.product.name,
            id: child.product.id,
            url: child.product.relative_uri,
            price: child.product.price_format,
          })
          ReactTopAdsManager.sendClickImpressionWithClickUrlString(
            child.product_click_url,
          )
        }}
      />
    ))

  renderTopAdsListCell = item =>
    item.item.data.map(child => (
      <ListProductCell
        key={child.product.id}
        cellData={child}
        isTopAds
        navigation={this.props.navigation}
        tracker={() => {
          TKPReactAnalytics.trackPromoClickWithDictionary({
            name: child.product.name,
            id: child.product.id,
            url: child.product.relative_uri,
            price: child.product.price_format,
          })
          ReactTopAdsManager.sendClickImpressionWithClickUrlString(
            child.product_click_url,
          )
        }}
      />
    ))

  render() {
    // we must set key for cellType reason, if we do not use it will show error when user tap change layout cell
    return (
      <FlatList
        data={this.state.dataSource}
        renderItem={this.renderProductCell}
        numColumns={this.state.numColumns}
        key={this.state.cellType}
        keyExtractor={this.keyExtractor}
        onEndReached={this.handleOnEndReached}
        ListHeaderComponent={this.renderHeader}
        ListFooterComponent={this.renderFooter}
        refreshing={this.state.refreshing}
        onRefresh={() => {
          this.setState(
            {
              dataSource: [],
              start: 0,
            },
            () => this.loadData(),
          )
        }}
        style={{ backgroundColor: '#f1f1f1' }}
      />
    )
  }
}

export default CategoryResultPage
