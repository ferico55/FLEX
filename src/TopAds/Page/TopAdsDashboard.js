"use strict";

import React, { Component } from "react";
import {
  StyleSheet,
  Text,
  View,
  TouchableOpacity,
  ActivityIndicator,
  Image,
  Dimensions,
  ScrollView,
  RefreshControl,
  AlertIOS
} from "react-native";

import Navigator from "native-navigation";
import { color } from "../Helper/Color";
import AboveTabBar from "../Components/AboveTabBar";
import BigGreenButton from "../Components/BigGreenButton";
import DateSettingsButton from "../Components/DateSettingsButton";
import PromoInfoCell from "../Components/PromoInfoCell";
import { ReactTPRoutes } from "NativeModules";
import moment from "moment";
import {
  requestCreditInfo,
  requestDashboardInfo,
  requestShopTopAdsInfo,
  requestTotalAds
} from "../Helper/Requests";

import { bindActionCreators } from "redux";
import { connect } from "react-redux";
import * as Actions from "../Redux/Actions";

var deviceWidth = Dimensions.get("window").width;

function mapStateToProps(state) {
  return {
    ...state.topAdsDashboardReducer,
    creditState: state.topAdsDashboardCreditReducer,
    dashboardStatisticState: state.topAdsDashboardStatisticReducer,
    shopPromoState: state.topAdsDashboardShopPromoReducer,
    totalAdsState: state.topAdsDashboardTotalAdsReducer
  };
}

function mapDispatchToProps(dispatch) {
  return bindActionCreators(Actions, dispatch);
}

