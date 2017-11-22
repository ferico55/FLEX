import React, { Component } from "react";
import {
  StyleSheet,
  View,
  Text,
  TouchableOpacity,
  ProgressViewIOS,
  Alert,
} from "react-native";

import RatingStars from "../RatingStars";

class ProductReviewFilter extends React.Component {
  constructor(props) {
    super(props);
    this.state = { selectedStar: 0 };
  }

  setNativeProps = nativeProps => {
    this._root.setNativeProps(nativeProps);
  };

  _rowClick = star => {
    this.setState({
      selectedStar: star,
    });
    if (this.props.onFilterSelected) this.props.onFilterSelected(star);
  };

  _renderRow = () => {
    let rows = [];
    for (let i = 5; i > 0; i--) {
      rows.push(
        <View
          style={
            this.state.selectedStar == i ? (
              styles.selectedStarFilterContainer
            ) : (
              styles.starFilterContainer
            )
          }
          key={i + ""}
        >
          <TouchableOpacity
            onPress={() => {
              this._rowClick(i);
            }}
          >
            <View style={styles.starFilter}>
              <RatingStars
                onPress={() => {
                  this._rowClick(i);
                }}
                enabled={false}
                rating={i}
                iconSize={16}
                rtl={true}
              />
              <ProgressViewIOS
                progress={0.5}
                progressTintColor="#FD9727"
                style={{ flex: 1, marginHorizontal: 8 }}
              />
              <Text>(28)</Text>
            </View>
          </TouchableOpacity>
        </View>
      );
    }
    return rows;
  };

  render = () => {
    return (
      <View
        style={{
          width: "100%",
          paddingHorizontal: 14,
        }}
      >
        {this._renderRow()}
        <TouchableOpacity
          style={{ alignSelf: "flex-end" }}
          onPress={() => {
            this._rowClick(0);
          }}
        >
          <Text style={styles.resetText}>Reset Filter</Text>
        </TouchableOpacity>
      </View>
    );
  };
}

const styles = StyleSheet.create({
  starFilter: {
    flexDirection: "row",
    alignItems: "center",
  },
  starFilterContainer: {
    marginVertical: 4,
    flexDirection: "column",
    width: "100%",
    paddingHorizontal: 2,
  },
  selectedStarFilterContainer: {
    marginVertical: 3,
    flexDirection: "column",
    width: "100%",
    paddingHorizontal: 1,
    borderWidth: 1,
    borderColor: "#FD9727",
    borderRadius: 3,
  },
  resetText: {
    color: "red",
    marginRight: 8,
    marginTop: 10,
    fontSize: 14,
  },
});

module.exports = ProductReviewFilter;
