"use strict";

import React, { Component } from "react";
import BigGreenButton from "../Components/BigGreenButton";
import { StyleSheet, Text, View, TouchableOpacity, Image } from "react-native";

class NoResultView extends Component {
  constructor(props) {
    super(props);
  }
  render() {
    return (
      <View style={styles.container}>
        <Image style={styles.image} source={require("../Icon/cactus.png")} />
        <Text style={styles.titleLabel}>
          {this.props.title}
        </Text>
        <Text style={styles.descLabel}>
          {this.props.desc}
        </Text>
        {this.props.buttonAction &&
          <BigGreenButton
            title={this.props.buttonTitle}
            buttonAction={this.props.buttonAction}
            disabled={false}
          />}
      </View>
    );
  }
}

var styles = StyleSheet.create({
  container: {
    flex: 1,
    justifyContent: "center",
    paddingHorizontal: 40
  },
  image: {
    width: 250,
    height: 150,
    marginBottom: 10,
    alignSelf: "center"
  },
  titleLabel: {
    color: "black",
    textAlign: "center",
    marginBottom: 5
  },
  descLabel: {
    color: "grey",
    textAlign: "center",
    fontSize: 11,
    marginBottom: 20
  }
});

export default NoResultView