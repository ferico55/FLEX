import React, { Component } from "react";
import {
  StyleSheet,
  Text,
  TouchableOpacity,
  View,
  FlatList,
  Image,
  Alert,
  ProgressViewIOS,
  ActionSheetIOS,
} from "react-native";

import axios from "axios";
import {
  TKPReactURLManager,
  ReactNetworkManager,
  TKPReactAnalytics,
  HybridNavigationManager,
} from "NativeModules";
import Rx from "rxjs/Rx";
import RatingStars from "../RatingStars";
import ProductReviewFilter from "./ProductReviewFilter";

class ProductReview extends React.PureComponent {
  constructor(props) {
    super(props);
    this.state = {
      dataSource: [{ id: 1 }],
    };

    var tag = props.navigation.state.key;
    tag = tag.substring(tag.indexOf("-") + 1, tag.length);
    HybridNavigationManager.setTitle(parseInt(tag), "Ulasan");
  }

  _showOption = () => {
    ActionSheetIOS.showActionSheetWithOptions(
      {
        options: ["Lapor", "Batal"],
        cancelButtonIndex: 1,
      },
      index => {}
    );
  };

  _renderReview = () => {
    return (
      <View style={styles.reviewContainer}>
        <View style={styles.reviewHeaderContainer}>
          <View style={styles.reviewHeader}>
            <Image
              source={{ uri: "thumb_product" }}
              style={{ height: 32, width: 32 }}
            />
            <View style={{ marginLeft: 8 }}>
              <Text style={styles.name}>Bruno Alex</Text>
              <Text style={[styles.mutedText, { fontSize: 11 }]}>
                28 may.....
              </Text>
            </View>
          </View>
          <TouchableOpacity
            onPress={() => {
              this._showOption();
            }}
          >
            <Image
              source={{ uri: "icon_arrow_down_grey" }}
              style={styles.optionButton}
            />
          </TouchableOpacity>
        </View>
        <View style={{ padding: 8 }}>
          <RatingStars enabled={false} rating={5} iconSize={16} />
          <View style={{ marginTop: 8 }}>
            <Text style={styles.mutedText}>
              ini isi review.. asdfhoausdfh uoh
            </Text>
          </View>
        </View>
        <View style={styles.separator} />
        <View style={{ padding: 8, flexDirection: "row" }}>
          <Image
            source={{ uri: "icon_star_active" }}
            style={{ height: 16, width: 16 }}
          />
          <Text style={[styles.mutedText, { marginLeft: 2 }]}>
            <Text>2</Text> orang
          </Text>
        </View>
        <View style={styles.separator} />
        <View style={styles.feedbackContainer}>
          <Text
            style={[
              styles.mutedText,
              { alignSelf: "center", fontWeight: "500" },
            ]}
          >
            Apakah ulasan ini membantu?
          </Text>
          <TouchableOpacity>
            <View style={styles.feedbackButton}>
              <Image
                source={{ uri: "icon_star_active" }}
                style={{ width: 16, height: 16, marginRight: 2 }}
              />
              <Text style={styles.mutedText}>Membantu</Text>
            </View>
          </TouchableOpacity>
        </View>
      </View>
    );
  };

  _renderHeader = () => {
    return (
      <View>
        <View style={styles.headerContainer}>
          <Text style={{ fontSize: 24, marginBottom: 4 }}>4.9</Text>
          <RatingStars enabled={false} rating={5} iconSize={16} />
          <Text style={{ marginTop: 2 }}>
            <Text>31</Text> Review
          </Text>
          <ProductReviewFilter onFilterSelected={star => {}} />
        </View>

        <Text style={[styles.mutedText, { margin: 16 }]}>
          ULASAN PALING MEMBANTU
        </Text>
      </View>
    );
  };

  _loadingIndicator = () => {
    if (this.state.isLoading)
      return (
        <ActivityIndicator
          animating={true}
          style={[styles.centering, { height: 44 }]}
          size="small"
        />
      );
    else return null;
  };

  _onRefresh = () => {
    //do nothing now
  };

  render() {
    return (
      <View style={{ backgroundColor: "#F1F1F1", flex: 1 }}>
        <FlatList
          ref={ref => {
            this.flatList = ref;
          }}
          style={{ backgroundColor: "#f1f1f1" }}
          onEndReached={distanceFromEnd => {}}
          ListHeaderComponent={this._renderHeader}
          ListFooterComponent={this._loadingIndicator}
          keyExtractor={(item, index) => item.id}
          data={this.state.dataSource}
          onRefresh={this._onRefresh}
          refreshing={false}
          renderItem={this._renderReview}
        />
      </View>
    );
  }
}

const styles = StyleSheet.create({
  headerContainer: {
    backgroundColor: "white",
    alignItems: "center",
    paddingTop: 16,
    paddingBottom: 8,
  },
  mutedText: {
    color: "rgba(0,0,0,0.5)",
  },
  reviewContainer: {
    backgroundColor: "white",
  },
  reviewHeader: {
    flexDirection: "row",
    padding: 8,
    paddingBottom: 0,
  },
  name: {
    fontWeight: "500",
    fontSize: 14,
  },
  separator: {
    height: 1,
    width: "100%",
    backgroundColor: "#F1F1F1",
  },
  reviewHeaderContainer: {
    flexDirection: "row",
    alignItems: "center",
    justifyContent: "space-between",
  },
  optionButton: {
    height: 16,
    width: 16,
    marginRight: 16,
    marginTop: 8,
  },
  feedbackButton: {
    borderRadius: 3,
    borderColor: "#f1f1f1",
    borderWidth: 1,
    paddingVertical: 8,
    paddingHorizontal: 4,
    flexDirection: "row",
  },
  feedbackContainer: {
    flexDirection: "row",
    justifyContent: "space-between",
    alignContent: "center",
    padding: 8,
  },
});

module.exports = ProductReview;
