"use strict";

import Navigator from "native-navigation";
import { color } from "../Helper/Color";
import SelectableCell from "../Components/SelectableCell";
import BigGreenButton from "../Components/BigGreenButton";
import { ReactTPRoutes } from "NativeModules";
import React, { Component } from "react";
import {
  StyleSheet,
  Text,
  TextInput,
  View,
  TouchableHighlight,
  ActivityIndicator,
  Image,
  RefreshControl,
  FlatList
} from "react-native";

import { bindActionCreators } from "redux";
import { connect } from "react-redux";
import * as Actions from "../Redux/Actions";

function mapStateToProps(state) {
  return {
    ...state.addPromoCreditReducer
  };
}

function mapDispatchToProps(dispatch) {
  return bindActionCreators(Actions, dispatch);
}

class AddPromoCredit extends Component {
  constructor(props) {
    super(props);
    this.state = {
      refreshing: false
    };
    this.cellSelected = this.cellSelected.bind(this);
    this.getPrices = this.getPrices.bind(this);
    this.selectButtonTapped = this.selectButtonTapped.bind(this);
  }
  componentWillUnmount = () => {
    this.props.changePromoListSelectedIndex(-1);
  }
  componentDidMount = () => {
    this.getPrices();
  }
  getPrices = () => {
    this.props.getPromoCreditList();
  }
  renderItem = item => (
    <View>
      <SelectableCell
        currentIndex={item.index}
        cellSelected={this.cellSelected}
        title={item.item.product_price}
        isSelected={this.props.selectedIndex == item.index ? true : false}
      />
      <View style={styles.separator} />
    </View>
  );
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
        <BigGreenButton
          title={"Pilih"}
          buttonAction={this.selectButtonTapped}
          disabled={this.props.selectedIndex < 0 ? true : false}
        />
      </View>
    </Navigator.Config>
  );
  selectButtonTapped = () => {
    this.props.changeIsNeedRefreshDashboard(true);
    const url = this.props.dataSource[this.props.selectedIndex].product_url;
    const encodedURL = encodeURIComponent(url);
    ReactTPRoutes.navigate(`tokopedia://topads/addcredit?url=${encodedURL}`);
  }
  cellSelected = index => {
    this.props.changePromoListSelectedIndex(index);
  }
}

var styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: "white"
  },
  defaultView: {
    flex: 1
  },
  separator: {
    height: 1,
    flex: 1,
    backgroundColor: color.lineGrey
  },
  tableView: {}
});

export default connect(mapStateToProps, mapDispatchToProps)(AddPromoCredit);
