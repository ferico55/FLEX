import Navigator from 'native-navigation'
import find from 'lodash/find'
import indexOf from 'lodash/indexOf'
import { bindActionCreators } from 'redux'
import { connect } from 'react-redux'
import React, { Component } from 'react'
import {
  StyleSheet,
  Text,
  View,
  TouchableOpacity,
  Image,
  FlatList,
  RefreshControl,
} from 'react-native'
import SearchBar from 'react-native-search-bar'

import color from '../Helper/Color'
import NoResultView from '../Components/NoResultView'
import * as Actions from '../Redux/Actions/AddPromoActions'

function mapStateToProps(state) {
  return {
    ...state.addPromoReducer,
  }
}

function mapDispatchToProps(dispatch) {
  return bindActionCreators(Actions, dispatch)
}

const styles = StyleSheet.create({
  progressBarContainer: {
    height: 2,
    flexDirection: 'row',
  },
  progressBarValueSide: {
    flex: 1,
    backgroundColor: color.mainGreen,
  },
  progressBarEmptySide: {
    flex: 2,
    backgroundColor: color.backgroundGrey,
  },
  container: {
    flex: 1,
    backgroundColor: 'white',
  },
  noProductContainer: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
  },
  noProductBoxImage: {
    height: 112,
    width: 181,
    marginBottom: 10,
  },
  noResultDescLabel: {
    fontSize: 12,
    marginBottom: 5,
    color: color.greyText,
  },
  productCellContainer: {
    height: 90,
    flexDirection: 'row',
    alignItems: 'center',
  },
  productCellChecklistContainer: {
    width: 45,
    alignItems: 'center',
    justifyContent: 'center',
  },
  productCellChecklistImageView: {
    height: 15,
    width: 15,
    borderRadius: 3,
  },
  productCellChecklistView: {
    height: 15,
    width: 15,
    borderWidth: 1,
    borderRadius: 3,
    borderColor: color.darkerGrey,
    overflow: 'hidden',
  },
  productCellInfoContainer: {
    flex: 1,
    paddingRight: 15,
    height: 90,
    justifyContent: 'center',
  },
  productNameLabel: {
    marginRight: 15,
  },
  productTagContainer: {
    paddingHorizontal: 5,
    marginTop: 5,
    height: 17,
    borderColor: color.darkerGrey,
    borderWidth: 0.5,
    borderRadius: 3,
    alignItems: 'center',
    justifyContent: 'center',
  },
  productTagLabel: {
    fontSize: 10,
    color: color.greyText,
  },
  productUnderline: {
    height: 1,
    backgroundColor: color.lineGrey,
    position: 'absolute',
    bottom: 0,
    right: 0,
    left: 0,
  },
  footerContainer: {
    flex: 1,
    height: 59,
    flexDirection: 'row',
    alignItems: 'center',
    paddingHorizontal: 20,
    borderTopWidth: 1,
    borderColor: color.lineGrey,
    position: 'absolute',
    bottom: 0,
    left: 0,
    right: 0,
  },
  footerCountLabel: {
    fontWeight: 'bold',
    color: color.blackText,
    fontSize: 16,
    marginHorizontal: 5,
  },
  footerProductLabel: {
    color: color.blackText,
    fontSize: 13,
  },
  footerGreenLabel: {
    fontSize: 16,
    textAlign: 'right',
    color: color.mainGreen,
  },
})

