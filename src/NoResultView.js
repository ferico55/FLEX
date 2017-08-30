import React, { Component } from "react";
import {
  StyleSheet,
  Image,
  View,
  Button,
  TouchableOpacity,
  Text,
} from "react-native";

class NoResultView extends React.Component {
  render() {
    return (
      <View style={{ alignItems: "center" }}>
        <Image source={{ uri: "icon_no_data_grey" }} style={styles.mascot} />
        <Text style={{ fontSize: 17, marginTop: 12 }}>Whoops!</Text>
        <Text style={{ fontSize: 17, marginTop: 6 }}>
          Terjadi kendala pada server
        </Text>
        <Text
          style={{ fontSize: 14, marginTop: 12, color: "rgba(0,0,0,0.54)" }}
        >
          Harap coba lagi
        </Text>
        <TouchableOpacity onPress={this.props.onRefresh}>
          <View style={styles.buttonHolder}>
            <Text style={{ color: "white", fontSize: 16 }}>Coba Lagi</Text>
          </View>
        </TouchableOpacity>
      </View>
    );
  }
}

const styles = StyleSheet.create({
  mascot: {
    width: 80,
    height: 80,
    marginTop: 50,
  },
  buttonHolder: {
    borderRadius: 3,
    backgroundColor: "#42b549",
    marginTop: 12,
    paddingVertical: 12,
    paddingHorizontal: 64,
  },
});

module.exports = NoResultView;
