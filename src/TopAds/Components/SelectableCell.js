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

class SelectableCell extends Component {
  constructor(props) {
    super(props);
  }
  render() {
    return (
      <TouchableOpacity
        onPress={() => this.props.cellSelected(this.props.currentIndex)}
      >
        <View style={styles.cellContainer}>
          <Text style={styles.cellTitleLabel}>
            {this.props.title}
          </Text>
          <View style={styles.cellChecklistContainer}>
            <View
              style={{
                height: 64,
                justifyContent: "center",
                marginRight: 5
              }}
            >
              {this.props.isSelected
                ? <Image
                    style={styles.cellChecklistImageView}
                    source={require("../Icon/check.png")}
                  />
                : <View style={styles.cellChecklistView} />}
            </View>
          </View>
        </View>
      </TouchableOpacity>
    );
  }
}

var styles = StyleSheet.create({
  cellContainer: {
    backgroundColor: "white",
    flexDirection: "row",
    alignItems: "center",
    paddingHorizontal: 20
  },
  cellTitleLabel: {
    flex: 1,
    color: color.blackText
  },
  cellChecklistContainer: {
    width: 16,
    alignItems: "center",
    justifyContent: "center"
  },
  cellChecklistView: {
    height: 16,
    width: 16,
    borderWidth: 1,
    borderRadius: 8,
    borderColor: color.darkerGrey,
    overflow: "hidden"
  },
  cellChecklistImageView: {
    height: 16,
    width: 16
  }
});

module.exports = SelectableCell;
