import React, { Component } from "react";
import {
  StyleSheet,
  ScrollView,
  Text,
  TouchableOpacity,
  View,
  FlatList,
  WebView,
  Image,
  ActivityIndicator,
  NativeEventEmitter,
  Button,
  Clipboard,
  Alert,
  ActionSheetIOS,
} from "react-native";
import DeviceInfo from "react-native-device-info";

import axios from "axios";
import PreAnimatedImage from "./PreAnimatedImage";
import {
  TKPReactURLManager,
  ReactNetworkManager,
  TKPReactAnalytics,
  EventManager,
  ReactInteractionHelper,
} from "NativeModules";
import Rx from "rxjs/Rx";

const nativeTabEmitter = new NativeEventEmitter(EventManager);

class Promo extends React.PureComponent {
  constructor(props) {
    super(props);
    this.state = {
      dataSource: [],
      page: 1,
      isLoading: false,
      selectedCategory: 0,
    };
  }

  componentWillUnmount() {
    this.subscription.remove();
    this.aliveSubscription.unsubscribe();
  }

  componentDidMount() {
    this.loadData();
    this.stickyIds = [];

    this.subscription = nativeTabEmitter.addListener(
      "HotlistScrollToTop",
      () => {
        this.flatList.scrollToOffset({ offset: 0, animated: true });
      }
    );
  }

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
    this.state = {
      dataSource: [],
      page: 1,
      isLoading: false,
      selectedCategory: this.state.selectedCategory,
    };

