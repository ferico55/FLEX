"use strict";

import { color } from "../Helper/Color";
import React, { Component } from "react";
import {
  StyleSheet,
  Text,
  View,
  TouchableOpacity,
  ActivityIndicator,
  Image
} from "react-native";

class DateSettingsButton extends Component {
  constructor(props) {
    super(props);
  }
  render() {
    let dateRange = this.props.currentDateRange;
    return (
      <TouchableOpacity
        style={styles.infoDateContainer}
        onPress={() => this.props.buttonTapped()}
      >
        <View style={styles.infoDateSubContainer}>
          <View style={styles.infoDateCalendarImageContainer}>
            <Image
              style={styles.infoDateCalendarImageView}
              source={require("../Icon/calendar.png")}
            />
          </View>
          <View style={styles.infoDateRangeContainer}>
            <Image
              style={styles.infoDateRangeArrowImageView}
              source={require("../Icon/arrow_right.png")}
            />
            <Text style={styles.infoDateRangeLabel}>
              {this.dateString(dateRange)}
            </Text>
          </View>
        </View>
      </TouchableOpacity>
    );
  }
  dateString(dateRange) {
    if (!dateRange) {
      return "-";
    }

    if (
      dateRange.startDate.format("D MMMM YYYY") ==
      dateRange.endDate.format("D MMMM YYYY")
    ) {
      return dateRange.startDate.format("D MMMM YYYY");
    } else {
      return dateRange.startDate.format("YYYY") ==
      dateRange.endDate.format("YYYY")
        ? dateRange.startDate.format("D MMMM") +
          " - " +
          dateRange.endDate.format("D MMMM YYYY")
        : dateRange.startDate.format("D MMMM YYYY") +
          " - " +
          dateRange.endDate.format("D MMMM YYYY");
    }
  }
}

var styles = StyleSheet.create({
  infoDateContainer: {
    height: 64,
    backgroundColor: color.lineGrey,
    paddingVertical: 1
  },
  infoDateSubContainer: {
    flex: 1,
    flexDirection: "row",
    backgroundColor: "white"
  },
  infoDateCalendarImageContainer: {
    marginHorizontal: 17,
    width: 20,
    alignItems: "center",
    justifyContent: "center"
  },
  infoDateCalendarImageView: {
    height: 25,
    width: 25
  },
  infoDateRangeContainer: {
    flex: 6,
    alignItems: "center",
    flexDirection: "row-reverse"
  },
  infoDateRangeLabel: {
    color: color.mainGreen,
    fontWeight: "500"
  },
  infoDateRangeArrowImageView: {
    height: 12,
    width: 8,
    marginLeft: 6,
    marginRight: 17
  }
});

module.exports = DateSettingsButton;
