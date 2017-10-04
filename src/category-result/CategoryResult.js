
import React, { Component } from 'react';
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
  TouchableWithoutFeedback
} from 'react-native';

import {
  ReactCategoryResultManager,
  EventManager,
  TKPReactAnalytics,
  ReactTopAdsManager,
  ReactInteractionHelper
} from 'NativeModules'

import Swiper from 'react-native-swiper';
import Icon from 'react-native-vector-icons/Ionicons'
import DeviceInfo from 'react-native-device-info';

import GridProductCell from './GridProductCell'
import ListProductCell from './ListProductCell'
import ThumbnailProductCell from './ThumbnailProductCell'
import Banner from './Banner'

import PageControl from 'react-native-page-control'

const screenWidth = Dimensions.get('window').width;

const changeLayoutCellNativeEventEmitter = new NativeEventEmitter(EventManager);


class CategoryResult extends React.PureComponent {

  componentWillMount() {
    this.subscription = changeLayoutCellNativeEventEmitter.addListener("changeLayoutCell", (cellType) => {
      this.setState({
        cellType: cellType,
        numColumns: this._numColumns(cellType)
      })
    });
  }

  componentWillUnmount() {
    this.subscription.remove();
  }

  constructor(props) {
    super(props);
    let uriNext = this.props.navigation.state.params.categoryResult.data.paging._uri_next;
    let uriNextNumber = -1
    if (uriNext != null && uriNext != "") {
      uriNextNumber = Number(this._getParameterByName('start', uriNext));
    }
    this.props.navigation.state.params.topAdsResult.type = 'topAds'

    let topAdsDummy = { data: [], type: 'topAdsDummy' }
    let topAdsDummy2 = { data: [], type: 'topAdsDummy' }
    let topAdsDummy3 = { data: [], type: 'topAdsDummy' }

    let initialDataSource = [this.props.navigation.state.params.topAdsResult, topAdsDummy, topAdsDummy2, topAdsDummy3]
    initialDataSource = initialDataSource.concat(this.props.navigation.state.params.categoryResult.data.products)

    let numColumns = this._numColumns(this.props.navigation.state.params.cellType)

    this.state = {
      dataSource: initialDataSource,
      start: uriNextNumber,
      isLoading: false,
      isSubCategoryExpanded: false,
      cellType: this.props.navigation.state.params.cellType,
      numColumns: numColumns,
      refreshing: false,
      bannerAutoplay: true,
      bannerCurrentIndex: 0,
      isErrorShown: false
    };
  }

  _numColumns = (cellType) => {
    if (cellType == 1) {
      return DeviceInfo.isTablet() ? 4 : 2
    } else {
      return DeviceInfo.isTablet() ? 2 : 1
    }
  }

  _getParameterByName = (name, url) => {
    if (!url) url = window.location.href;
    name = name.replace(/[\[\]]/g, "\\$&");
    var regex = new RegExp("[?&]" + name + "(=([^&#]*)|&|#|$)"),
      results = regex.exec(url);
    if (!results) return null;
    if (!results[2]) return '';
    return decodeURIComponent(results[2].replace(/\+/g, " "));
  }

  _renderTopAdsSquareCell = (item) => {
    return (
      item.item.data.map((child) =>
        <GridProductCell key={child.id} cellData={child} isTopAds={true} navigation={this.props.navigation} tracker={() => {
          TKPReactAnalytics.trackPromoClickWithDictionary({
            name: child.product.name,
            id: child.product.id,
            url: child.product.relative_uri,
            price: child.product.price_format
          })
          ReactTopAdsManager.sendClickImpressionWithClickUrlString(child.product_click_url)
        }}
        />
      )
    )
  }

  _renderTopAdsListCell = (item) => {
    return (
      item.item.data.map((child) =>
        <ListProductCell key={child.product.id} cellData={child} isTopAds={true} navigation={this.props.navigation} tracker={() => {
          TKPReactAnalytics.trackPromoClickWithDictionary({
            name: child.product.name,
            id: child.product.id,
            url: child.product.relative_uri,
            price: child.product.price_format,
          })
          ReactTopAdsManager.sendClickImpressionWithClickUrlString(child.product_click_url)
        }} />
      )
    )
  }