    this.loadData();
  };

  _dropdownText = () => {
    switch (this.state.selectedCategory) {
      case 0:
        return "Semua Promo";
      case 1:
        return "Jual Beli Online";
      case 2:
        return "Official Store";
      case 3:
        return "Pulsa";
      case 4:
        return "Tiket";
    }
  };

  _getCategoryID = index => {
    switch (index) {
      case 0:
        return 0;
      case 1:
        return 2;
      case 2:
        return 8;
      case 3:
        return 3;
      case 4:
        return 4;
    }
  };

  _copyPromoCode = kodepromo => {
    Clipboard.setString(kodepromo);
    ReactInteractionHelper.showStickyAlert("Kode Promo berhasil disalin");
  };

  _getPromoPeriod = (startDate, endDate) => {
    startDate = new Date(startDate);
    endDate = new Date(endDate);
    var period = startDate.getDate();
    if (startDate.getMonth() != endDate.getMonth())
      period += " " + monthNames[startDate.getMonth()];
    if (startDate.getFullYear() != endDate.getFullYear())
      period += " " + startDate.getFullYear();

    period +=
      " - " +
      endDate.getDate() +
      " " +
      monthNames[endDate.getMonth()] +
      " " +
      endDate.getFullYear();
    return period;
  };

  _showDropdown = e => {
    ActionSheetIOS.showActionSheetWithOptions(
      {
        options: [
          "Semua Promo",
          "Jual Beli Online",
          "Official Store",
          "Pulsa",
          "Tiket",
          "Batal",
        ],
        cancelButtonIndex: 5,
      },
      index => {
        if (index >= 5) return;
        this.setState({
          selectedCategory: index,
          page: 1,
          dataSource: [],
        });
        this.loadData(1);
      }
    );
  };

  _listHeader = () => {
    return (
      <TouchableOpacity onPress={e => this._showDropdown(e)}>
        <View style={styles.dropDownWrapper}>
          <Text style={[styles.greyText, { fontWeight: "600" }]}>
            {this._dropdownText()}
          </Text>
          <Image
            source={{ uri: "icon_arrow_down_grey" }}
            style={{ width: 14, height: 14, marginTop: 2, marginRight: 2 }}
          />
        </View>
      </TouchableOpacity>
    );
  };

  _renderItem = (item, index) => {
    return (
      <TouchableOpacity
        onPress={() => {
          this.props.navigation.navigate("tproutes", { url: item.item.link });
        }}
        style={styles.photoContainer}
      >
        <View style={{ borderWidth: 1, borderColor: "rgba(0,0,0,0.12)" }}>
          <PreAnimatedImage
            source={item.item.meta.thumbnail_image}
            style={styles.photo}
            onLoadEnd={() => {
              this.setNativeProps();
            }}
          />
          <View style={styles.textWrapper}>
            <View style={styles.promoWrapper}>
              <View style={{ flexDirection: "row" }}>
                <Image
                  source={{ uri: "icon_stopwatch" }}
                  style={styles.stopwatch}
                />
                <View style={{ flexDirection: "column", marginRight: 15 }}>
                  <Text style={[styles.greyText, styles.subtitle]}>
                    Periode Promo
                  </Text>
                  <Text style={{ color: "rgba(0,0,0,0.7)", fontSize: 14 }}>
                    {this._getPromoPeriod(
                      item.item.meta.start_date,
                      item.item.meta.end_date
                    )}
                  </Text>
                </View>
              </View>

              <View style={{ marginTop: 18, flexDirection: "row" }}>
                <Image source={{ uri: "icon_coupon" }} style={styles.coupon} />
                <View style={{ flexDirection: "column" }}>
                  <View style={{ flexDirection: "row" }}>
                    <Text
                      style={
                        item.item.meta.promo_code == ""
                          ? [styles.greyText, styles.subtitle, { marginTop: 9 }]
                          : [styles.greyText, styles.subtitle]
                      }
                      numberOfLines={2}
                    >
                      {item.item.meta.promo_code == ""
                        ? "Tanpa Kode Promo"
                        : "Kode Promo"}
                    </Text>
                    {item.item.meta.promo_code != "" &&
                      <TouchableOpacity
                        onPress={() =>
                          ReactInteractionHelper.showTooltip(
                            "Kode Promo",
                            "Masukan Kode Promo di halaman pembayaran",
                            "icon_promo",
                            "Tutup"
                          )}
                      >
                        <Image
                          source={{ uri: "icon_information" }}
                          resizeMode="contain"
                          style={
                            item.item.meta.promo_code == ""
                              ? [styles.info, { marginTop: 12 }]
                              : styles.info
                          }
                        />
                      </TouchableOpacity>}
                  </View>
                  <Text style={{ color: "rgba(255,87,34,1)", fontSize: 14 }}>
                    {item.item.meta.promo_code}
                  </Text>
                </View>
                <View style={{ flex: 1 }} />
                {item.item.meta.promo_code != "" &&
                  <TouchableOpacity
                    onPress={() =>
                      this._copyPromoCode(item.item.meta.promo_code)}
                  >
                    <View style={styles.copyButton}>
                      <Text style={{ color: "rgba(0,0,0,0.38)" }}>
                        {"Salin Kode"}
                      </Text>
                    </View>
                  </TouchableOpacity>}
              </View>
            </View>
          </View>
        </View>
      </TouchableOpacity>
    );
  };

  render() {
    return (
      <View style={{ backgroundColor: "#F1F1F1", flex: 1 }}>
        <FlatList
          ref={ref => {
            this.flatList = ref;
          }}
          style={styles.wrapper}
          onEndReached={distanceFromEnd => {
            if (!this.state.isLoading) {
              this.loadData(this.state.page);
            }
          }}
          ListHeaderComponent={this._listHeader}
          ListFooterComponent={this._loadingIndicator}
          keyExtractor={(item, index) => item.id}
          data={this.state.dataSource}
          onRefresh={this._onRefresh}
          numColumns={DeviceInfo.isTablet() ? 2 : 1}
          refreshing={false}
          renderItem={this._renderItem}
        />
      </View>
    );
  }

  loadData(page = 1) {
    if (this.state.page == -1) return;

    this.setState({
      isLoading: true,
    });

    var params = { page: page, per_page: 12, categories_exclude: 30 };
    var featuredParams = { categories_exclude: 30, sticky: true };
    if (this.state.selectedCategory != 0) {
      params.categories = this._getCategoryID(this.state.selectedCategory);
      featuredParams.categories = this._getCategoryID(
        this.state.selectedCategory
      );
    }

    var promoRequest = Rx.Observable.fromPromise(
      ReactNetworkManager.request({
        method: "GET",
        baseUrl: TKPReactURLManager.tokopediaUrl,
        path: "/promo/wp-json/wp/v2/posts",
        params: params,
      })
    );

    if (page > 1) {
      promoRequest.catch(err => {
        this.setState({
          isLoading: false,
        });
        return Rx.Observable.empty();
      });
      if (this.aliveSubscription) this.aliveSubscription.unsubscribe();
      this.aliveSubscription = promoRequest.subscribe(response => {
        var dataSource = [];
        if (
          response.code &&
          response.code == "rest_post_invalid_page_number" &&
          response.data.status == 400
        ) {
          this.setState({
            page: -1,
            isLoading: false,
          });
          return;
        }

        var keys = Object.keys(response);
        for (let i = 0; i < keys.length; i++) {
          if (this.stickyIds.includes(response[keys[i]].id)) {
            continue;
          }
          dataSource.push(response[keys[i]]);
        }

        this.setState({
          dataSource: this.state.dataSource.concat(dataSource),
          isLoading: false,
          page: this.state.page + 1,
        });
      });
    } else {
      var featuredPromoRequest = Rx.Observable.fromPromise(
        ReactNetworkManager.request({
          method: "GET",
          baseUrl: TKPReactURLManager.tokopediaUrl,
          path: "/promo/wp-json/wp/v2/posts",
          params: featuredParams,
        })
      );
      var request = Rx.Observable
        .zip(featuredPromoRequest, promoRequest)
        .catch(err => {
          this.setState({
            isLoading: false,
          });
          return Rx.Observable.empty();
        });
      this.aliveSubscription = request.subscribe(response => {
        var dataSource = [];
        for (let idx = 0; idx < response.length; idx++) {
          var keys = Object.keys(response[idx]);
          for (var i = 0; i < keys.length; i++) {
            if (idx == 0) {
              this.stickyIds.push(response[idx][keys[i]].id);
            } else if (this.stickyIds.includes(response[idx][keys[i]].id)) {
              continue;
            }
            dataSource.push(response[idx][keys[i]]);
          }
        }

        this.setState({
          dataSource: this.state.dataSource.concat(dataSource),
          isLoading: false,
          page: this.state.page + 1,
        });
      });
    }
  }
}

