import React, { Component } from 'react'
import Navigator from 'native-navigation'
import {
  View,
  ScrollView,
  StyleSheet,
  RefreshControl,
  FlatList,
  ActivityIndicator,
} from 'react-native'
import { ReactInteractionHelper, TKPReactAnalytics } from 'NativeModules'

import HeaderView from '../Components/HistoryLastStatus'
import OrderStatusTitleView from '../Components/HeaderSectionView'
import HistoryCell from '../Components/HistoryCell'

import { getOrderHistory } from '../Helper/OrderRequest'

const styles = StyleSheet.create({
  container: {
    backgroundColor: 'rgba(241, 241, 241, 1.0)',
  },
  listContainer: {
    backgroundColor: 'white',
    paddingTop: 15,
  },
})

export default class HistoryPage extends Component {
  constructor(props) {
    super(props)
    this.state = {
      isLoading: true,
    }
  }

  componentDidMount = () => {
    this.getData()
  }

  didAppear = () => {
    TKPReactAnalytics.trackScreenName('Shipment Status Detail Page')
  }

  getData = () => {
    getOrderHistory({
      userID: this.props.user_id,
      orderID: this.props.order_id,
      type: this.props.type,
    })
      .then(response => {
        this.setState({
          isLoading: false,
          lastHistoryTitle: response.data.history_title,
          lastHistoryStatus: response.data.order_status,
          lastHistoryColor: response.data.order_status_color,
          histories: response.data.histories,
        })
      })
      .catch(error => {
        ReactInteractionHelper.showErrorStickyAlert(error.description)
        this.setState({
          isLoading: false,
        })
      })
  }

  render() {
    return (
      <Navigator.Config title="Detail Status" onAppear={this.didAppear}>
        {this.state.isLoading ? (
          <View style={{ alignSelf: 'center', marginTop: 20 }}>
            <ActivityIndicator />
          </View>
        ) : (
          <ScrollView
            style={styles.container}
            refreshControl={
              <RefreshControl
                refreshing={this.state.isLoading}
                onRefresh={() => this.getData()}
              />
            }
          >
            <HeaderView
              lastStatus={this.state.lastHistoryStatus}
              title={this.state.lastHistoryTitle}
              color={this.state.lastHistoryColor}
            />

            <OrderStatusTitleView title={'Status Pemesanan'} />

            <View style={styles.listContainer}>
              {this.state.histories.map((item, index) => (
                <HistoryCell
                  key={index}
                  title={`${item.action_by} - ${item.date}`}
                  time={item.hour}
                  description={`${item.status} ${item.comment}`}
                  color={item.order_status_color}
                  islastCell={
                    this.state.histories[this.state.histories.length - 1] ===
                    item
                  }
                />
              ))}
            </View>
          </ScrollView>
        )}
      </Navigator.Config>
    )
  }
}
