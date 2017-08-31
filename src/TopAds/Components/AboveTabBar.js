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

class AboveTabBar extends Component {
  constructor(props) {
    super(props);
  }
  render() {
    return (
      <View style={styles.aboveTabContainer}>
        <TouchableOpacity
          style={styles.aboveTabView}
          onPress={() => this.props.tabBarSelected(0)}
        >
          <View style={styles.defaultView}>
            <View style={styles.aboveTabTextContainer}>
              <Text style={styles.titleLabel}>
                {this.props.firstTabTitle}
              </Text>
            </View>
            <View
              style={
                this.props.selectedTabIndex == 0
                  ? styles.aboveTabBottomStripOn
                  : styles.aboveTabBottomStripOff
              }
            />
          </View>
        </TouchableOpacity>
        <TouchableOpacity
          style={styles.aboveTabView}
          onPress={() => this.props.tabBarSelected(1)}
        >
          <View style={styles.defaultView}>
            <View style={styles.aboveTabTextContainer}>
              <Text style={styles.titleLabel}>
                {this.props.secondTabTitle}
              </Text>
            </View>
            <View
              style={
                this.props.selectedTabIndex == 1
                  ? styles.aboveTabBottomStripOn
                  : styles.aboveTabBottomStripOff
              }
            />
          </View>
        </TouchableOpacity>
      </View>
    );
  }
}

const styles = StyleSheet.create({
  defaultView: {
    flex: 1
  },
  aboveTabContainer: {
    height: 45,
    backgroundColor: "white",
    flexDirection: "row",
    shadowColor: "grey",
    shadowOffset: {
      width: 0
    },
    shadowRadius: 3,
    shadowOpacity: 1
  },
  titleLabel: {
    color: color.mainGreen,
    fontSize: 14,
    fontWeight: "500"
  },
  aboveTabView: {
    flex: 1,
    backgroundColor: "white"
  },
  aboveTabTextContainer: {
    flex: 9,
    alignItems: "center",
    justifyContent: "center"
  },
  aboveTabBottomStripOn: {
    height: 3,
    backgroundColor: color.mainGreen
  },
  aboveTabBottomStripOff: {
    height: 1,
    backgroundColor: color.backgroundGrey
  }
});

export default AboveTabBar;