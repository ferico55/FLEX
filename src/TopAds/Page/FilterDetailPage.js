import Navigator from 'native-navigation'
import React, { Component } from 'react'
import { StyleSheet, View, FlatList, RefreshControl } from 'react-native'
import { bindActionCreators } from 'redux'
import { connect } from 'react-redux'

import color from '../Helper/Color'
import SelectableCell from '../Components/SelectableCell'
import SearchBar from '../Components/SearchBar'
import { requestGroupList } from '../Helper/Requests'
import * as Actions from '../Redux/Actions/FilterActions'

let reduxKey = ''

function mapStateToProps(state, ownProps) {
  reduxKey = ownProps.reduxKey
  if (ownProps.isFromAddPromo) {
    return {
      ...state.addPromoReducer,
    }
  }
  return {
    ...state.promoListPageReducer[reduxKey],
  }
}

function mapDispatchToProps(dispatch) {
  return bindActionCreators(Actions, dispatch)
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
      isFromAddPromo: this.props.isFromAddPromo,
      refreshing: false,
      groups: [],
      statuses: [
        { id: 1, value: 'Aktif', isSelected: false },
        { id: 2, value: 'Tidak Terkirim', isSelected: false },
        { id: 3, value: 'Tidak Aktif', isSelected: false },
      ],
      selectedGroupId: this.props.tempFilter.group.group_id,
      selectedStatusId: this.props.tempFilter.status,
      searchCancelButtonShown: false,
    }
  }
  componentDidMount = () => {
    if (!this.state.isStatus) {
      this.getData('')
    }
  }

  onCancelButtonPress() {
    this.getData('')
  }
  getData = theKeyword => {
    this.closeKeyboard()
    this.setState({
      refreshing: true,
    })

    requestGroupList(this.props.shopId, theKeyword)
      .then(result => {
        this.setState({
          groups: result.data,
          refreshing: false,
        })
      })
      .catch(error => {
        this.setState({
          refreshing: false,
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
  resetFilter = () => {
    if (this.state.isStatus) {
      this.props.changeTempFilterStatus({
        tempStatus: 0,
        key: reduxKey,
      })

      this.setState({
        selectedStatusId: 0,
      })
    } else {
      this.props.changeTempFilterGroup({
        tempGroup: {
          group_id: '',
          group_name: '',
        },
        key: reduxKey,
      })

      this.setState({
        selectedGroupId: '',
      })
    }

    Navigator.pop()
  }
  cellSelected = index => {
    if (this.state.isStatus) {
      this.setState({
        selectedStatusId: this.state.statuses[index].id,
      })
      this.props.changeTempFilterStatus({
        tempStatus: this.state.statuses[index].id,
        key: reduxKey,
      })
    } else {
      this.setState({
        selectedGroupId: this.state.groups[index].group_id,
      })
      this.props.changeTempFilterGroup({
        tempGroup: this.state.groups[index],
        key: reduxKey,
      })
    }

    Navigator.pop()
  }
  closeKeyboard() {
    this.refs.searchBar.unFocus()
  }
  renderItem(item, selectedId) {
    const key = this.state.isStatus ? item.item.id : item.item.group_id
    const name = this.state.isStatus ? item.item.value : item.item.group_name
    let isSelected = false
    if (this.state.isStatus) {
      isSelected = item.item.id === selectedId
    } else {
      isSelected = item.item.group_id === selectedId
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
  render() {
    return (
      <Navigator.Config
        title={this.state.isStatus ? 'Status' : 'Grup'}
        rightTitle="Reset"
        onRightPress={this.resetFilter}
      >
        <View style={styles.container}>
          <View style={{ backgroundColor: color.backgroundGrey }}>
            {!this.state.isStatus ? (
              <SearchBar
                ref="searchBar"
                placeholder="Cari Grup"
                onFocus={this.settingKeyboardCancelButton}
                onSearchButtonPress={keyword => this.getData(keyword)}
                barTintColor={color.backgroundGrey}
                showsCancelButton={this.state.searchCancelButtonShown}
                onCancelButtonPress={this.onCancelButtonPress}
              />
            ) : null}
          </View>
          <FlatList
            style={styles.tableView}
            keyExtractor={
              this.state.isStatus ? (
                status => status.id
              ) : (
                group => group.group_id
              )
            }
            data={this.state.isStatus ? this.state.statuses : this.state.groups}
            renderItem={item =>
              this.renderItem(
                item,
                this.state.isStatus
                  ? this.state.selectedStatusId
                  : this.state.selectedGroupId,
              )}
            refreshControl={
              !this.state.isStatus ? (
                <RefreshControl
                  refreshing={this.state.refreshing}
                  onRefresh={this.refreshData}
                />
              ) : null
            }
          />
        </View>
      </Navigator.Config>
    )
  }
}

export default connect(mapStateToProps, mapDispatchToProps)(FilterDetailPage)
