import Navigator from 'native-navigation'
import { TKPReactAnalytics } from 'NativeModules'
import React, { Component } from 'react'
import { StyleSheet, Text, View, TouchableOpacity, Image } from 'react-native'
import { bindActionCreators } from 'redux'
import { connect } from 'react-redux'

import BigGreenButton2 from '../Components/BigGreenButton2'
import color from '../Helper/Color'
import * as Actions from '../Redux/Actions/FilterActions'

import arrowRightImg from '../Icon/arrow_right.png'

let reduxKey = ''
const statuses = ['Semua Status', 'Aktif', 'Tidak Terkirim', 'Tidak Aktif']
const promotedStatuses = [
  'Belum Dipromo',
  'Semua Produk',
  'Di Dalam Grup',
  'Di Luar Grup',
]

function mapStateToProps(state, ownProps) {
  if (ownProps.isFromAddPromo) {
    return {
      ...state.addPromoReducer,
    }
  }
  reduxKey = ownProps.reduxKey
  return state.promoListPageReducer[reduxKey]
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
  mainCellContainer: {
    marginBottom: 20,
  },
  mainCell: {
    backgroundColor: 'white',
    flexDirection: 'row',
    alignItems: 'center',
    paddingHorizontal: 10,
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
  selectButton: {
    position: 'absolute',
    left: 0,
    right: 0,
    bottom: 0,
  },
})

class FilterPage extends Component {
  componentDidMount = () => {
    if (this.props.isFromAddPromo) {
      this.props.changeTempFilterPromotedStatus(
        this.props.productFilter.promotedStatus,
      )
      this.props.changeTempFilterEtalase(this.props.productFilter.etalase)
    } else {
      this.props.changeTempFilterStatus({
        tempStatus: this.props.filter.status,
        key: reduxKey,
      })
      this.props.changeTempFilterGroup({
        tempGroup: {
          group_id: this.props.filter.group.group_id,
          group_name: this.props.filter.group.group_name,
        },
        key: reduxKey,
      })
    }
  }
  resetFilter = () => {
    if (this.props.isFromAddPromo) {
      this.props.changeTempFilterPromotedStatus(1)
      this.props.changeTempFilterEtalase({
        menu_id: '',
        menu_name: '',
      })
    } else {
      this.props.changeTempFilterStatus({
        tempStatus: 0,
        key: reduxKey,
      })

      this.props.changeTempFilterGroup({
        tempGroup: {
          group_id: '',
          group_name: '',
        },
        key: reduxKey,
      })
    }
  }
  statusMenuTapped = () => {
    Navigator.push('FilterDetailPage', {
      shopId: this.props.shopId,
      isStatus: true,
      reduxKey,
    })
  }
  groupMenuTapped = () => {
    Navigator.push('FilterDetailPage', {
      shopId: this.props.shopId,
      isSelectGroup: true,
      reduxKey,
    })
  }
  promoStatusTapped = () => {
    Navigator.push('FilterDetailPage', {
      shopId: this.props.shopId,
      isPromotedStatus: true,
      reduxKey,
    })
  }
  etalaseMenuTApped = () => {
    Navigator.push('FilterDetailPage', {
      shopId: this.props.shopId,
      isEtalase: true,
      reduxKey,
    })
  }
  selectButtonTapped = () => {
    if (this.props.isFromAddPromo) {
      this.props.changeAddPromoProductListFilter()
    } else {
      const labelTitle = this.props.promoType === 0 ? 'Group Filter' : 'Product Filter'
      TKPReactAnalytics.trackEvent({
        name: 'topadsios',
        category: 'ta - product',
        action: 'Click',
        label: `${labelTitle} - ${statuses[this.props.tempFilter.status]}`,
      })
      this.props.changePromoListFilter({
        key: reduxKey,
      })
    }

    Navigator.pop()
  }
  generateSelectedGroupName = () => {
    let name = ''
    if (
      this.props.tempFilter.group.group_name ===
      this.props.filter.group.group_name
    ) {
      name = this.props.filter.group.group_name
    } else {
      name = this.props.tempFilter.group.group_name
    }
    return name !== '' ? name : 'Semua Grup'
  }
  generateSelectedEtalaseName = () => {
    let name = ''
    if (
      this.props.tempProductFilter.etalase.menu_name ===
      this.props.productFilter.etalase.menu_name
    ) {
      name = this.props.productFilter.etalase.menu_name
    } else {
      name = this.props.tempProductFilter.etalase.menu_name
    }
    return name !== '' ? name : 'Semua Etalase'
  }

  renderPromoListFilter = () => (
    <View>
      {this.renderCell(
        'Status',
        statuses[this.props.tempFilter.status],
        this.statusMenuTapped,
      )}
      {this.renderCell(
        'Grup',
        this.generateSelectedGroupName(),
        this.groupMenuTapped,
      )}
    </View>
  )
  renderAddPromoFilter = () => (
    <View>
      {this.renderCell(
        'Status Promo',
        promotedStatuses[this.props.tempProductFilter.promotedStatus],
        this.promoStatusTapped,
      )}
      {this.renderCell(
        'Etalase',
        this.generateSelectedEtalaseName(),
        this.etalaseMenuTApped,
      )}
    </View>
  )
  renderCell = (title, value, onPress) => (
    <View style={styles.mainCellContainer}>
      <TouchableOpacity onPress={onPress}>
        <View style={styles.mainCell}>
          <View
            style={{
              height: 64,
              width: this.props.isFromAddPromo ? 120 : 70,
              justifyContent: 'center',
              marginRight: 5,
            }}
          >
            <Text style={{ fontSize: 16, color: color.blackText }}>
              {title}
            </Text>
          </View>
          <View style={styles.valueSubContainer}>
            <Image style={styles.arrowImageViewRight} source={arrowRightImg} />
            <Text style={styles.greenValueLabel}>{value}</Text>
          </View>
        </View>
      </TouchableOpacity>
      <View style={styles.separator} />
    </View>
  )
  render = () => {
    let tempSelectedName = ''
    if (this.props.isFromAddPromo) {
      tempSelectedName =
        this.generateSelectedEtalaseName() === 'Semua Etalase'
          ? ''
          : this.generateSelectedEtalaseName()
    } else {
      tempSelectedName =
        this.generateSelectedGroupName() === 'Semua Grup'
          ? ''
          : this.generateSelectedGroupName()
    }

    let isNoNewFilterFilter = false
    if (this.props.isFromAddPromo) {
      isNoNewFilterFilter =
        this.props.productFilter.promotedStatus ===
          this.props.tempProductFilter.promotedStatus &&
        tempSelectedName === this.props.productFilter.etalase.menu_name
    } else {
      isNoNewFilterFilter =
        this.props.filter.status === this.props.tempFilter.status &&
        tempSelectedName === this.props.filter.group.group_name
    }

    return (
      <Navigator.Config
        title="Filter"
        rightTitle="Reset"
        onRightPress={this.resetFilter}
        hidesBackButton={false}
      >
        <View style={styles.container}>
          {this.props.isFromAddPromo ? (
            this.renderAddPromoFilter()
          ) : (
            this.renderPromoListFilter()
          )}
          <View style={styles.selectButton}>
            <BigGreenButton2
              title={'Simpan'}
              buttonAction={this.selectButtonTapped}
              disabled={isNoNewFilterFilter}
            />
          </View>
        </View>
      </Navigator.Config>
    )
  }
}

export default connect(mapStateToProps, mapDispatchToProps)(FilterPage)
