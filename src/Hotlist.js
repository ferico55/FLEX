
import React, { Component } from 'react';
import {
  StyleSheet,
  ScrollView,
  Text,
  TouchableOpacity,
  View,
  FlatList,
  Image,
  ActivityIndicator,
  NativeEventEmitter
} from 'react-native';
import DeviceInfo from 'react-native-device-info';

import axios from 'axios';
import { 
  TKPReactURLManager, 
  ReactNetworkManager,
  TKPReactAnalytics,
  EventManager 
} from 'NativeModules';

const nativeTabEmitter = new NativeEventEmitter(EventManager);

class Hotlist extends React.PureComponent {

  constructor(props) {
    super(props);
    this.state = {
      dataSource: [],
      page: 1,
      isLoading: false
    };
  }

  componentWillUnmount() {
    this.subscription.remove();
  }

  componentDidMount() {
    this.loadData();

    this.subscription = nativeTabEmitter.addListener("HotlistScrollToTop", () => {
      this.flatList.scrollToIndex({index: 0});
    });
  }

  _loadingIndicator = () => {
    return <ActivityIndicator animating={this.state.isLoading} style={[styles.centering, { height: 44 }]} size="small" />
  }

  _onRefresh = () => {
    this.state = {
      dataSource: [],
      page: 1,
      isLoading: false
    };

    this.loadData();
  }

  _renderItem = (item, index) => {
    return <TouchableOpacity
      onPress={() => {
        TKPReactAnalytics.trackEvent({
          name: 'clickHotlist',
          category: 'Hotlist',
          action: 'Click',
          label: item.item.key
        })

        this.props.navigation.navigate('tproutes', { url: item.item.url });
      }}
      style={styles.photoContainer}>
      <Image source={{ uri: item.item.image_url_600 }} style={styles.photo} />
      <View style={styles.textWrapper}>
        <Text style={{ fontSize: 12, flexShrink: 1 }}>
          {item.item.title}
        </Text>
        <View style={{ flexDirection: 'row' }}>
          <Text style={styles.textStartFrom}>
            Mulai dari
            </Text>
          <Text style={styles.textPrice}>
            {item.item.price_start}
          </Text>
        </View>

      </View>

    </TouchableOpacity>
  }



  render() {
    return (
      <FlatList
        ref={(ref) => { this.flatList = ref }}
        style={styles.wrapper}
        onEndReached={(distanceFromEnd) => {
          if (!this.state.isLoading) {
            this.loadData(this.state.page);
          }
        }}
        ListFooterComponent={this._loadingIndicator}
        keyExtractor={(item, index) => item.url}
        data={this.state.dataSource}
        onRefresh={this._onRefresh}
        numColumns={DeviceInfo.isTablet() ? 2 : 1}
        refreshing={false}
        renderItem={this._renderItem} />
    );
  }

  loadData(page = 1) {
    this.setState({
      isLoading: true
    });

    ReactNetworkManager.request({
      method: 'GET',
      baseUrl: TKPReactURLManager.v4Url,
      path: '/v4/hotlist/get_hotlist.pl',
      params: { page: this.state.page, limit: 10, os_type: 2 }
    }).then((response) => {

      if (page > this.state.page) {
        return;
      }

      this.setState({
        dataSource: this.state.dataSource.concat(response.data.list),
        page: this.state.page + 1,
        isLoading: false
      });

    });
  }
}

const styles = StyleSheet.create({
  container: {
    flexDirection: 'column',
    backgroundColor: '#e1e1e1',
    padding: 5,
    flex: 1
  },
  text: {
    fontSize: 12
  },
  photoContainer: {
    flexDirection: 'column',
    backgroundColor: '#e1e1e1',
    padding: 5,
    flex: DeviceInfo.isTablet() ? 1: 0
  },
  photo: {
    resizeMode: 'cover',
    aspectRatio: 1.91
  },
  wrapper: {
    backgroundColor: '#e1e1e1',
    paddingTop: 5,
    paddingLeft: 5,
    paddingRight: 5
  },
  centering: {
    alignItems: 'center',
    justifyContent: 'center',
    padding: 8,
  },
  textWrapper: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    backgroundColor: 'white',
    padding: 5
  },
  textStartFrom: {
    color: '#c8c7cc',
    fontSize: 12,
    marginRight: 5
  },
  textPrice: {
    color: '#ff5722', fontSize: 12
  }
});

module.exports = Hotlist;
