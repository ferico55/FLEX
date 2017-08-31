"use strict";

import React, { Component } from "react";
import { color } from "../Helper/Color";
import {
  StyleSheet,
  Text,
  View,
  TouchableHighlight,
  ActivityIndicator,
  Image
} from "react-native";

class PromoInfoCell extends Component {
  render() {
    return (
      <View>
        {this.props.isLoading ? this.loadingCell() : this.populatedCell()}
      </View>
    );
  }
  populatedCell() {
    let ad = this.generateCellDataFromAd(this.props.adType, this.props.ad);

    return (
      <View style={styles.promoInfoContainer}>
        <Text style={styles.promoInfoTitleLabel}>
          {ad.title}
        </Text>
        <View style={styles.promoInfoActiveContainer}>
          <View
            style={[
              styles.promoInfoActiveImageView,
              {
                backgroundColor:
                ad.status != 3 ? color.mainGreen : color.lineGrey
              }
            ]}
          />
          <Text style={styles.promoInfoActiveLabel}>
            {ad.statusDesc}
          </Text>
        </View>
        <Text style={styles.promoInfoPerClickLabel}>
          {ad.perClickLabel}
        </Text>
        <Text style={styles.promoInfoUsedCreditsLabel}>
          {ad.usedCreditsLabel}
        </Text>
        {this.additionalInfo(ad)}
      </View>
    );
  }
  additionalInfo(ad) {
    if (
      this.props.adType == 0 &&
      (ad.dailyPriceSpent != "-" && ad.dailyPriceSpent != "")
    ) {
      const greenFlex = parseFloat(ad.dailyPriceBar);
      const emptyFlex = 100 - greenFlex;

      return (
        <View>
          <View style={[styles.priceDailyBarOuter, { flexDirection: "row" }]}>
            <View style={[styles.priceDailyBarInner, { flex: greenFlex }]} />
            <View style={{ flex: emptyFlex }} />
          </View>
          <View style={styles.priceInfoContainer}>
            <Text style={{ color: color.greyText, fontSize: 14 }}>
              Anggaran
            </Text>
            <Text
              style={{
                flex: 1,
                textAlign: "right",
                color: color.blackText,
                fontSize: 14,
                fontWeight: "500"
              }}
            >
              {ad.dailyPriceSpent}
              <Text style={{ color: color.greyText }}>
                {` / ${ad.dailyPrice}`}
              </Text>
            </Text>
          </View>
        </View>
      );
    } else if (this.props.adType == 1 && ad.groupId != 0) {
      return (
        <Text style={{ color: color.greyText, marginTop: 5, fontSize: 14 }}>
          {`Grup: ${ad.groupName}`}
        </Text>
      );
    }
  }
  loadingCell() {
    return <ActivityIndicator size="large" />;
  }

  generateCellDataFromAd(adType, ad) {
    // adType: 0 = group, 1 = product, 2 = shop
    let title = "-";
    let status = 3;
    let statusDesc = "";
    let perClickLabel = "-";
    let usedCreditsLabel = "-";
    let dailyPrice = "-";
    let dailyPriceSpent = "-";
    let dailyPriceBar = "0.000";
    let groupName = "-";
    let groupId = 0;

    if (ad) {
      if (adType == 2) {
        title = ad.shop_name;
        status = ad.ad_status;
        statusDesc = ad.ad_status_desc;
        perClickLabel =
          (ad.ad_price_bid_fmt ? ad.ad_price_bid_fmt : "") +
          " " +
          ad.label_per_click;
        usedCreditsLabel = "Terpakai " + ad.stat_total_spent;
      } else if (adType == 0) {
        title = ad.group_name;
        status = ad.group_status;
        statusDesc = ad.group_status_desc;
        perClickLabel =
          (ad.group_price_bid_fmt ? ad.group_price_bid_fmt : "") +
          " " +
          ad.label_per_click;
        usedCreditsLabel = "Terpakai " + ad.stat_total_spent;
        dailyPrice = ad.group_price_daily_fmt;
        dailyPriceSpent = ad.group_price_daily_spent_fmt;
        dailyPriceBar = ad.group_price_daily_bar;
      } else if (adType == 1) {
        title = ad.product_name;
        status = ad.ad_status;
        statusDesc = ad.ad_status_desc;
        perClickLabel =
          (ad.ad_price_bid_fmt ? ad.ad_price_bid_fmt : "") +
          " " +
          ad.label_per_click;
        usedCreditsLabel = "Terpakai " + ad.stat_total_spent;
        groupId = ad.group_id;
        groupName = ad.group_name;
      }
    }

    return {
      title,
      status,
      statusDesc,
      perClickLabel,
      usedCreditsLabel,
      dailyPrice,
      dailyPriceSpent,
      dailyPriceBar,
      groupId,
      groupName
    };
  }
}

const styles = StyleSheet.create({
  promoInfoContainer: {
    backgroundColor: "white",
    paddingHorizontal: 30,
    paddingBottom: 17
  },
  promoInfoTitleLabel: {
    fontWeight: "500",
    height: 20,
    fontSize: 16,
    marginTop: 15,
    marginBottom: 3,
    color: color.blackText
  },
  promoInfoActiveContainer: {
    height: 20,
    marginBottom: 2,
    flexDirection: "row",
    alignItems: "center"
  },
  promoInfoActiveImageView: {
    height: 8,
    width: 8,
    borderRadius: 4,
    marginRight: 7
  },
  promoInfoActiveLabel: {
    color: color.greyText
  },
  promoInfoPerClickLabel: {
    color: color.greyText,
    height: 20,
    marginBottom: 11
  },
  promoInfoUsedCreditsLabel: {
    fontWeight: "500",
    color: color.blackText,
    fontSize: 16,
    height: 20,
    marginRight: 4
  },
  priceDailyBarOuter: {
    marginTop: 17,
    height: 5,
    borderRadius: 3,
    backgroundColor: color.lineGrey,
    marginBottom: 5
  },
  priceDailyBarInner: {
    borderRadius: 3,
    backgroundColor: color.mainGreen
  },
  priceInfoContainer: {
    height: 20,
    flexDirection: "row"
  }
});

export default PromoInfoCell