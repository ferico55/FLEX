
import React, { Component } from 'react';
import {
  StyleSheet,
  ScrollView,
  Text,
  TouchableOpacity,
  View,
  FlatList,
  Image,
  ActivityIndicator
} from 'react-native';
import DeviceInfo from 'react-native-device-info';



import axios from 'axios';
import { TKPHmacManager } from 'NativeModules';
import { TKPReactAnalytics } from 'NativeModules';
import { TKPReactURLManager } from 'NativeModules';

// var DeviceInfo = require('react-native-device-info');

class Hotlist extends React.PureComponent {
  

  constructor(props) {
    super(props);
    this.state = {
      dataSource: [],
      page: 1,
      isLoading: false
    };
  }

  componentDidMount() {
    this.loadData()
  }

  _loadingIndicator = () => {
    return <ActivityIndicator animating={this.state.isLoading} style={[styles.centering, {height: 44}]} size="small" />
  }

  _onRefresh = () => {
    this.state = {
      dataSource: [],
      page: 1,
      isLoading: false
    };

    this.loadData()
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

        this.props.navigation.navigate('tproutes', {url: item.item.url});
      }}
      style={styles.container}>
        <Image source={{ uri: item.item.image_url_600}} style={styles.photo} />
        <View style={styles.textWrapper}>
          <Text style={{ fontSize: 12, flexShrink: 1}}>
            {item.item.title}
          </Text>
          <View style={{ flexDirection: 'row'}}>
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
        style={styles.wrapper}
        onEndReached={ (distanceFromEnd) => {
          if(!this.state.isLoading) {
            this.loadData()
          }
        }}
        ListFooterComponent={this._loadingIndicator}
        keyExtractor={(item, index) => item.url}
        data={this.state.dataSource}
        onRefresh={this._onRefresh}
        numColumns={DeviceInfo.isTablet() ? 2 : 1}
        refreshing={false}
        renderItem={this._renderItem}/>
    );
  }

  loadData() {
    this.setState({
      isLoading: true
    });

    const params  = { page : this.state.page, limit : 10 , os_type : 2 }
    const dictionary = {params: params, base_url: TKPReactURLManager.v4Url, path: '/v4/hotlist/get_hotlist.pl', method: 'GET'}
    
    TKPHmacManager.getHmac(dictionary).then((result) => {
      axios({
        method:dictionary.method,
        url:dictionary.base_url + dictionary.path,
        params: params,
        headers : result
      })
      .then((response) => {

        this.setState({
          dataSource: this.state.dataSource.concat(response.data.data.list),
          page: this.state.page + 1,
          isLoading: false
        });
        
      });
    })
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
  photo: {
    flex: 1,
    resizeMode: 'cover',
    height: 160
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
