"use strict";

import Navigator from "native-navigation";
import { color } from "../Helper/Color";
import DateSettingsButton from "../Components/DateSettingsButton";
import moment from "moment";
import React, { Component } from "react";
import { ReactTPRoutes } from "NativeModules";
import {
  StyleSheet,
  Text,
  TextInput,
  View,
  TouchableOpacity,
  ActivityIndicator,
  Image,
  FlatList,
  ScrollView,
  Switch
} from "react-native";

import { bindActionCreators } from "redux";
import { connect } from "react-redux";
import * as Actions from "../Redux/Actions";

let reduxKey = "";

function mapStateToProps(state, ownProps) {
  reduxKey = `${ownProps.reduxKey}`;
  return {
    ...state.promoDetailPageReducer[reduxKey],
    keyword: ownProps.keyword
  };
}

function mapDispatchToProps(dispatch) {
  return bindActionCreators(Actions, dispatch);
}

class PromoDetailPage extends Component {
  constructor(props) {
    super(props);
    this.getData = this.getData.bind(this);
    this.dateButtonTapped = this.dateButtonTapped.bind(this);
    this.switchToggled = this.switchToggled.bind(this);
    this.groupOrProductAction = this.groupOrProductAction.bind(this);
    this.goToNativeAction = this.goToNativeAction.bind(this);
  }
  componentDidMount() {
    ReactTPRoutes.addNavbarRightButtons([]);
  }
  getData() {
    if (this.props.promoType == 0) {
      this.props.getGroupAdDetail({
        shopId: this.props.authInfo.shop_id,
        startDate: this.props.startDate.format("YYYY-MM-DD"),
        endDate: this.props.endDate.format("YYYY-MM-DD"),
        keyword: this.props.keyword,
        status: this.props.promo.group_status,
        groupId: this.props.promo.group_id,
        key: reduxKey
      });
    } else if (this.props.promoType == 1) {
      this.props.getProductAds({
        shopId: this.props.authInfo.shop_id,
        startDate: this.props.startDate.format("YYYY-MM-DD"),
        endDate: this.props.endDate.format("YYYY-MM-DD"),
        keyword: this.props.keyword,
        status: this.props.promo.ad_status,
        groupId: this.props.promo.group_id,
        adId: this.props.promo.ad_id,
        key: reduxKey
      });
    } else {
      this.props.getShopAdDetail({
        shopId: this.props.authInfo.shop_id,
        startDate: this.props.startDate.format("YYYY-MM-DD"),
        endDate: this.props.endDate.format("YYYY-MM-DD"),
        key: reduxKey
      });
    }
  }
  renderNormalCell(data, item, index) {
    return (
      <View key={index} style={styles.mainCellOuter}>
        <View key={index} style={styles.mainCell}>
          <View
            style={{
              height: 64,
              justifyContent: "center",
              marginRight: 5
            }}
          >
            <Text style={{ fontSize: 14, color: color.blackText }}>
              {item.title}
            </Text>
          </View>
          {this.props.isLoading
            ? <View style={{ flex: 1, flexDirection: "row-reverse" }}>
              <ActivityIndicator size="small" />
            </View>
            : <Text style={styles.valueLabel}>
              {item.value}
            </Text>}
        </View>
        <View style={styles.separator} />
      </View>
    );
  }
  render() {
    let navTitle = "Detail Promo Toko";
    let nameTitleString = "Toko";
    if (this.props.promoType == 0) {
      navTitle = "Detail Promo Grup";
      nameTitleString = "Grup";
    } else if (this.props.promoType == 1) {
      navTitle = "Detail Promo Produk";
      nameTitleString = "Produk";
    }
    const data = this.generateData();

    let isSwitchOn = data.status != 3;
    if (this.props.isStatusLoading) {
      isSwitchOn = !isSwitchOn;
    }

    // the scrollview seems to work if the height is set to whatever
    return (
      <Navigator.Config title={navTitle} onAppear={this.getData}>
        <View style={styles.container}>
          <ScrollView style={{ height: 0 }}>
            <DateSettingsButton
              currentDateRange={{
                startDate: this.props.startDate,
                endDate: this.props.endDate
              }}
              buttonTapped={this.dateButtonTapped}
            />
            <View style={styles.mainCellContainer}>
              <View style={styles.separator} />
              <View style={styles.mainCellOuter}>
                <TouchableOpacity
                  style={{ flex: 1 }}
                  onPress={this.goToNativeAction}
                  disabled={nameTitleString == "Grup"}
                >
                  <View style={styles.mainCell}>
                    <View
                      style={{
                        height: 64,
                        width: 60,
                        justifyContent: "center",
                        marginRight: 5
                      }}
                    >
                      <Text style={styles.titleUpperLabel}>
                        {nameTitleString}
                      </Text>
                    </View>
                    {this.props.promoType == 0
                      ? <Text style={[styles.valueLabel, { fontSize: 16 }]}>
                        {data.name}
                      </Text>
                      : <Text style={styles.greenValueLabel}>
                        {data.name}
                      </Text>}
                  </View>
                </TouchableOpacity>
              </View>
              <View style={styles.separator} />
              <View style={styles.mainCellOuter}>
                <View style={styles.mainCell}>
                  <View
                    style={{
                      height: 64,
                      width: 60,
                      justifyContent: "center",
                      marginRight: 5
                    }}
                  >
                    <Text style={styles.titleUpperLabel}>Status</Text>
                  </View>
                  <View style={styles.valueSubContainer}>
                    <Switch
                      style={styles.switch}
                      onValueChange={this.switchToggled}
                      value={isSwitchOn}
                      disabled={this.props.isStatusLoading}
                    />
                    {this.props.isStatusLoading || this.props.isLoading
                      ? <ActivityIndicator size="small" />
                      : <Text style={styles.valueLabel}>
                        {data.statusDesc}
                      </Text>}
                  </View>
                </View>
              </View>
              <View style={styles.separator} />
            </View>
            {this.props.promoType != 2
              ? <View style={styles.mainCellContainer}>
                <View style={styles.separator} />
                <View style={styles.mainCellOuter}>
                  <View style={styles.mainCell}>
                    <View
                      style={{
                        height: 64,
                        width: 60,
                        justifyContent: "center",
                        marginRight: 5
                      }}
                    >
                      <Text style={styles.titleUpperLabel}>
                        {this.props.promoType == 0 ? "Produk" : "Grup"}
                      </Text>
                    </View>
                    {this.props.promo.group_id == 0 &&
                      this.props.promoType == 1
                      ? <View style={styles.valueSubContainer}>
                        <Text style={[styles.valueLabel, { fontSize: 16 }]}>
                          {data.totalAdsOrGroup}
                        </Text>
                      </View>
                      : <TouchableOpacity
                        onPress={this.groupOrProductAction}
                        style={{ flex: 1 }}
                      >
                        <View style={styles.valueSubContainer}>
                          {this.props.promoType == 0
                            ? <Image
                              style={styles.arrowImageView}
                              source={require("../Icon/arrow_right.png")}
                            />
                            : null}
                          <Text style={styles.greenValueLabel}>
                            {data.totalAdsOrGroup}
                          </Text>
                        </View>
                      </TouchableOpacity>}
                  </View>
                </View>
                <View style={styles.separator} />
              </View>
              : null}

            <View style={styles.mainCellContainer}>
              <View style={styles.separator} />
              <View style={styles.mainCellOuter}>
                <View style={styles.mainCell}>
                  <View
                    style={{
                      height: 64,
                      justifyContent: "center",
                      marginRight: 5
                    }}
                  >
                    <Text style={styles.titleHeaderLabel}>
                      {data.costAndScheduleData.length > 2
                        ? "Biaya & Jadwal"
                        : "Biaya Promo"}
                    </Text>
                  </View>
                </View>
                <View style={styles.separator} />
              </View>
              {data.costAndScheduleData.map((item, index) =>
                this.renderNormalCell(data, item, index)
              )}
            </View>
            <View style={styles.mainCellContainer}>
              <View style={styles.separator} />
              <View style={styles.mainCellOuter}>
                <View style={styles.mainCell}>
                  <View
                    style={{
                      height: 64,
                      justifyContent: "center",
                      marginRight: 5
                    }}
                  >
                    <Text style={styles.titleHeaderLabel}>
                      Ringkasan Statistik
                    </Text>
                  </View>
                </View>
              </View>
              <View style={styles.separator} />
              {data.statisticSumData.map((item, index) =>
                this.renderNormalCell(data, item, index)
              )}
            </View>
          </ScrollView>
        </View>
      </Navigator.Config>
    );
  }
  generateData() {
    let name = "-";
    if (this.props.promoType == 0 && this.props.promo) {
      name = this.props.promo.group_name ? this.props.promo.group_name : "-";
    } else if (this.props.promoType == 1) {
      name = this.props.promo.product_name
        ? this.props.promo.product_name
        : "-";
    } else {
      name = this.props.promo.shop_name ? this.props.promo.shop_name : "-";
    }

    const status =
      this.props.promoType == 0
        ? this.props.promo.group_status
        : this.props.promo.ad_status;
    const statusDesc =
      this.props.promoType == 0
        ? this.props.promo.group_status_desc
        : this.props.promo.ad_status_desc;
    const totalAdsOrGroup =
      this.props.promoType == 0
        ? this.props.promo.total_item + " Produk"
        : this.props.promo.group_name;
    const maxCost =
      (this.props.promoType == 0
        ? this.props.promo.group_price_bid_fmt
        : this.props.promo.ad_price_bid_fmt) +
      " " +
      this.props.promo.label_per_click;
    const avgClick = this.props.promo.stat_avg_click;

    const startDate =
      this.props.promoType == 0
        ? this.props.promo.group_start_date +
        " - " +
        this.props.promo.group_start_time
        : this.props.promo.ad_start_date +
        " - " +
        this.props.promo.ad_start_time;
    const endDate =
      this.props.promoType == 0
        ? this.props.promo.group_end_date +
        (this.props.promo.group_end_time != ""
          ? " - " + this.props.promo.group_end_time
          : "")
        : this.props.promo.ad_end_date +
        (this.props.promo.ad_end_time != ""
          ? " - " + this.props.promo.ad_end_time
          : "");
    const dailySpent =
      this.props.promoType == 0
        ? this.props.promo.group_price_daily_spent_fmt != ""
          ? this.props.promo.group_price_daily_spent_fmt +
          " / " +
          this.props.promo.group_price_daily_fmt
          : this.props.promo.group_price_daily_fmt
        : this.props.promo.ad_price_daily_spent_fmt != ""
          ? this.props.promo.ad_price_daily_spent_fmt +
          " / " +
          this.props.promo.ad_price_daily_fmt
          : this.props.promo.ad_price_daily_fmt;

    const spent = this.props.promo.stat_total_spent;
    const impression = this.props.promo.stat_total_impression;
    const click = this.props.promo.stat_total_click;
    const ctr = this.props.promo.stat_total_ctr;
    const sold = this.props.promo.stat_total_conversion;

    var costAndScheduleData = [
      { title: "Biaya Maks", value: maxCost },
      { title: "Rata-rata", value: avgClick }
    ];

    if (this.props.promoType == 0 || this.props.promoType == 2) {
      costAndScheduleData = costAndScheduleData.concat([
        { title: "Mulai", value: startDate },
        { title: "Selesai", value: endDate },
        { title: "Anggaran Harian", value: dailySpent }
      ]);
    } else {
      if (this.props.promo.group_id == 0) {
        costAndScheduleData = costAndScheduleData.concat([
          { title: "Mulai", value: startDate },
          { title: "Selesai", value: endDate },
          { title: "Anggaran Harian", value: dailySpent }
        ]);
      }
    }

    const statisticSumData = [
      { title: "Terpakai", value: spent },
      { title: "Tampil", value: impression },
      { title: "Klik", value: click },
      { title: "Persentase Klik", value: ctr },
      { title: this.props.promoType == 2 ? "Favorit" : "Terjual", value: sold }
    ];

    var item = {
      name: "-",
      status: "-",
      statusDesc: "-",
      totalAdsOrGroup: "-",
      costAndScheduleData: [],
      statisticSumData: []
    };

    const adId =
      this.props.promoType == 0
        ? this.props.promo.group_id
        : this.props.promo.ad_id;
    if (adId && adId != "undefined" && adId != "" && name != "-") {
      item = {
        name: name,
        status: status,
        statusDesc: statusDesc,
        totalAdsOrGroup: totalAdsOrGroup,
        costAndScheduleData: costAndScheduleData,
        statisticSumData: statisticSumData
      };
    }

    return item;
  }
  dateButtonTapped() {
    Navigator.push("DateSettingsPage", {
      changeDateActionId: "CHANGE_DATE_RANGE_PROMODETAIL",
      reduxKey: reduxKey
    });
  }
  switchToggled(value) {
    if (this.props.promoType == 0) {
      this.props.toggleStatusGroupAd({
        toggleOn: value,
        shopId: this.props.authInfo.shop_id,
        groupId: this.props.promo.group_id,
        key: reduxKey
      });
    } else if (this.props.promoType == 1) {
      this.props.toggleStatusProductAd({
        toggleOn: value,
        shopId: this.props.authInfo.shop_id,
        adId: this.props.promo.ad_id,
        key: reduxKey
      });
    } else {
      this.props.changeIsNeedRefreshDashboard(true);
      this.props.toggleStatusShopAd({
        toggleOn: value,
        shopId: this.props.authInfo.shop_id,
        adId: this.props.promo.ad_id,
        key: reduxKey
      });
    }
  }
  goToNativeAction() {
    if (this.props.promoType == 1 && this.props.promo) {
      ReactTPRoutes.navigate(`tokopedia://product/${this.props.promo.item_id}`);
    }

    if (this.props.promoType == 2 && this.props.promo) {
      ReactTPRoutes.navigate(`tokopedia://shop/${this.props.promo.shop_id}`);
    }
  }
  groupOrProductAction() {
    if (this.props.promoType == 0) {
      const newReduxKey = `L1${this.props.authInfo.shop_id}`;
      this.props.changeTempGroupFilter({
        tempGroup: {
          group_id: this.props.promo.group_id,
          group_name: this.props.promo.group_name
        },
        key: newReduxKey
      });
      this.props.changePromoListFilter({
        status: 0,
        key: newReduxKey
      });

      this.props.changeDateRange({
        actionId: "CHANGE_DATE_RANGE_PROMOLIST",
        theSelectedIndex: this.props.selectedPresetDateRangeIndex,
        theStartDate: this.props.startDate,
        theEndDate: this.props.endDate,
        key: newReduxKey
      });
      Navigator.push("PromoListPage", {
        authInfo: this.props.authInfo,
        promoListType: 1,
        reduxKey: newReduxKey
      });
    } else {
      if (this.props.promo.group_id == 0) {
        return;
      }

      const newReduxKey = `D0${this.props.promo.group_id}`;
      this.props.setInitialDataPromoDetail({
        promoType: 0,
        promo: {
          group_id: this.props.promo.group_id
        },
        selectedPresetDateRangeIndex: this.props.selectedPresetDateRangeIndex,
        startDate: this.props.startDate,
        endDate: this.props.endDate,
        key: newReduxKey
      });

      Navigator.push("PromoDetailPage", {
        authInfo: this.props.authInfo,
        keyword: this.props.keyword,
        reduxKey: newReduxKey
      });
    }
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
  separator: {
    height: 1,
    backgroundColor: color.lineGrey
  },
  mainCellContainer: {
    backgroundColor: color.backgroundGrey,
    marginTop: 15
  },
  mainCellOuter: {
    justifyContent: "center",
    flex: 1
  },
  mainCell: {
    flex: 1,
    backgroundColor: "white",
    flexDirection: "row",
    alignItems: "center",
    paddingHorizontal: 17
  },
  titleUpperLabel: {
    fontSize: 16,
    color: color.blackText
  },
  valueLabel: {
    flex: 1,
    textAlign: "right",
    fontSize: 14,
    color: color.greyText,
    marginVertical: 5
  },
  greenValueLabel: {
    flex: 1,
    fontSize: 16,
    color: color.mainGreen,
    textAlign: "right",
    marginVertical: 5
  },
  titleHeaderLabel: {
    fontSize: 16,
    fontWeight: "500",
    color: color.blackText
  },
  valueSubContainer: {
    flex: 1,
    flexDirection: "row-reverse",
    alignItems: "center"
  },
  switch: {
    marginLeft: 10
  },
  activeSwitch: {
    backgroundColor: color.mainGreen,
    marginLeft: 10,
    height: 15,
    width: 30
  },
  arrowImageView: {
    height: 15,
    width: 10,
    marginLeft: 6
  }
});

export default connect(mapStateToProps, mapDispatchToProps)(PromoDetailPage);
