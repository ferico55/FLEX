import Navigator from 'native-navigation'
import { TKPReactAnalytics } from 'NativeModules'
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
  ActivityIndicator,
} from 'react-native'

import color from '../Helper/Color'
import BigGreenButton2 from '../Components/BigGreenButton2'
import * as AddPromoActions from '../Redux/Actions/AddPromoActions'
import * as DashboardActions from '../Redux/Actions/DashboardActions'
import * as FilterActions from '../Redux/Actions/FilterActions'

function mapStateToProps(state) {
  return {
    ...state.addPromoReducer,
  }
}

function mapDispatchToProps(dispatch) {
  return bindActionCreators(
    { ...AddPromoActions, ...DashboardActions, ...FilterActions },
    dispatch,
  )
}

const styles = StyleSheet.create({
  progressBarContainer: {
    height: 2,
    flexDirection: 'row',
  },
  progressBarValueSide: {
    backgroundColor: color.mainGreen,
  },
  progressBarEmptySide: {
    backgroundColor: color.backgroundGrey,
  },
  container: {
    flex: 1,
    backgroundColor: 'white',
  },
  separator: {
    height: 1,
    backgroundColor: color.lineGrey,
  },
  headerContainer: {
    paddingHorizontal: 16,
  },
  headerAddProductLabel: {
    color: color.blackText,
    fontSize: 24,
    marginTop: 25,
    marginBottom: 20,
  },
  headerSubContainer: {
    height: 49,
    flexDirection: 'row',
    alignItems: 'center',
  },
  headerSubBoxImage: {
    height: 13,
    width: 18,
  },
  headerSubProductCountLabel: {
    fontWeight: 'bold',
    color: color.blackText,
    fontSize: 16,
    marginHorizontal: 5,
  },
  headerSubProductLabel: {
    color: color.greyText,
    fontSize: 16,
  },
  headerSubGreenLabel: {
    fontSize: 16,
    textAlign: 'right',
    color: color.mainGreen,
  },
  noProductContainer: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
  },
  noProductBoxImage: {
    height: 130,
    width: 181,
    marginBottom: 10,
  },
  noResultDescLabel: {
    fontSize: 12,
    color: color.greyText,
  },
  productCellContainer: {
    height: 80,
    flexDirection: 'row',
    alignItems: 'center',
  },
  productCellImageContainer: {
    marginLeft: 15,
    marginRight: 9,
    height: 50,
    width: 50,
    padding: 0.5,
    borderRadius: 3,
    backgroundColor: color.lineGrey,
  },
  productCellImage: {
    flex: 1,
    backgroundColor: 'white',
    borderRadius: 3,
  },
  productCellNameLabel: {
    flex: 1,
    fontSize: 13,
  },
  productDeleteButtonContainer: {
    height: 80,
    width: 60,
    alignItems: 'center',
    justifyContent: 'center',
  },
  productDeleteButtonImage: {
    height: 18,
    width: 14,
  },
})