const monthNames = [
  "Januari",
  "Februari",
  "Maret",
  "April",
  "Mei",
  "Juni",
  "Juli",
  "Agustus",
  "September",
  "Oktober",
  "November",
  "Desember",
];

const styles = StyleSheet.create({
  container: {
    flexDirection: "column",
    backgroundColor: "#F1F1F1",
    padding: 5,
    flex: 1,
  },
  text: {
    fontSize: 12,
  },
  photoContainer: {
    flexDirection: "column",
    backgroundColor: "#F1F1F1",
    padding: 5,
    flex: DeviceInfo.isTablet() ? 1 : 0,
  },
  photo: {
    resizeMode: "cover",
    aspectRatio: 1.91,
    justifyContent: "center",
  },
  wrapper: {
    backgroundColor: "#F1F1F1",
    paddingTop: 5,
    paddingHorizontal: 5,
  },
  centering: {
    alignItems: "center",
    justifyContent: "center",
    padding: 8,
  },
  textWrapper: {
    flexDirection: "column",
    justifyContent: "space-between",
    backgroundColor: "white",
  },
  detailText: {
    color: "#66b573",
    fontSize: 14,
    fontWeight: "600",
  },
  actionWrapper: {
    borderTopWidth: 1,
    borderColor: "rgba(0,0,0,0.12)",
    paddingVertical: 20,
    paddingRight: 15,
    alignItems: "flex-end",
  },
  greyText: {
    color: "rgba(0,0,0,0.38)",
  },
  promoWrapper: {
    paddingLeft: 18,
    paddingTop: 13,
    paddingBottom: 22,
    paddingRight: 20,
  },
  copyButton: {
    borderColor: "rgb(224,224,224)",
    borderWidth: 1,
    borderRadius: 3,
    paddingHorizontal: 10,
    height: 30,
    justifyContent: "center",
  },
  stopwatch: {
    marginRight: 11,
    marginTop: 4,
    width: 24,
    height: 26,
  },
  coupon: {
    marginRight: 11,
    marginTop: 10,
    width: 25,
    height: 14,
  },
  info: {
    marginLeft: 5,
    height: 14,
    width: 14,
  },
  dropDownWrapper: {
    margin: 5,
    padding: 13,
    backgroundColor: "white",
    flexDirection: "row",
    justifyContent: "space-between",
  },
  subtitle: {
    fontSize: 12,
  },
});

module.exports = Promo;
