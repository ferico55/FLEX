import React, { Component } from 'react'
import {
  View,
  Text,
  StyleSheet,
  FlatList,
  TouchableOpacity,
  ActivityIndicator,
} from 'react-native'
import DeviceInfo from 'react-native-device-info'
import Navigator from 'native-navigation'

import { getHistory, getStaticMapUrl, getHistoryFromUri } from '../Services/api'
import PreAnimatedImage from '../../PreAnimatedImage'
import NoResult from '../../unify/NoResult'
import { rupiahFormat, currencyFormat, trackEvent } from '../Lib/RideHelper'

const styles = StyleSheet.create({
  historyList: {
    flex: 1,
    paddingHorizontal: 16,
    backgroundColor: '#FAFAFA',
  },
  listContainer: {
    flex: 1,
    marginTop: 8,
    marginBottom: 8,
  },
  descriptionContainer: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    paddingHorizontal: 8,
    paddingVertical: 14,
    backgroundColor: 'white',
  },
  alignRight: {
    textAlign: 'right',
  },
  subtitleContainerleft: {
    flex: 6,
  },
  subtitleContainerRight: {
    flex: 4,
  },
  subtitle: {
    fontSize: 13,
    fontWeight: '200',
    marginTop: 6,
    color: 'rgba(0,0,0,0.7)',
  },
})

class RideHistoryScreen extends Component {
  constructor(props) {
    super(props)
    this.state = {
      dataSource: [],
      loadProgress: 'idle',
      screenName: 'Ride Your Trips Screen',
    }
  }

  componentDidMount() {
    this.loadData()
  }

  componentWillUnmount() {
    trackEvent('GenericUberEvent', 'click back', this.state.screenName)
  }

  handleRefresh = async () => {
    await this.setState({
      loadProgress: 'loading',
      dataSource: [],
      nextUri: null,
    })

    this.loadData()
  }

  loadData = () => {
    this.setState({
      loadProgress: 'loading',
    })

    const historyHandler = result => {
      const data = result.data
      if (data.history) {
        this.setState({
          dataSource: this.state.dataSource.concat(data.history),
          loadProgress: 'loaded',
          nextUri: data.paging.uri_next,
        })
      } else {
        this.setState({
          loadProgress: 'loaded',
          nextUri: null,
        })
      }
    }

    const errorHandler = error =>
      this.setState({
        loadProgress: 'error',
        error,
      })

    if (this.state.nextUri) {
      getHistoryFromUri(this.state.nextUri)
        .then(historyHandler)
        .catch(errorHandler)
    } else {
      getHistory()
        .then(historyHandler)
        .catch(errorHandler)
    }
  }

  loadingIndicator = () => (
    <ActivityIndicator
      animating={this.state.loadProgress === 'loading'}
      style={[styles.centering, { height: 44 }]}
      size="small"
    />
  )

  renderStatus = status => {
    let newStatus
    let color = '#7F7F7F'
    switch (status) {
      case 'NO_DRIVERS_AVAILABLE':
        newStatus = 'DRIVER NOT AVAILABLE'
        break
      case 'RIDER_CANCELED':
        newStatus = 'YOU CANCELED'
        break
      case 'DRIVER_CANCELED':
        newStatus = 'DRIVER CANCELED'
        break
      default:
        color = '#3AB539'
        newStatus = status
    }

    return (
      <Text
        style={[
          styles.alignRight,
          styles.subtitle,
          { color, fontWeight: '500' },
        ]}
      >
        {newStatus}
      </Text>
    )
  }

  renderItem = item => (
    <TouchableOpacity
      style={{ flex: 1 }}
      onPress={() => {
        Navigator.push('RideHistoryDetailScreen', { trip: item.item })
        trackEvent(
          'GenericUberEvent',
          'click receipt',
          `${this.state.screenName} - ${item.item.create_time} - ${currencyFormat(
            item.item.payment.currency_code,
          )} ${rupiahFormat(item.item.payment.total_amount)} - ${item.item
            .status}`,
        )
      }}
    >
      <View
        style={styles.listContainer}
        shadowColor="black"
        shadowRadius={2}
        shadowOpacity={0.15}
        shadowOffset={{ height: 2 }}
      >
        <PreAnimatedImage
          aspectRatio={2}
          source={getStaticMapUrl(item.item.pickup, item.item.destination)}
        />
        <View style={styles.descriptionContainer}>
          <View style={styles.subtitleContainerleft}>
            <Text>{item.item.create_time}</Text>
            <Text style={styles.subtitle}>
              {item.item.vehicle.make} {item.item.vehicle.model}{' '}
              {item.item.vehicle.license_plate}
            </Text>
          </View>
          <View style={styles.subtitleContainerRight}>
            <Text style={styles.alignRight}>
              {`${currencyFormat(
                item.item.payment.currency_code,
              )} ${rupiahFormat(item.item.payment.total_amount)}`}
            </Text>
            {this.renderStatus(item.item.status.toUpperCase())}
          </View>
        </View>
      </View>
    </TouchableOpacity>
  )

  renderContent = () => {
    const { loadProgress, nextUri, dataSource } = this.state

    if (loadProgress === 'error') {
      return (
        <NoResult
          buttonTitle="Try again"
          title="Oops!"
          subtitle={this.state.error.description}
          style={{ marginTop: 100 }}
          onButtonPress={() => this.loadData()}
        />
      )
    }

    if (loadProgress === 'loaded' && !dataSource.length) {
      return (
        <NoResult
          title="No trips"
          subtitle="You have no trip"
          style={{ marginTop: 100 }}
          showButton={false}
        />
      )
    }

    return (
      <FlatList
        onEndReached={() => {
          if (!(loadProgress === 'loading') && nextUri) {
            this.loadData()
          }
        }}
        style={styles.historyList}
        data={dataSource}
        renderItem={this.renderItem}
        refreshing={false}
        onRefresh={this.handleRefresh}
        numColumns={DeviceInfo.isTablet() ? 2 : 1}
        ListFooterComponent={this.loadingIndicator}
        keyExtractor={item => item.request_id}
      />
    )
  }

  render() {
    return (
      <View style={{ flex: 1 }}>
        <Navigator.Config title="Your Trips" />
        {this.renderContent()}
      </View>
    )
  }
}

export default RideHistoryScreen