  _isCellTypeIsList = () => {
    return this.state.cellType == 2
  }

  _isCellTypeisGrid = () => {
    return this.state.cellType == 1
  }

  _isCellTypeisThumbnail = () => {
    return this.state.cellType == 0
  }

  _didPressTopAdsInformationIcon = () => {
    ReactCategoryResultManager.showTopAdsInfoActionSheet()
  }

  _renderProductCell = (item, index) => {
    if (item.item.type == 'topAds') {
      if (item.item.data != null && item.item.data.length > 0) {
        return (
          <View style={{ backgroundColor: 'white' }}>
            <View style={{ height: 15, backgroundColor: '#f1f1f1', borderBottomWidth: 1, borderColor: 'rgba(224,224,224,1)' }}></View>
            <TouchableOpacity style={{ height: 30, width: 100, flexDirection: 'row', alignItems: 'center', justifyContent: 'flex-start' }}
              onPress={this._didPressTopAdsInformationIcon}>
              <Text style={{ fontSize: 12, marginLeft: 10, color: 'rgba(0,0,0,0.38)' }}>Promoted</Text>
              <Icon style={{ marginLeft: 6 }} color='rgba(153,153,153,1)' name='ios-information-circle-outline' size={13} />
            </TouchableOpacity>
            <View style={{ flexDirection: 'row', flexWrap: 'wrap' }}>
              {this._isCellTypeIsList() ? this._renderTopAdsListCell(item) : this._renderTopAdsSquareCell(item)}
            </View>
            <View style={{ height: 15, width: screenWidth, backgroundColor: '#f1f1f1', borderTopWidth: 1, borderBottomWidth: 1, borderColor: 'rgba(224,224,224,1)' }}></View>
          </View>
        )
      } else {
        <View />
      }
    }
    else if (item.item.type == 'topAdsDummy') {
      return (
        <View />
      )
    }
    // if not topAds
    else {
      if (this._isCellTypeIsList()) {
        return <ListProductCell cellData={item.item} navigation={this.props.navigation} tracker={() => {
          TKPReactAnalytics.trackEvent({
            name: 'clickCategory',
            category: 'Kategori',
            action: 'Click Product',
            label: item.item.product_id
          })
        }
        } didTapWishlist={(isOnWishlist) =>
          item.item.isOnWishlist = isOnWishlist
        } />
      } else if (this._isCellTypeisGrid()) {
        return <GridProductCell cellData={item.item} navigation={this.props.navigation} tracker={() => {
          TKPReactAnalytics.trackEvent({
            name: 'clickCategory',
            category: 'Kategori',
            action: 'Click Product',
            label: item.item.product_id
          })
        }
        }
          didTapWishlist={(isOnWishlist) =>
            item.item.isOnWishlist = isOnWishlist
          } />
      } else {
        return <ThumbnailProductCell cellData={item.item} navigation={this.props.navigation} tracker={() => {
          TKPReactAnalytics.trackEvent({
            name: 'clickCategory',
            category: 'Kategori',
            action: 'Click Product',
            label: item.item.product_id
          })
        }
        }
          didTapWishlist={(isOnWishlist) =>
            item.item.isOnWishlist = isOnWishlist
          } />
      }
    }
  }

  handlePageChange = (event) => this.setState({ bannerCurrentIndex: event.nativeEvent.page })

