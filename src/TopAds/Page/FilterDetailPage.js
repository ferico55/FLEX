import Navigator from 'native-navigation'
import React, { Component } from 'react'
import { StyleSheet, View, FlatList, RefreshControl } from 'react-native'
import { bindActionCreators } from 'redux'
import { connect } from 'react-redux'
import { ReactInteractionHelper } from 'NativeModules'
import SearchBar from 'react-native-search-bar'

import color from '../Helper/Color'
import SelectableCell from '../Components/SelectableCell'
import NoResultView from '../Components/NoResultView'
import { requestGroupList, requestEtalaseList } from '../Helper/Requests'
import * as FilterActions from '../Redux/Actions/FilterActions'
import * as AddPromoActions from '../Redux/Actions/AddPromoActions'

let reduxKey = ''

function mapStateToProps(state, ownProps) {
  reduxKey = ownProps.reduxKey
  if (
    ownProps.isGroupAddPromo ||
    ownProps.isPromotedStatus ||
    ownProps.isEtalase
  ) {
    return {
      ...state.addPromoReducer,
    }
  }
  return {
    ...state.promoListPageReducer[reduxKey],
  }
}

function mapDispatchToProps(dispatch) {
  return bindActionCreators({ ...FilterActions, ...AddPromoActions }, dispatch)
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: 'white',
  },
  defaultView: {
    flex: 1,
  },
  tableView: {},
  separator: {
    height: 1,
    backgroundColor: color.lineGrey,
  },
})

