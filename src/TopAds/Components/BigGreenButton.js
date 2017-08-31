"use strict";

import React, { Component } from "react";
import { color } from "../Helper/Color";
import {
  StyleSheet,
  Text,
  View,
  TouchableOpacity,
  ActivityIndicator,
  Image
} from "react-native";

class BigGreenButton extends Component {
  constructor(props) {
    super(props);
  }
  render() {
    return (
      <TouchableOpacity
        style={[
          styles.promoTokoAddButton,
          {
            backgroundColor: this.props.disabled
              ? color.lineGrey
              : color.mainGreen
          }
        ]}
        onPress={() => this.props.buttonAction()}
        disabled={this.props.disabled}
      >
        <Text style={styles.promoTokoAddButtonLabel}>
          {this.props.title}
        </Text>
      </TouchableOpacity>
    );
  }
}

var styles = StyleSheet.create({
  promoTokoAddButton: {
    height: 40,
    alignItems: "center",
    justifyContent: "center",
    marginHorizontal: 17,
    marginBottom: 10,
    borderRadius: 3
  },
  promoTokoAddButtonLabel: {
    color: "white"
  }
});

export default BigGreenButton;