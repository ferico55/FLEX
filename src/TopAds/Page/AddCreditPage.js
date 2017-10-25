import Navigator from 'native-navigation'
import { ReactTPRoutes } from 'NativeModules'
import React, { Component } from 'react'
import { StyleSheet, View, RefreshControl, FlatList } from 'react-native'
import { bindActionCreators } from 'redux'
import { connect } from 'react-redux'

import color from '../Helper/Color'
import SelectableCell from '../Components/SelectableCell'
import BigGreenButton2 from '../Components/BigGreenButton2'

import * as AddCreditActions from '../Redux/Actions/AddCreditActions'
import * as DashboardActions from '../Redux/Actions/DashboardActions'

function mapStateToProps(state) {
  return {
    ...state.addCreditReducer,
  }
}

function mapDispatchToProps(dispatch) {
  return bindActionCreators(
    {
      ...DashboardActions,
      ...AddCreditActions,
    },
    dispatch,
  )
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: 'white',
  },
  defaultView: {
    flex: 1,
  },
  separator: {
    height: 1,
    flex: 1,
    backgroundColor: color.lineGrey,
  },
  tableView: {},
})

class AddCreditPage extends Component {
  constructor(props) {
    super(props)
    this.state = {
      refreshing: false,
    }
  }
  componentDidMount = () => {
    this.getPrices()
  }
  componentWillUnmount = () => {
    this.props.changeAddCreditSelectedIndex(-1)
  }
  getPrices = () => {
    this.props.getPromoCreditList()
  }
  selectButtonTapped = () => {
    this.props.changeIsNeedRefreshDashboard(true)
    const url = this.props.dataSource[this.props.selectedIndex].product_url
    const encodedURL = encodeURIComponent(url)
    ReactTPRoutes.navigate(`tokopedia://topads/addcredit?url=${encodedURL}`)
  }
  cellSelected = index => {
    this.props.changeAddCreditSelectedIndex(index)
  }

  renderItem = item => (
    <View>
      <SelectableCell
        currentIndex={item.index}
        cellSelected={this.cellSelected}
        title={item.item.product_price}
        isSelected={this.props.selectedIndex === item.index}
      />
      <View style={styles.separator} />
    </View>
  )
  render = () => (
    <Navigator.Config title="Tambah Kredit TopAds">
      <View style={styles.container}>
        <FlatList
          style={styles.tableView}
          keyExtractor={priceItem => priceItem.product_id}
          data={this.props.dataSource}
          renderItem={this.renderItem}
          refreshControl={
            <RefreshControl
              refreshing={this.props.isLoading}
              onRefresh={this.getPrices}
            />
          }
        />
        <BigGreenButton2
          title={'Pilih'}
          buttonAction={this.selectButtonTapped}
          disabled={this.props.selectedIndex < 0}
        />
      </View>
    </Navigator.Config>
  )
}

export default connect(mapStateToProps, mapDispatchToProps)(AddCreditPage)