class FilterDetailPage extends Component {
  constructor(props) {
    super(props)
    this.state = {
      isStatus: this.props.isStatus,
      isSelectGroup: this.props.isSelectGroup,
      isGroupAddPromo: this.props.isGroupAddPromo,
      isPromotedStatus: this.props.isPromotedStatus,
      isEtalase: this.props.isEtalase,
      refreshing: false,
      groups: [],
      isFailedRequest: false,
      isEmptyGroup: false,
      keyword: '',
      statuses: [
        { id: 1, value: 'Aktif' },
        { id: 2, value: 'Tidak Terkirim' },
        { id: 3, value: 'Tidak Aktif' },
      ],
      promotedStatuses: [
        { id: 0, value: 'Belum Dipromo' },
        { id: 2, value: 'Di Dalam Grup' },
        { id: 3, value: 'Di Luar Grup' },
      ],
      etalases: [],
      searchCancelButtonShown: false,
    }
  }
  componentWillMount = () => {
    this.setSelectedId()
  }
  componentDidMount = () => {
    this.refreshData()
  }
  onCancelButtonPress = () => {
    this.getGroups('')
  }
  setSelectedId = () => {
    if (this.state.isStatus) {
      this.setState({
        selectedId: this.props.tempFilter.status,
      })
    } else if (this.state.isSelectGroup) {
      this.setState({
        selectedId: this.props.tempFilter.group.group_id,
      })
    } else if (this.state.isGroupAddPromo) {
      this.setState({
        selectedId: this.props.existingGroup.group_id,
      })
    } else if (this.state.isPromotedStatus) {
      this.setState({
        selectedId: this.props.tempProductFilter.promotedStatus,
      })
    } else {
      this.setState({
        selectedId: this.props.tempProductFilter.etalase.menu_id,
      })
    }
  }
  getGroups = theKeyword => {
    this.closeKeyboard()
    this.setState({
      refreshing: true,
      isFailedRequest: false,
      isEmptyGroup: false,
      keyword: theKeyword,
    })

    requestGroupList(this.props.shopId, theKeyword)
      .then(result => {
        if (result.data) {
          this.setState({
            groups: result.data,
            refreshing: false,
            isEmptyGroup: result.data.length < 1,
          })
        }
      })
      .catch(error => {
        ReactInteractionHelper.showErrorStickyAlert(error.message)
        this.setState({
          refreshing: false,
          isFailedRequest: true,
        })
      })
  }
  getEtalase = () => {
    requestEtalaseList(this.props.shopId)
      .then(result => {
        if (result.data) {
          this.setState({
            etalases: result.data,
            refreshing: false,
            isEmptyGroup: result.data.length < 1,
          })
        }
      })
      .catch(error => {
        ReactInteractionHelper.showErrorStickyAlert(error.message)
        this.setState({
          refreshing: false,
          isFailedRequest: true,
        })
      })
  }
  settingKeyboardCancelButton = () => {
    if (!this.state.searchCancelButtonShown) {
      this.setState({
        searchCancelButtonShown: true,
      })
    }
  }
  refreshData = () => {
    if (this.state.isSelectGroup || this.state.isGroupAddPromo) {
      this.getGroups('')
    } else if (this.state.isEtalase) {
      this.getEtalase()
    }
  }
  resetFilter = () => {
    if (this.state.isStatus) {
      this.props.changeTempFilterStatus({
        tempStatus: 0,
        key: reduxKey,
      })
    } else if (this.state.isSelectGroup) {
      this.props.changeTempFilterGroup({
        tempGroup: {
          group_id: '',
          group_name: '',
        },
        key: reduxKey,
      })
    } else if (this.state.isGroupAddPromo) {
      this.props.setExistingGroupAddPromo({
        group_id: '',
        group_name: '',
        total_item: 0,
      })
    } else if (this.state.isPromotedStatus) {
      this.props.changeTempFilterPromotedStatus(1)
    } else {
      this.props.changeTempFilterEtalase({ menu_id: '', menu_name: '' })
    }

    Navigator.pop()
  }
  cellSelected = index => {
    if (this.state.isStatus) {
      this.setState({
        selectedId: this.state.statuses[index].id,
      })
      this.props.changeTempFilterStatus({
        tempStatus: this.state.statuses[index].id,
        key: reduxKey,
      })
    } else if (this.state.isSelectGroup) {
      this.setState({
        selectedId: this.state.groups[index].group_id,
      })
      this.props.changeTempFilterGroup({
        tempGroup: this.state.groups[index],
        key: reduxKey,
      })
    } else if (this.state.isGroupAddPromo) {
      this.props.setExistingGroupAddPromo(this.state.groups[index])
      this.props.getGroupAdDetailEdit(this.state.groups[index].group_id)
    } else if (this.state.isPromotedStatus) {
      this.props.changeTempFilterPromotedStatus(
        this.state.promotedStatuses[index].id,
      )
    } else {
      this.props.changeTempFilterEtalase(this.state.etalases[index])
    }

    Navigator.pop()
  }
  closeKeyboard() {
    this.refs.searchBar.unFocus()
  }
  renderItem(item) {
    const theItem = item.item
    let key = ''
    let name = ''
    let isSelected = false

    if (this.state.isStatus) {
      key = theItem.id
      name = theItem.value
      isSelected = theItem.id == this.state.selectedId
    } else if (this.state.isSelectGroup || this.state.isGroupAddPromo) {
      key = theItem.group_id
      name = theItem.group_name
      isSelected = theItem.group_id == this.state.selectedId
    } else if (this.state.isPromotedStatus) {
      key = theItem.id
      name = theItem.value
      isSelected = theItem.id == this.state.selectedId
    } else {
      key = theItem.menu_id
      name = theItem.menu_name
      isSelected = theItem.menu_id == this.state.selectedId
    }

    return (
      <View key={key}>
        <SelectableCell
          currentIndex={item.index}
          cellSelected={index => this.cellSelected(index)}
          title={name}
          isSelected={isSelected}
        />
        <View style={styles.separator} />
      </View>
    )
  }
  renderContent = () => {
    if (this.state.isFailedRequest) {
      return (
        <NoResultView
          title={'Gagal Mendapatkan Data'}
          desc={'Terjadi masalah pada saat pengambilan data'}
          buttonTitle={'Coba Lagi'}
          buttonAction={() => this.getGroups(this.state.keyword)}
        />
      )
    }
    if (this.state.isEmptyGroup) {
      return (
        <NoResultView
          title={'Hasil Tidak Ditemukan'}
          desc={'Silahkan coba lagi atau ganti kata kunci.'}
        />
      )
    }

    return this.renderFlatList()
  }
  renderFlatList = () => {
    let keyEx = _ => _
    let data = []
    const isShowRefreshControl =
      this.state.isSelectGroup || this.state.isGroupAddPromo || this.state.isEtalase

    if (this.state.isStatus) {
      keyEx = status => status.id
      data = this.state.statuses
    } else if (this.state.isSelectGroup || this.state.isGroupAddPromo) {
      keyEx = group => group.group_id
      data = this.state.groups
    } else if (this.state.isPromotedStatus) {
      keyEx = promotedStatus => promotedStatus.id
      data = this.state.promotedStatuses
    } else {
      keyEx = etalase => etalase.menu_id
      data = this.state.etalases
    }

    return (
      <FlatList
        style={styles.tableView}
        keyExtractor={keyEx}
        data={data}
        renderItem={item => this.renderItem(item)}
        refreshControl={
          isShowRefreshControl ? (
            <RefreshControl
              refreshing={this.state.refreshing}
              onRefresh={this.refreshData}
            />
          ) : null
        }
      />
    )
  }
  render() {
    return (
      <Navigator.Config
        title={this.state.isStatus ? 'Status' : 'Grup'}
        rightTitle="Reset"
        onRightPress={this.resetFilter}
      >
        <View style={styles.container}>
          <View style={{ backgroundColor: color.backgroundGrey }}>
            {(this.state.isSelectGroup || this.props.isGroupAddPromo) && (
              <SearchBar
                ref="searchBar"
                placeholder="Cari Grup"
                onFocus={this.settingKeyboardCancelButton}
                onSearchButtonPress={keyword => this.getGroups(keyword)}
                barTintColor={color.backgroundGrey}
                showsCancelButton={this.state.searchCancelButtonShown}
                onCancelButtonPress={this.onCancelButtonPress}
              />
            )}
          </View>
          {this.renderContent()}
        </View>
      </Navigator.Config>
    )
  }
}

export default connect(mapStateToProps, mapDispatchToProps)(FilterDetailPage)