  _renderHeader = () => {
    let expandedArrowIconString = this.state.isSubCategoryExpanded ? 'ios-arrow-up' : 'ios-arrow-down'
    let subCategoriesBorderWidth = this.props.navigation.state.params.categoryIntermediaryResult.isRevamp == true ? 0 : 1
    let subCategoriesBackgroundColor = this.props.navigation.state.params.categoryIntermediaryResult.isRevamp == true ? '#f1f1f1' : 'white'
    let bannerMarginBottom = 10
    let subCategoriesView = <View />
    let hideShowView = <View />

    if (typeof this.props.navigation.state.params.categoryIntermediaryResult.children != 'undefined') {
      let childrenWillBeShowed = this.state.isSubCategoryExpanded ? this.props.navigation.state.params.categoryIntermediaryResult.nonHiddenChildren : this.props.navigation.state.params.categoryIntermediaryResult.nonExpandedChildren
      let hideShowLabel = this.state.isSubCategoryExpanded ? ('Sembunyikan Lainnya') : 'Lihat Lainnya'
      hideShowView = this.props.navigation.state.params.categoryIntermediaryResult.children.length > (this.props.navigation.state.params.categoryIntermediaryResult.isRevamp ? 9 : 6) ? (
        <TouchableOpacity
          onPress={() => {
            TKPReactAnalytics.trackEvent({
              name: 'clickCategory',
              category: 'Category Page - ' + this.props.navigation.state.params.categoryIntermediaryResult.rootCategoryId,
              action: 'Category Breakdown',
              label: 'Lihat Lainnya'
            })
            this.setState({
              isSubCategoryExpanded: !this.state.isSubCategoryExpanded
            })
          }}
          style={{ marginTop: 14, marginBottom: 25, width: screenWidth, flexDirection: 'row', justifyContent: 'center', alignItems: 'center' }}>
          <Text style={{ fontSize: 12, color: 'rgba(66,181,73,1)' }}>
            {hideShowLabel}
          </Text>
          <Icon style={{ marginLeft: 6 }} name={expandedArrowIconString} size={15} color='rgba(66,181,73,1)' />
        </TouchableOpacity>) : (<View></View>)


      subCategoriesView = childrenWillBeShowed.map((child, index) =>
        this.props.navigation.state.params.categoryIntermediaryResult.isRevamp == true ?
          (
            <TouchableOpacity
              key={child.id}
              style={{ height: 137, width: screenWidth / 3, flexDirection: 'row', justifyContent: 'center', alignItems: 'center' }}
              onPress={() => {
                TKPReactAnalytics.trackEvent({
                  name: 'clickCategory',
                  category: 'Category Page - ' + child.rootCategoryId,
                  action: 'Category',
                  label: child.id
                })
                { this.props.navigation.navigate('tproutes', { url: 'tokopedia://category/' + child.id + '?categoryName=' + escape(child.name) }); }
              }}>
              <View style={{
                height: 127,
                flex: 1,
                margin: 5,
                justifyContent: 'center',
                alignItems: 'center',
                backgroundColor: 'rgba(255,255,255,0.9)',
                borderRadius: 3,
                shadowOffset: { height: 1, width: 1 },
                shadowColor: "#000000",
                shadowOpacity: 0.1
              }}>
                <Image
                  style={{ height: 100, alignSelf: 'stretch', marginTop: 10 }}
                  key={child.thumbnailImage}
                  source={{ uri: child.thumbnailImage }}
                  resizeMode='contain' />
                <Text style={{
                  fontSize: 12,
                  textAlign: 'center',
                  color: 'rgba(0,0,0,0.54)',
                  fontWeight: '300',
                  marginBottom: 17
                }}>
                  {child.name.toUpperCase()}
                </Text>
              </View>
            </TouchableOpacity>
          ) :
          (
            <TouchableOpacity
              key={child.id}
              style={{
                height: 38,
                width: (screenWidth / 2),
                flexDirection: 'row',
                justifyContent: 'space-between',
                alignItems: 'center',
                flexWrap: 'wrap'
              }}
              onPress={() => {
                TKPReactAnalytics.trackEvent({
                  name: 'clickCategory',
                  category: 'Category Page - ' + child.rootCategoryId,
                  action: 'Category',
                  label: child.id
                })
                { this.props.navigation.navigate('tproutes', { url: 'tokopedia://category/' + child.id + '?categoryName=' + escape(child.name) }); }
              }}
              activeOpacity={1}>
              <Text
                numberOfLines={1}
                style={{ 
                  width: (screenWidth / 2) - 20,
                 paddingLeft: 10, 
                 textAlign: 'left', 
                 fontSize: 12, 
                 color: 'rgba(0,0,0,0.7)' }}
                key={child.id}>
                {child.name}
              </Text>
              <Icon style={{ paddingRight: 10 }}
                   name='ios-arrow-forward'
                   size={15} 
                   color='rgba(0,0,0,0.7)' />
              {index % 2 == 0 ?
                (
                  <View style={styles.subCategoryVerticalSeparator} />
                ) :
                index != childrenWillBeShowed.length - 1 ?
                  (
                    <View style={styles.subCategoryHorizontalSeparator} />
                  ) :
                  (
                    <View style={{ position: 'absolute' }} />
                  )
              }
            </TouchableOpacity>
          )
      )
    }

    let headerImageOrBannerView = () => {
      if (this.props.navigation.state.params.categoryIntermediaryResult.isRevamp == true) {
        if (this.props.navigation.state.params.categoryIntermediaryResult.banner.images.length > 0) {
          const numberOfBanners = this.props.navigation.state.params.categoryIntermediaryResult.banner.images.length

          return (
            <View>
              <Banner onPageChange={this.handlePageChange}>
                {this.props.navigation.state.params.categoryIntermediaryResult.banner.images.map((image, index) => (
                  <TouchableWithoutFeedback key={image.title} onPress={(e) => {
                    TKPReactAnalytics.trackEvent({
                      name: 'clickCategory',
                      category: 'Category Page - ' + this.props.navigation.state.params.categoryIntermediaryResult.rootCategoryId,
                      action: 'Banner Click',
                      label: image.title
                    })
                    this.props.navigation.navigate('tproutes', { url: image.appLinks })
                  }}>
                    <Image
                      style={[styles.pageStyle]}
                      source={{ uri: image.imageUrl }}
                      key={image.imageUrl}
                      resizeMode={'cover'}
                    />
                  </TouchableWithoutFeedback>
                ))}
              </Banner>
              <View style={[StyleSheet.absoluteFill, { justifyContent: 'flex-end', marginBottom: 5 }]} pointerEvents="box-none">
                <PageControl numberOfPages={numberOfBanners} currentPageIndicatorTintColor='#ff5732' currentPage={this.state.bannerCurrentIndex} indicatorSize={{ width: 8, height: 8 }} indicatorStyle={{ marginLeft: 2 }} />
              </View>
            </View>
          )
        } else if (this.props.navigation.state.params.categoryIntermediaryResult.headerImage != "") {
          return (
            <View style={{ height: 150, width: screenWidth, flexDirection: 'row' }}>
              <Image style={{ flex: 1, marginLeft: -85 }}
                     key={this.props.navigation.state.params.categoryIntermediaryResult.headerImage}
                     source={{ uri: this.props.navigation.state.params.categoryIntermediaryResult.headerImage }}/>
              <Text style={{
                position: 'absolute', 
                alignSelf: 'center', 
                marginLeft: 15, 
                fontSize: 24, 
                backgroundColor: 'transparent',
                color: 'white',
                fontWeight: '300',
                shadowOffset: { height: 1, width: 1 },
                shadowColor: "#000000",
                shadowRadius: 1,
                shadowOpacity: 0.5
              }}>{this.props.navigation.state.params.categoryIntermediaryResult.name.toUpperCase()}</Text>
            </View>
          )
        } else {
          return (
            <View />
          )
        }
      } else {
        return (
          <Text />
        )
      }
    }

    let totalProductsView = <Text style={{
           marginLeft: 10,
           fontSize: 14, 
           color: 'rgba(0,0,0,0.54)', 
           fontWeight: '600' }}>
              {this.props.navigation.state.params.categoryResult.header.total_data} Produk
           </Text>

    return (
      <View style={{ backgroundColor: '#f1f1f1' }}>
        {headerImageOrBannerView()}
        <View style={{ 
          borderTopWidth: subCategoriesBorderWidth,
          borderBottomWidth: subCategoriesBorderWidth,
          backgroundColor: subCategoriesBackgroundColor, 
          borderColor: 'rgba(224,224,224,1)', 
          flexDirection: 'row', flexWrap: 'wrap'
          }}>
          {subCategoriesView}
        </View>
        {hideShowView}
        {totalProductsView}
      </View>
    )
  };

