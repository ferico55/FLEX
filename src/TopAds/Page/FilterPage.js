import Navigator from 'native-navigation'
import React, { Component } from 'react'
import { StyleSheet, Text, View, TouchableOpacity, Image } from 'react-native'
import { bindActionCreators } from 'redux'
import { connect } from 'react-redux'

import BigGreenButton from '../Components/BigGreenButton'
import color from '../Helper/Color'
import * as Actions from '../Redux/Actions/FilterActions'

import arrowRightImg from '../Icon/arrow_right.png'

let reduxKey = ''
const statuses = [
  { id: 0, value: 'Semua Status', isSelected: false },
  { id: 1, value: 'Aktif', isSelected: false },
  { id: 2, value: 'Tidak Terkirim', isSelected: false },
  { id: 3, value: 'Tidak Aktif', isSelected: false },
]

function mapStateToProps(state, ownProps) {
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
    left: 10,
    right: 10,
    bottom: 10,
  },
})

class FilterPage extends Component {
  componentDidMount = () => {
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
  resetFilter = () => {
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
  statusMenuTapped = () => {
    Navigator.push('FilterDetailPage', {
      shopId: this.props.shopId,
      isStatus: true,
      isFromAddPromo: false,
      reduxKey,
    })
  }
  groupMenuTapped = () => {
    Navigator.push('FilterDetailPage', {
      shopId: this.props.shopId,
      isStatus: false,
      isFromAddPromo: false,
      reduxKey,
    })
  }
  selectButtonTapped = () => {
    this.props.changePromoListFilter({
      key: reduxKey,
    })
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

  renderCell = (title, value, onPress) => (
    <View style={styles.mainCellContainer}>
      <TouchableOpacity onPress={onPress}>
        <View style={styles.mainCell}>
          <View
            style={{
              height: 64,
              width: 50,
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
    const tempSelectedGroupName =
      this.generateSelectedGroupName() === 'Semua Grup'
        ? ''
        : this.generateSelectedGroupName()
    const isNoNewFilterFilter =
      this.props.filter.status === this.props.tempFilter.status &&
      tempSelectedGroupName === this.props.filter.group.group_name

    return (
      <Navigator.Config
        title="Filter"
        rightTitle="Reset"
        onRightPress={this.resetFilter}
        hidesBackButton={false}
      >
        <View style={styles.container}>
          {this.renderCell(
            'Status',
            statuses[this.props.tempFilter.status].value,
            this.statusMenuTapped,
          )}
          {this.renderCell(
            'Grup',
            this.generateSelectedGroupName(),
            this.groupMenuTapped,
          )}
          <View style={styles.selectButton}>
            <BigGreenButton
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
