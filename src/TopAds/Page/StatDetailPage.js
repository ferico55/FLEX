"use strict";

import Navigator from "native-navigation";
import DeviceInfo from "react-native-device-info";
import moment from "moment";
import DateSettingsButton from "../Components/DateSettingsButton";
import StatisticChart from "../Components/StatisticChart";
import { color } from "../Helper/Color";
import React, { Component } from "react";
import {
  StyleSheet,
  Text,
  TextInput,
  View,
  TouchableOpacity,
  ActivityIndicator,
  Image,
  ScrollView,
  Dimensions
} from "react-native";

import { bindActionCreators } from "redux";
import { connect } from "react-redux";
import * as Actions from "../Redux/Actions";

const { width } = Dimensions.get("window");

function mapStateToProps(state, ownProps) {
  return {
    ...state.statDetailReducer
  };
}

function mapDispatchToProps(dispatch) {
  return bindActionCreators(Actions, dispatch);
}

class StatDetailPage extends Component {
  constructor(props) {
    super(props);
    this.state = {
      isCenterTab: false,
      defaultTabOffset: 0
    };
    this.onAppear = this.onAppear.bind(this);
    this.dateButtonTapped = this.dateButtonTapped.bind(this);
  }
  componentDidMount() {
    if (this.props.selectedTabIndex >= 3) {
      this.setState({
        defaultTabOffset: 720 - width
      });
    } else {
      if (width >= 640) {
        this.setState({
          isCenterTab: true,
          defaultTabOffset: 0
        });
      }
    }
  }
  refreshData() {
    this.props.getStatDetailStatistic({
      shopId: this.props.authInfo.shop_id,
      type: this.props.promoType,
      startDate: this.props.startDate.format("YYYY-MM-DD"),
      endDate: this.props.endDate.format("YYYY-MM-DD")
    });
  }
  onAppear() {
    if (this.props.isNeedRefresh) {
      this.refreshData();
    }
  }
  renderTabBar() {
    const tabMenus = [
      "Tampil",
      "Klik",
      "Persentase Klik",
      "Konversi",
      "Rata-Rata",
      "Terpakai"
    ];
    return (
      <View style={styles.aboveTabBarContainer}>
        <ScrollView
          horizontal
          centerContent={this.state.isCenterTab}
          showsHorizontalScrollIndicator={false}
          contentOffset={{ x: this.state.defaultTabOffset, y: 0 }}
        >
          {tabMenus.map((item, index) =>
            <TouchableOpacity
              style={styles.aboveTabView}
              onPress={() => this.props.changeStatDetailTab(index)}
              key={index}
            >
              <View style={styles.defaultView}>
                <View style={styles.aboveTabTextContainer}>
                  <Text style={styles.aboveTabTitleLabel}>
                    {item}
                  </Text>
                </View>
                <View
                  style={
                    this.props.selectedTabIndex == index
                      ? styles.aboveTabBottomStripOn
                      : {}
                  }
                />
              </View>
            </TouchableOpacity>
          )}
        </ScrollView>
      </View>
    );
  }
  render() {
    const isScrollable =
      DeviceInfo.getModel() == "iPhone 5" ||
      DeviceInfo.getModel() == "iPhone 5s" ||
      DeviceInfo.getModel() == "iPhone 4" ||
      DeviceInfo.getModel() == "iPhone 5s";
    return (
      <Navigator.Config title={"Statistik"} onAppear={this.onAppear}>
        <View style={styles.container}>
          {this.renderTabBar()}
          <DateSettingsButton
            currentDateRange={{
              startDate: this.props.startDate,
              endDate: this.props.endDate
            }}
            buttonTapped={this.dateButtonTapped}
          />
          <ScrollView scrollEnabled={isScrollable}>
            <StatisticChart
              dataSource={this.props.dataSource}
              selectedTabIndex={this.props.selectedTabIndex}
              isLoading={this.props.isLoading}
            />
          </ScrollView>
        </View>
      </Navigator.Config>
    );
  }

  dateButtonTapped() {
    Navigator.push("DateSettingsPage", {
      changeDateActionId: "CHANGE_DATE_RANGE_STATDETAIL"
    });
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
  separator: {
    height: 1,
    backgroundColor: color.lineGrey
  },
  aboveTabBarContainer: {
    height: 45,
    flexDirection: "row",
    backgroundColor: "white"
  },
  aboveTabTitleLabel: {
    color: color.mainGreen,
    fontSize: 14,
    fontWeight: "500"
  },
  aboveTabView: {
    backgroundColor: "white",
    height: 45,
    width: 120
  },
  aboveTabTextContainer: {
    flex: 9,
    alignItems: "center",
    justifyContent: "center"
  },
  aboveTabBottomStripOn: {
    height: 3,
    backgroundColor: color.mainGreen
  }
});

export default connect(mapStateToProps, mapDispatchToProps)(StatDetailPage);