class TopAdsDashboard extends Component {
  constructor(props) {
    super(props);
    this.state = {
      refreshing: false
    };
    this.onAppear = this.onAppear.bind(this);
    this.tabBarSelected = this.tabBarSelected.bind(this);
    this.addCreditButtonTapped = this.addCreditButtonTapped.bind(this);
    this.shopPromoTapped = this.shopPromoTapped.bind(this);
    this.getAllData = this.getAllData.bind(this);
    this.bottomCellTapped = this.bottomCellTapped.bind(this);
  }
  componentDidMount() {
    this.getAllData();
  }
  onAppear() {
    ReactTPRoutes.addNavbarRightButtons([]);
    if (this.props.isNeedRefresh) {
      this.getAllData();
    }
  }
  getAllData() {
    this.props.changeIsNeedRefreshDashboard(false);
    this.props.getDashboardCredit(this.props.authInfo.shop_id);
    this.props.getDashboardStatistic({
      shopId: this.props.authInfo.shop_id,
      type: this.props.selectedTabIndex + 1,
      startDate: this.props.startDate.format("YYYY-MM-DD"),
      endDate: this.props.endDate.format("YYYY-MM-DD")
    });
    this.props.getDashboardShopPromo({
      shopId: this.props.authInfo.shop_id,
      startDate: this.props.startDate.format("YYYY-MM-DD"),
      endDate: this.props.endDate.format("YYYY-MM-DD")
    });
    this.props.getDashboardTotalAds(this.props.authInfo.shop_id);
  }
  render() {
    return (
      <Navigator.Config title="TopAds" onAppear={this.onAppear}>
        <View style={styles.container}>
          <AboveTabBar
            firstTabTitle="Produk"
            secondTabTitle="Toko"
            selectedTabIndex={this.props.selectedTabIndex}
            tabBarSelected={this.tabBarSelected}
          />
          <ScrollView
            refreshControl={
              <RefreshControl
                refreshing={this.state.refreshing}
                onRefresh={() => this.getAllData()}
              />
            }
          >
            <View style={{ marginBottom: 20 }}>
              <View style={styles.shopGeneralInfoContainer}>
                <View style={styles.shopImageContainer}>
                  <Image
                    style={styles.shopImageView}
                    source={{ uri: this.props.authInfo.shop_avatar }}
                  />
                </View>
                <View style={styles.shopNameContainer}>
                  <Text style={styles.shopNameLabel}>
                    {this.props.authInfo.shop_name}
                  </Text>
                  {this.props.creditState.isLoading
                    ? <View style={{ alignSelf: "flex-start" }}>
                        <ActivityIndicator size="small" />
                      </View>
                    : <Text style={styles.shopTAKreditLabel}>
                        Kredit TopAds: {this.props.creditState.creditString}
                      </Text>}
                </View>
                <TouchableOpacity
                  style={styles.shopPlusButton}
                  onPress={this.addCreditButtonTapped}
                  disabled={this.props.creditState.isLoading}
                >
                  <Image
                    style={{ height: 21, width: 21 }}
                    source={require("../Icon/green_plus.png")}
                  />
                </TouchableOpacity>
              </View>
              <View style={styles.line} />
            </View>

            <View style={styles.infoContainer}>
              <DateSettingsButton
                currentDateRange={{
                  startDate: this.props.startDate,
                  endDate: this.props.endDate
                }}
                buttonTapped={this.dateButtonTapped}
              />
              <View style={styles.infoDetailsContainer}>
                {this.infoDetailsMenuRow(
                  "Tampil",
                  this.props.dashboardStatisticState.dataSource
                    ? this.props.dashboardStatisticState.dataSource
                        .impression_sum_fmt
                    : "-",
                  "Klik",
                  this.props.dashboardStatisticState.dataSource
                    ? this.props.dashboardStatisticState.dataSource
                        .click_sum_fmt
                    : "-"
                )}
                {this.infoDetailsMenuRow(
                  "Persentase Klik",
                  this.props.dashboardStatisticState.dataSource
                    ? this.props.dashboardStatisticState.dataSource
                        .ctr_percentage_fmt
                    : "-",
                  "Konversi",
                  this.props.dashboardStatisticState.dataSource
                    ? this.props.dashboardStatisticState.dataSource
                        .conversion_sum_fmt
                    : "-"
                )}
                {this.infoDetailsMenuRow(
                  "Rata-Rata",
                  this.props.dashboardStatisticState.dataSource
                    ? this.props.dashboardStatisticState.dataSource.cost_avg_fmt
                    : "-",
                  "Terpakai",
                  this.props.dashboardStatisticState.dataSource
                    ? this.props.dashboardStatisticState.dataSource.cost_sum_fmt
                    : "-"
                )}
              </View>
            </View>
            {this.props.selectedTabIndex == 1
              ? this.shopBottom()
              : this.productBottom()}
            <View style={{ marginBottom: 50 }} />
          </ScrollView>
        </View>
      </Navigator.Config>
    );
  }
  infoDetailsMenuRow(titleLeft, valueLeft, titleRight, valueRight) {
    let isDisabled = false;
    if (!valueLeft || valueLeft == "" || valueLeft == "-") {
      isDisabled = true;
    }
    return (
      <View style={styles.infoDetailsMenuRow}>
        <TouchableOpacity
          style={{ justifyContent: "center" }}
          onPress={() => this.statCellTapped(titleLeft)}
          disabled={isDisabled}
        >
          <View
            style={[styles.infoDetailsMenuView, { marginRight: 1, height: 86 }]}
          >
            <Text style={styles.infoDetailsTitleLabel}>
              {titleLeft}
            </Text>
            {this.props.dashboardStatisticState.isLoading
              ? <View
                  style={{
                    alignSelf: "flex-start",
                    marginLeft: 20,
                    flex: 1,
                    justifyContent: "center"
                  }}
                >
                  <ActivityIndicator size="small" />
                </View>
              : <Text style={styles.infoDetailsValueLabel}>
                  {valueLeft}
                </Text>}
          </View>
        </TouchableOpacity>
        <TouchableOpacity
          onPress={() => this.statCellTapped(titleRight)}
          disabled={isDisabled}
        >
          <View style={[styles.infoDetailsMenuView, { height: 86 }]}>
            <Text style={styles.infoDetailsTitleLabel}>
              {titleRight}
            </Text>
            {this.props.dashboardStatisticState.isLoading
              ? <View
                  style={{
                    alignSelf: "flex-start",
                    marginLeft: 20,
                    flex: 1,
                    justifyContent: "center"
                  }}
                >
                  <ActivityIndicator size="small" />
                </View>
              : <Text style={styles.infoDetailsValueLabel}>
                  {valueRight}
                </Text>}
          </View>
        </TouchableOpacity>
      </View>
    );
  }
  productBottom() {
    return (
      <View style={styles.productBottomContainer}>
        <TouchableOpacity
          onPress={() => this.bottomCellTapped(0)}
          disabled={this.props.totalAdsState.isLoading}
        >
          <View style={styles.productBottomView}>
            <Text style={styles.productBottomTitleLabel}>Grup</Text>
            {this.props.totalAdsState.isLoading
              ? <View style={{ marginRight: 5 }}>
                  <ActivityIndicator size="small" />
                </View>
              : <Text style={styles.productBottomValueLabel}>
                  {this.props.totalAdsState.dataSource &&
                    this.props.totalAdsState.dataSource.total_product_group_ad}
                </Text>}
            <View style={styles.productBottomArrowView}>
              <Image
                style={styles.productBottomArrowImageView}
                source={require("../Icon/arrow_right.png")}
              />
            </View>
          </View>
        </TouchableOpacity>
        <TouchableOpacity
          onPress={() => this.bottomCellTapped(1)}
          disabled={this.props.totalAdsState.isLoading}
        >
          <View style={styles.productBottomView}>
            <Text style={styles.productBottomTitleLabel}>Produk</Text>
            {this.props.totalAdsState.isLoading
              ? <View style={{ marginRight: 5 }}>
                  <ActivityIndicator size="small" />
                </View>
              : <Text style={styles.productBottomValueLabel}>
                  {this.props.totalAdsState.dataSource &&
                    this.props.totalAdsState.dataSource.total_product_ad}
                </Text>}
            <View style={styles.productBottomArrowView}>
              <Image
                style={styles.productBottomArrowImageView}
                source={require("../Icon/arrow_right.png")}
              />
            </View>
          </View>
        </TouchableOpacity>
      </View>
    );
  }
  shopBottom() {
    if (!this.props.shopPromoState.dataSource) {
      return;
    }

    return this.props.shopPromoState.dataSource.ad_id == 0
      ? <View>
          <View style={styles.line} />
          <View style={styles.promoTokoContainer}>
            <Text style={styles.promoTokoTitleLabel}>
              Promo Toko Anda Kosong
            </Text>
            <Text style={styles.promoTokoInfoLabel}>
              Promosikan toko Anda untuk menambah banyak pengunjung dan
              mendapatkan banyak favorit.
            </Text>
            <BigGreenButton
              title="Tambah Promo Toko"
              buttonAction={this.addPromoButtonTapped}
              disabled={false}
            />
          </View>
          <View style={styles.line} />
        </View>
      : <TouchableOpacity
          onPress={this.shopPromoTapped}
          disabled={this.props.shopPromoState.isLoading}
        >
          {this.props.shopPromoState.dataSource.ad_id
            ? <PromoInfoCell
                isLoading={this.props.shopPromoState.isLoading}
                adType={2}
                ad={this.props.shopPromoState.dataSource}
              />
            : <View />}
        </TouchableOpacity>;
  }