class ChooseProductPage extends Component {
  constructor(props) {
    super(props)
    this.state = {
      searchCancelButtonShown: false,
    }
  }
  componentWillMount = () => {
    const tempArray = [].concat(this.props.selectedProducts)
    this.props.setSelectedProductsAddPromo(tempArray)
  }
  componentDidUpdate = () => {
    if (this.props.isCallNextDataNeeded) {
      this.props.getProductListAddPromo({
        shopId: this.props.authInfo.shop_id,
        keyword: this.props.productKeyword,
        page: this.props.currentStart,
        promotedStatus: this.props.productFilter.promotedStatus,
        etalase: this.props.productFilter.etalase,
      })
    }
  }
  onAppear = () => {
    this.searchData('')
  }
  getData = () => {
    this.closeKeyboard()
    if (!this.props.productEOF) {
      this.props.getProductListAddPromo({
        shopId: this.props.authInfo.shop_id,
        keyword: this.props.productKeyword,
        page: this.props.currentStart,
        promotedStatus: this.props.productFilter.promotedStatus,
        etalase: this.props.productFilter.etalase,
      })
    }
  }
  searchData = keyword => {
    this.closeKeyboard()
    this.props.getProductListAddPromo({
      shopId: this.props.authInfo.shop_id,
      keyword,
      page: 0,
      promotedStatus: this.props.productFilter.promotedStatus,
      etalase: this.props.productFilter.etalase,
    })
  }
  checkIfProductIsSelected = product => {
    const selectedMatchedProduct = find(
      this.props.tempSelectedProducts,
      selectedProduct => selectedProduct.product_id === product.product_id,
    )
    return !!selectedMatchedProduct
  }
  closeKeyboard = () => {
    this.refs.searchBar.unFocus()
  }
  handleCancelButtonPress = () => {
    this.searchData('')
  }
  handleSettingKeyboardCancelButton = () => {
    if (!this.state.searchCancelButtonShown) {
      this.setState({
        searchCancelButtonShown: true,
      })
    }
  }
  handleCellSelected = product => {
    const tempSelectedProducts = this.props.tempSelectedProducts
    const foundProduct = find(
      this.props.tempSelectedProducts,
      selectedProduct => selectedProduct.product_id === product.product_id,
    )

    if (foundProduct) {
      const index = indexOf(tempSelectedProducts, foundProduct)
      tempSelectedProducts.splice(index, 1)
    } else {
      tempSelectedProducts.push(product)
    }

    this.props.setSelectedProductsAddPromo(tempSelectedProducts)
  }
  handleFilterButtonPressed = () => {
    Navigator.push('FilterPage', {
      shopId: this.props.authInfo.shop_id,
      isFromAddPromo: true,
    })
  }
  handleSaveButtonTapped = () => {
    this.props.saveSelectedProductsAddPromo()
    Navigator.pop()
  }
  renderNoProduct = () => {
    if (this.props.isFailedFetch) {
      return (
        <NoResultView
          title={'Gagal Mendapatkan Data'}
          desc={'Terjadi masalah pada saat pengambilan data'}
          buttonTitle={'Coba Lagi'}
          buttonAction={() => this.searchData('')}
        />
      )
    }
    return (
      <NoResultView
        title={'Hasil Tidak Ditemukan'}
        desc={'Silahkan coba lagi atau ganti kata kunci.'}
      />
    )
  }
  renderItem = item => {
    const isSelected = this.checkIfProductIsSelected(item.item)
    const isFull = this.props.tempSelectedProducts.length >= this.props.limit
    const isMustBeDisabled = isFull && !isSelected
    const isClickDisabled =
      this.props.groupType === 0
        ? isMustBeDisabled
        : item.item.product_is_promoted || isMustBeDisabled

    return (
      <TouchableOpacity
        onPress={() => this.handleCellSelected(item.item)}
        disabled={isClickDisabled}
      >
        <View
          style={[
            styles.productCellContainer,
            {
              backgroundColor: isSelected
                ? color.lightBackgroundGreen
                : 'white',
              opacity: isClickDisabled ? 0.4 : 1,
            },
          ]}
        >
          <View style={styles.productCellChecklistContainer}>
            {isSelected ? (
              <Image
                style={styles.productCellChecklistImageView}
                source={{ uri: 'Icon_check_green_bg' }}
              />
            ) : (
              <View style={styles.productCellChecklistView} />
            )}
          </View>
          <View style={styles.productCellInfoContainer}>
            <Text style={styles.productNameLabel} numberOfLines={2}>
              {item.item.product_name}
            </Text>
            {item.item.product_is_promoted && (
              <View style={{ flexDirection: 'row' }}>
                <View style={styles.productTagContainer}>
                  <Text style={styles.productTagLabel}>
                    {item.item.group_name !== '' ? (
                      item.item.group_name
                    ) : (
                      'Promoted'
                    )}
                  </Text>
                </View>
              </View>
            )}
            <View style={styles.productUnderline} />
          </View>
        </View>
      </TouchableOpacity>
    )
  }
  render = () => {
    const filterImage = {
      uri: 'icon_filter',
      scale: 3,
    }

    return (
      <Navigator.Config
        title="Pilih Produk"
        onAppear={this.onAppear}
        rightImage={filterImage}
        onRightPress={this.handleFilterButtonPressed}
      >
        <View style={{ flex: 1 }}>
          <View style={styles.container}>
            <View style={{ backgroundColor: color.backgroundGrey }}>
              <SearchBar
                ref="searchBar"
                placeholder="Cari Produk"
                onFocus={this.handleSettingKeyboardCancelButton}
                onSearchButtonPress={keyword => this.searchData(keyword)}
                barTintColor={color.backgroundGrey}
                showsCancelButton={this.state.searchCancelButtonShown}
                onCancelButtonPress={this.handleCancelButtonPress}
              />
            </View>
            {this.props.productDataSource.length <= 0 &&
            !this.props.isLoading ? (
              this.renderNoProduct()
            ) : (
              <FlatList
                style={{ marginBottom: 59 }}
                keyExtractor={item => item.product_id}
                data={this.props.productDataSource}
                renderItem={this.renderItem}
                refreshControl={
                  <RefreshControl
                    refreshing={false}
                    onRefresh={() => this.searchData('')}
                  />
                }
                onEndReached={() => {
                  if (!this.props.isLoading) {
                    this.getData()
                  }
                }}
              />
            )}
          </View>
          <View style={styles.footerContainer}>
            <Text style={styles.footerCountLabel}>{`${this.props
              .tempSelectedProducts.length}/${this.props.limit}`}</Text>
            <Text style={styles.footerProductLabel}>produk terpilih</Text>
            <TouchableOpacity
              style={{ flex: 1 }}
              onPress={this.handleSaveButtonTapped}
            >
              <Text style={styles.footerGreenLabel}>Simpan</Text>
            </TouchableOpacity>
          </View>
        </View>
      </Navigator.Config>
    )
  }
}

export default connect(mapStateToProps, mapDispatchToProps)(ChooseProductPage)
