import Navigator from 'native-navigation'
import { MaskService } from 'react-native-masked-text'
import React, { Component } from 'react'
import {
  StyleSheet,
  Text,
  View,
  TouchableOpacity,
  Image,
  ActivityIndicator,
} from 'react-native'
import { bindActionCreators } from 'redux'
import { connect } from 'react-redux'

import color from '../Helper/Color'
import * as Actions from '../Redux/Actions/AddPromoActions'

import arrowRight from '../Icon/arrow_right.png'

function mapStateToProps(state) {
  return state.addPromoReducer
}

function mapDispatchToProps(dispatch) {
  return bindActionCreators(Actions, dispatch)
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: color.backgroundGrey,
  },
  defaultView: {
    flex: 1,
  },
  separator: {
    height: 1,
    backgroundColor: color.lineGrey,
  },
  mainCellOuter: {
    justifyContent: 'center',
  },
  mainCell: {
    backgroundColor: 'white',
    flexDirection: 'row',
    alignItems: 'center',
    paddingHorizontal: 17,
  },
  titleLabel: {
    fontSize: 16,
    color: color.blackText,
  },
  greenValueLabel: {
    fontSize: 16,
    color: color.mainGreen,
  },
  valueSubContainer: {
    flexDirection: 'row-reverse',
    alignItems: 'center',
    flex: 1,
  },
  arrowImageViewRight: {
    height: 12,
    width: 8,
    marginLeft: 14,
  },
})

class EditPromoPage extends Component {
  componentWillUnmount = () => {
    this.props.resetProgressAddPromo()
  }
  getData = () => {
    if (this.props.promoType === 0) {
      this.props.getGroupAdDetailEdit(this.props.existingGroup.group_id)
    } else {
      this.props.getProductAdDetailEdit(this.props.adId)
    }
  }
  handleOnAppear = () => {
    this.getData()
  }
  productCellTapped = () => {
    Navigator.push('AddPromoPageStep1', {
      authInfo: this.props.authInfo,
      isEdit: true,
    })
  }
  nameCellTapped = () => {
    Navigator.push('EditPromoGroupNamePage', {
      authInfo: this.props.authInfo,
      prevName: this.props.existingGroup.group_name,
    })
  }
  groupCellTapped = () => {
    Navigator.push('AddPromoPage', {
      authInfo: this.props.authInfo,
      isEdit: true,
    })
  }
  priceCellTapped = () => {
    Navigator.push('AddPromoPageStep2', {
      authInfo: this.props.authInfo,
      isEdit: true,
    })
  }
  scheduleCellTapped = () => {
    Navigator.push('AddPromoPageStep3', {
      authInfo: this.props.authInfo,
      isEdit: true,
    })
  }
  renderNormalCell = (title, value, onPress) => (
    <TouchableOpacity
      style={styles.mainCellOuter}
      onPress={onPress}
      disabled={this.props.isLoading}
    >
      <View style={styles.mainCell}>
        <View
          style={{
            height: 64,
            justifyContent: 'center',
            marginRight: 15,
          }}
        >
          {this.props.isLoading && value === 'Tambah' ? (
            <ActivityIndicator />
          ) : (
            <Text style={{ fontSize: 16, color: color.blackText }}>
              {title}
            </Text>
          )}
        </View>
        <View style={styles.valueSubContainer}>
          <Image style={styles.arrowImageViewRight} source={arrowRight} />
          {this.props.isLoading ? (
            <ActivityIndicator />
          ) : (
            <Text style={styles.greenValueLabel}>{value}</Text>
          )}
        </View>
      </View>
      <View style={styles.separator} />
    </TouchableOpacity>
  )
  render = () => {
    const priceBidString = MaskService.toMask('money', this.props.maxPrice, {
      precision: 0,
      unit: 'Rp ',
    })

    const isPromoToko = this.props.promoType === 2
    const navTitle =
      this.props.promoType === 0
        ? 'Ubah Promo Grup'
        : this.props.promoType === 1 ? 'Ubah Promo Produk' : 'Ubah Promo Toko'

    const isGroup = this.props.promoType === 0
    const isProduct = this.props.promoType === 1
    const isShop = this.props.promoType === 2

    const isWithoutGroup = this.props.groupType === 2

    return (
      <Navigator.Config title={navTitle} onAppear={this.handleOnAppear}>
        <View style={styles.container}>
          {this.props.promoType === 0 && (
            <View>
              {this.renderNormalCell(
                `${this.props.existingGroup.total_item} Produk`,
                'Tambah',
                this.productCellTapped,
              )}
              <View style={{ height: 10 }} />
            </View>
          )}
          <View style={styles.separator} />
          {!isPromoToko &&
            (this.props.promoType === 0
              ? this.renderNormalCell(
                  'Nama Grup',
                  this.props.existingGroup.group_name,
                  this.nameCellTapped,
                )
              : this.renderNormalCell(
                  'Atur Grup',
                  this.props.existingGroup.group_id == 0
                    ? 'Tanpa Grup'
                    : this.props.existingGroup.group_name,
                  this.groupCellTapped,
                ))}
          {((isWithoutGroup && isProduct) || (isGroup || isShop)) && (
            <View>
              {this.renderNormalCell(
                'Biaya',
                priceBidString,
                this.priceCellTapped,
              )}
              {this.renderNormalCell(
                'Jadwal',
                this.props.scheduleType === 0 ? 'Tidak Dibatasi' : 'Ubah',
                this.scheduleCellTapped,
              )}
            </View>
          )}
        </View>
      </Navigator.Config>
    )
  }
}

export default connect(mapStateToProps, mapDispatchToProps)(EditPromoPage)