  addCreditButtonTapped() {
    Navigator.push("AddPromoCredit", {});
  }
  tabBarSelected() {
    this.props.getDashboardStatistic({
      shopId: this.props.authInfo.shop_id,
      type: this.props.selectedTabIndex == 0 ? 2 : 1,
      startDate: this.props.startDate.format("YYYY-MM-DD"),
      endDate: this.props.endDate.format("YYYY-MM-DD")
    });
    this.props.changeDashboardTab();
  }
  dateButtonTapped() {
    Navigator.push("DateSettingsPage", {
      changeDateActionId: "CHANGE_DATE_RANGE_DASHBOARD"
    });
  }
  statCellTapped(title) {
    switch (title) {
      case "Tampil":
        this.props.changeStatDetailTab(0);
        break;
      case "Klik":
        this.props.changeStatDetailTab(1);
        break;
      case "Persentase Klik":
        this.props.changeStatDetailTab(2);
        break;
      case "Konversi":
        this.props.changeStatDetailTab(3);
        break;
      case "Rata-Rata":
        this.props.changeStatDetailTab(4);
        break;
      case "Terpakai":
        this.props.changeStatDetailTab(5);
        break;
      default:
    }

    this.props.setInitialDataStatDetail({
      dataSource: this.props.dashboardStatisticState.cellData,
      selectedPresetDateRangeIndex: this.props.selectedPresetDateRangeIndex,
      promoType: this.props.selectedTabIndex == 0 ? 1 : 2,
      startDate: this.props.startDate,
      endDate: this.props.endDate
    });
    Navigator.push("StatDetailPage", {
      clickedTitle: title,
      authInfo: this.props.authInfo
    });
  }
  bottomCellTapped(type) {
    // 0 for group, 1 for product
    const newReduxKey = `L${type}${this.props.authInfo.shop_id}`;
    this.props.changeDateRange({
      actionId: "CHANGE_DATE_RANGE_PROMOLIST",
      theSelectedIndex: this.props.selectedPresetDateRangeIndex,
      theStartDate: this.props.startDate,
      theEndDate: this.props.endDate,
      key: newReduxKey
    });
    Navigator.push("PromoListPage", {
      authInfo: this.props.authInfo,
      promoListType: type,
      reduxKey: newReduxKey
    });
  }
  shopPromoTapped() {
    this.props.setInitialDataPromoDetail({
      promoType: 2,
      promo: this.props.shopPromoState.dataSource,
      selectedPresetDateRangeIndex: this.props.selectedPresetDateRangeIndex,
      startDate: this.props.startDate,
      endDate: this.props.endDate,
      key: "D2" // D for detail, 2 for shop promo key
    });

    Navigator.push("PromoDetailPage", {
      authInfo: this.props.authInfo,
      keyword: this.props.keyword,
      reduxKey: "D2"
    });
  }
  addPromoButtonTapped() {
    AlertIOS.alert(
      "Tambah Promo Tidak Tersedia",
      "Saat ini tambah promo hanya bisa dilakukan dari komputer.",
      [{ text: "OK" }]
    );
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
  line: {
    height: 1,
    backgroundColor: color.lineGrey
  },
  shopGeneralInfoContainer: {
    height: 70,
    backgroundColor: "white",
    flexDirection: "row"
  },
  shopImageContainer: {
    marginHorizontal: 17,
    width: 40,
    alignItems: "center",
    justifyContent: "center"
  },
  shopImageView: {
    backgroundColor: "grey",
    height: 40,
    width: 42,
    borderRadius: 3
  },
  shopNameContainer: {
    flex: 5,
    backgroundColor: "white",
    justifyContent: "center"
  },
  shopNameLabel: {
    fontSize: 13,
    fontWeight: "bold",
    color: color.blackText
  },
  shopTAKreditLabel: {
    fontSize: 13,
    color: color.greyText
  },
  shopPlusButton: {
    width: 30,
    marginLeft: 10,
    marginRight: 17,
    backgroundColor: "white",
    flexDirection: "row",
    alignItems: "center",
    justifyContent: "flex-end"
  },
  infoContainer: {
    marginBottom: 20
  },
  infoDetailsContainer: {
    backgroundColor: color.lineGrey
  },
  infoDetailsMenuRow: {
    height: 86,
    marginBottom: 1,
    flexDirection: "row"
  },
  infoDetailsMenuView: {
    width: deviceWidth / 2 - 0.5,
    paddingVertical: 10,
    backgroundColor: "white",
    justifyContent: "center"
  },
  infoDetailsTitleLabel: {
    height: 15,
    fontSize: 12,
    marginHorizontal: 17,
    color: color.greyText
  },
  infoDetailsValueLabel: {
    height: 40,
    marginHorizontal: 17,
    fontSize: 35,
    color: color.mainGreen
  },
  promoTokoContainer: {
    paddingTop: 15,
    paddingBottom: 29,
    backgroundColor: "white"
  },
  promoTokoTitleLabel: {
    height: 24,
    fontSize: 16,
    color: color.blackText,
    marginBottom: 1,
    textAlign: "center"
  },
  promoTokoInfoLabel: {
    fontSize: 12,
    marginHorizontal: 17,
    color: color.greyText,
    textAlign: "center",
    marginBottom: 15
  },
  productBottomContainer: {
    paddingTop: 1,
    backgroundColor: color.lineGrey
  },
  productBottomView: {
    height: 64,
    paddingHorizontal: 17,
    backgroundColor: "white",
    flexDirection: "row",
    alignItems: "center",
    marginBottom: 1
  },
  productBottomTitleLabel: {
    flex: 1,
    color: color.blackText
  },
  productBottomValueLabel: {
    color: color.mainGreen,
    textAlign: "right",
    marginRight: 3
  },
  productBottomArrowView: {
    width: 20,
    alignItems: "center",
    justifyContent: "center"
  },
  productBottomArrowImageView: {
    height: 12,
    width: 8,
    marginLeft: 6
  }
});

export default connect(mapStateToProps, mapDispatchToProps)(TopAdsDashboard);