class AddPromoPageStep1 extends Component {
  componentDidUpdate = () => {
    if (this.props.isDonePost) {
      if (this.props.isEdit) {
        Navigator.pop()
        this.props.resetAddPromoGroupRequestState()
        this.props.setSelectedProductsAddPromo([])
        this.props.saveSelectedProductsAddPromo()
      } else {
        Navigator.dismiss()
        this.props.resetProgressAddPromo()
        this.props.changeIsNeedRefreshDashboard(true)
      }
    }
  }
  componentWillUnmount = () => {
    if (this.props.isDirectEdit) {
      this.props.resetProgressAddPromo()
    } else {
      this.props.resetAddPromoGroupRequestState()
    }
  }
  onNextButtonTapped = () => {
    if (this.props.isEdit) {
      TKPReactAnalytics.trackEvent({
        name: 'topadsios',
        category: 'ta - product',
        action: 'Click',
        label: 'Edit Group Promo - Tambah Produk',
      })
      this.props.postAddPromo({
        shopId: this.props.authInfo.shop_id,
        groupId:
          this.props.groupType === 1
            ? `${this.props.existingGroup.group_id}`
            : '0',
        selectedProducts: this.props.selectedProducts,
        maxPrice: this.props.maxPrice,
        scheduleType: 0,
        startDate: this.props.startDate,
        endDate: this.props.endDate,
        budgetType: 0,
        budgetPerDay: 0,
      })
    } else if (this.props.stepCount > 1) {
      let trackerLabel = ''
      if (this.props.groupType === 0) {
        trackerLabel = 'New Promo Step 1'
      } else if (this.props.groupType === 2) {
        trackerLabel = 'Without Group Step 1- Add Product'
      }
      TKPReactAnalytics.trackEvent({
        name: 'topadsios',
        category: 'ta - product',
        action: 'Click',
        label: trackerLabel,
      })
      Navigator.push('AddPromoPageStep2', { authInfo: this.props.authInfo })
    } else {
      TKPReactAnalytics.trackEvent({
        name: 'topadsios',
        category: 'ta - product',
        action: 'Click',
        label: 'Avaiable Group Step 1 - Add Product',
      })
      this.props.postAddPromo({
        shopId: this.props.authInfo.shop_id,
        groupId:
          this.props.groupType === 1
            ? `${this.props.existingGroup.group_id}`
            : '0',
        selectedProducts: this.props.selectedProducts,
        maxPrice: this.props.maxPrice,
        scheduleType: this.props.scheduleType,
        startDate: this.props.startDate,
        endDate: this.props.endDate,
        budgetType: this.props.budgetType,
        budgetPerDay: this.props.budgetPerDay,
      })
    }
  }
  handleAddButtonTapped = () => {
    let limit = 50
    if (300 - this.props.existingGroup.total_item < 50) {
      limit = 300 - this.props.existingGroup.total_item
    }
    this.props.changeTempFilterPromotedStatus(1)
    this.props.changeTempFilterEtalase({
      menu_id: '',
      menu_name: '',
    })
    this.props.changeAddPromoProductListFilter()
    Navigator.push('ChooseProductPage', {
      authInfo: this.props.authInfo,
      limit,
    })
  }
  deleteItem = item => {
    const selectedProducts = this.props.selectedProducts
    for (let i = 0; i < selectedProducts.length; i++) {
      if (selectedProducts[i].product_id === item.product_id) {
        selectedProducts.splice(i, 1)
        break
      }
    }

    this.props.setSelectedProductsAddPromo(selectedProducts)
    this.props.saveSelectedProductsAddPromo()
  }
  renderProgressBar = () => (
    <View style={styles.progressBarContainer}>
      <View
        style={[
          styles.progressBarValueSide,
          { flex: this.props.stepCount - (this.props.stepCount - 1) },
        ]}
      />
      <View
        style={[
          styles.progressBarEmptySide,
          { flex: this.props.stepCount - 1 },
        ]}
      />
    </View>
  )
  renderHeader = () => {
    let limit = 50
    if (300 - this.props.existingGroup.total_item < 50) {
      limit = 300 - this.props.existingGroup.total_item
    }
    return (
      <View style={styles.headerContainer}>
        {!this.props.isEdit && (
          <Text style={styles.headerAddProductLabel}>Tambah Produk</Text>
        )}
        <View style={styles.headerSubContainer}>
          <Image
            source={{ uri: 'icon_box_small' }}
            style={styles.headerSubBoxImage}
          />
          <Text style={styles.headerSubProductCountLabel}>{`${this.props
            .selectedProducts.length}/${limit}`}</Text>
          <Text style={styles.headerSubProductLabel}>
            {this.props.selectedProducts.length < 1 ? (
              'Produk'
            ) : (
              'Produk Terpilih'
            )}
          </Text>
          <TouchableOpacity
            style={{ flex: 1 }}
            onPress={this.handleAddButtonTapped}
          >
            <Text style={styles.headerSubGreenLabel}>
              {this.props.selectedProducts.length <= 0 ? 'Tambah' : 'Ubah'}
            </Text>
          </TouchableOpacity>
        </View>
      </View>
    )
  }
  renderNoProduct = () => (
    <View style={styles.noProductContainer}>
      <Image source={{ uri: 'box_empty' }} style={styles.noProductBoxImage} />
      <Text style={styles.noResultDescLabel}>
        {this.props.groupType === 2 ? (
          'Pilih produk yang akan dimasukkan ke promo.'
        ) : (
          'Pilih produk yang akan dimasukkan ke grup promo.'
        )}
      </Text>
    </View>
  )
  renderBigGreenButton = () => {
    let stepTitle = this.props.stepCount > 1 ? 'Selanjutnya' : 'Simpan'
    stepTitle = this.props.isEdit ? 'Simpan' : stepTitle
    const title = this.props.isFailedPost ? 'Coba Lagi' : stepTitle

    if (this.props.isLoadingPost) {
      return (
        <View
          style={{
            height: 52,
            justifyContent: 'center',
            alignItems: 'center',
            position: 'absolute',
            bottom: 0,
            left: 0,
            right: 0,
          }}
        >
          <ActivityIndicator />
        </View>
      )
    }
    return (
      <BigGreenButton2
        title={title}
        buttonAction={this.onNextButtonTapped}
        disabled={this.props.selectedProducts.length < 1}
      />
    )
  }
  renderItem = item => (
    <View key={item.item.product_id}>
      <View style={styles.productCellContainer}>
        <View style={styles.productCellImageContainer}>
          <Image
            source={{ uri: item.item.product_image }}
            style={styles.productCellImage}
          />
        </View>
        <Text style={styles.productCellNameLabel} numberOfLines={2}>
          {item.item.product_name}
        </Text>
        <TouchableOpacity
          onPress={() => this.deleteItem(item.item)}
          style={styles.productDeleteButtonContainer}
        >
          <Image
            source={{ uri: 'add-promo-trash' }}
            style={styles.productDeleteButtonImage}
          />
        </TouchableOpacity>
      </View>
      <View style={styles.separator} />
    </View>
  )
  render = () => {
    const navTitle = this.props.isEdit
      ? 'Tambah Produk'
      : `1 dari ${this.props.stepCount} step`
    return (
      <Navigator.Config title={navTitle}>
        <View style={{ flex: 1 }}>
          {!this.props.isEdit && this.renderProgressBar()}
          <View style={styles.container}>
            {this.renderHeader()}
            <View style={styles.separator} />
            {this.props.selectedProducts.length <= 0 ? (
              this.renderNoProduct()
            ) : (
              <FlatList
                keyExtractor={item => item.product_id}
                data={this.props.selectedProducts}
                renderItem={this.renderItem}
              />
            )}
          </View>
          {this.renderBigGreenButton()}
        </View>
      </Navigator.Config>
    )
  }
}

export default connect(mapStateToProps, mapDispatchToProps)(AddPromoPageStep1)