  _renderFooter = () => {
    let loadingView = this.state.isLoading ? (<ActivityIndicator style={{ height: 50 }} />) : (<View />)
    return (
      <View>
        {loadingView}
      </View>
    )
  }

  _loadData = () => {
    if (!this.state.isLoading && this.state.start != -1) {
      this.setState({
        isLoading: true
      })
      ReactCategoryResultManager.getNextPageCategoryResultProductWithCategoryId(
        this.props.navigation.state.params.categoryResult.data.departmentId,
        this.state.start,
        this.props.navigation.state.params.categoryParams
      ).then((response) => {

        this.setState({
          isErrorShown: false
        })

        let fetchedProducts = response.data.products

        ReactCategoryResultManager.getNextPageCategoryResultTopAdsWithCategoryId(
          this.props.navigation.state.params.categoryResult.data.departmentId,
          this.state.start / 12,
          this.props.navigation.state.params.topAdsFilter
        ).then((topAdsResponse) => {

          let uriNext = response.data.paging._uri_next;
          let uriNextNumber = -1;
          if (response.data.paging._uri_next != "") {
            uriNextNumber = Number(this._getParameterByName('start', uriNext));
          }
          topAdsResponse.type = 'topAds'

          let topAdsDummy = { data: [], type: 'topAdsDummy' }
          let topAdsDummy2 = { data: [], type: 'topAdsDummy' }
          let topAdsDummy3 = { data: [], type: 'topAdsDummy' }


          this.setState({
            dataSource: this.state.dataSource.concat(topAdsResponse).concat(topAdsDummy).concat(topAdsDummy2).concat(topAdsDummy3).concat(fetchedProducts),
            start: uriNextNumber,
            isLoading: false
          });
        }).catch((error) => {
          if (!this.state.isErrorShown) {
            ReactInteractionHelper.showErrorStickyAlert(error.message)
          }
          this.setState({
            isLoading: false,
            isErrorShown: true
          })
        })
      }).catch((error) => {
        if (!this.state.isErrorShown) {
          ReactInteractionHelper.showErrorStickyAlert(error.message)
        }
        this.setState({
          isLoading: false,
          isErrorShown: true
        })
      })
    }
  }

