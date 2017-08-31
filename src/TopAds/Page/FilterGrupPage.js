"use strict";

import Navigator from "native-navigation";
import { color } from "../Helper/Color";
import SelectableCell from "../Components/SelectableCell";
import SearchBar from "../Components/SearchBar";
import React, { Component } from "react";
import {
  StyleSheet,
  Text,
  View,
  TouchableHighlight,
  ActivityIndicator,
  Image,
  FlatList,
  RefreshControl
} from "react-native";

import { requestGroupList } from "../Helper/Requests";

import { bindActionCreators } from "redux";
import { connect } from "react-redux";
import * as Actions from "../Redux/Actions";

let reduxKey = "";

function mapStateToProps(state, ownProps) {
  reduxKey = ownProps.reduxKey;
  return {
    ...state.promoListPageReducer[reduxKey]
  };
}

function mapDispatchToProps(dispatch) {
  return bindActionCreators(Actions, dispatch);
}

class FilterGrupPage extends Component {
  constructor(props) {
    super(props);
    this.state = {
      isStatusMenuOpened: false,
      refreshing: false,
      groups: [],
      selectedGroupId: this.props.filter.tempGroup.group_id,
      searchCancelButtonShown: false
    };

    this.resetFilter = this.resetFilter.bind(this);
    this.cellSelected = this.cellSelected.bind(this);
    this.closeKeyboard = this.closeKeyboard.bind(this);
    this.settingKeyboardCancelButton = this.settingKeyboardCancelButton.bind(
      this
    );
    this.onCancelButtonPress = this.onCancelButtonPress.bind(this);
  }
  componentDidMount() {
    this.getData("");
  }

  getData(theKeyword) {
    this.closeKeyboard();
    this.setState({
      refreshing: true
    });

    requestGroupList(this.props.shopId, theKeyword)
      .then(result => {
        this.setState({
          groups: result.data,
          refreshing: false
        });
      })
      .catch(error => {
        this.setState({
          refreshing: false
        });
      });
  }
  renderItem(item, selectedGroupId) {
    return (
      <View key={item.item.group_id}>
        <SelectableCell
          currentIndex={item.index}
          cellSelected={index => this.cellSelected(index)}
          title={item.item.group_name}
          isSelected={item.item.group_id == selectedGroupId}
        />
        <View style={styles.separator} />
      </View>
    );
  }
  render() {
    return (
      <Navigator.Config
        title="Filter"
        rightTitle="Reset"
        onRightPress={this.resetFilter}
      >
        <View style={styles.container}>
          <SearchBar
            ref="searchBar"
            placeholder="Cari Grup"
            onFocus={this.settingKeyboardCancelButton}
            onSearchButtonPress={keyword => this.getData(keyword)}
            barTintColor={color.backgroundGrey}
            showsCancelButton={this.state.searchCancelButtonShown}
            onCancelButtonPress={this.onCancelButtonPress}
          />
          <FlatList
            style={styles.tableView}
            keyExtractor={group => group.group_id}
            data={this.state.groups}
            renderItem={item =>
              this.renderItem(item, this.state.selectedGroupId)}
            refreshControl={
              <RefreshControl
                refreshing={this.state.refreshing}
                onRefresh={this.refreshData}
              />
            }
          />
        </View>
      </Navigator.Config>
    );
  }

  resetFilter() {
    this.props.changeTempGroupFilter({
      tempGroup: {
        group_id: "",
        group_name: ""
      },
      key: reduxKey
    });

    this.setState({
      selectedGroupId: ""
    });

    Navigator.pop();
  }
  cellSelected(index) {
    this.setState({
      selectedGroupId: this.state.groups[index].group_id
    });
    this.props.changeTempGroupFilter({
      tempGroup: this.state.groups[index],
      key: reduxKey
    });

    Navigator.pop();
  }
  settingKeyboardCancelButton() {
    if (!this.state.searchCancelButtonShown) {
      this.setState({
        searchCancelButtonShown: true
      });
    }
  }
  onCancelButtonPress() {
    this.getData("");
  }
  closeKeyboard() {
    this.refs.searchBar.unFocus();
  }
}

var styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: color.backgroundGrey
  },
  defaultView: {
    flex: 1
  },
  tableView: {},
  separator: {
    height: 1,
    backgroundColor: color.lineGrey
  }
});

export default connect(mapStateToProps, mapDispatchToProps)(FilterGrupPage);