  keyExtractor = (item, index) => {
    return index
  }

  render() {
    // we must set key for cellType reason, if we do not use it will show error when user tap change layout cell
    return (
      <FlatList data={this.state.dataSource}
        renderItem={this._renderProductCell}
        numColumns={this.state.numColumns}
        key={(this.state.cellType)}
        keyExtractor={this.keyExtractor}
        onEndReached={this._loadData}
        ListHeaderComponent={this._renderHeader}
        ListFooterComponent={this._renderFooter}
        refreshing={this.state.refreshing}
        onRefresh={() => {
          this.state.dataSource = []
          this.state.start = 0
          this._loadData()
        }}
        style={{ backgroundColor: '#f1f1f1' }}
      />
    )
  }
}

const styles = StyleSheet.create({
  pageStyle: {
    alignItems: 'center',
    width: 375,
    height: 150,
    resizeMode: 'contain',
  },
  subCategoryVerticalSeparator: {
    position: 'absolute',
    right: 0,
    top: 0,
    marginTop: 6,
    width: 1,
    height: 25,
    backgroundColor: 'rgba(224,224,224,1)'
  },
  subCategoryHorizontalSeparator: {
    position: 'absolute',
    right: 10,
    bottom: 0,
    height: 1,
    width: screenWidth - 20,
    backgroundColor: 'rgba(224,224,224,1)'
  }
});

module.exports = CategoryResult
