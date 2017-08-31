"use strict";

import Navigator from "native-navigation";
import { color } from "../Helper/Color";
import DateSettingsButton from "../Components/DateSettingsButton";
import NoResultView from "../Components/NoResultView";
import PromoInfoCell from "../Components/PromoInfoCell";
import SearchBar from "../Components/SearchBar";
import { ReactTPRoutes } from "NativeModules";
import React, { Component } from "react";
import {
  StyleSheet,
  Text,
  TextInput,
  View,
  TouchableOpacity,
  ActivityIndicator,
  Image,
  Dimensions,
  FlatList,
  RefreshControl,
  Button,
  AlertIOS,
  NativeEventEmitter
} from "react-native";

import { EventManager } from "NativeModules";

import { bindActionCreators } from "redux";
import { connect } from "react-redux";
import * as Actions from "../Redux/Actions";

let reduxKey = "";
const nativeTabEmitter = new NativeEventEmitter(EventManager);

function mapStateToProps(state, ownProps) {
  reduxKey = `${ownProps.reduxKey}`;
  return {
    ...state.promoListPageReducer[reduxKey],
    promoListType: ownProps.promoListType
  };
}

function mapDispatchToProps(dispatch) {
  return bindActionCreators(Actions, dispatch);
}

class PromoListPage extends Component {
  constructor(props) {
    super(props);
    this.state = {
      searchCancelButtonShown: false,
      navBarNeedsToBeAdded: true
    };

    this.onAppear = this.onAppear.bind(this);
    this.onDisappear = this.onDisappear.bind(this);
    this.clearData = this.clearData.bind(this);
    this.refreshData = this.refreshData.bind(this);
    this.getData = this.getData.bind(this);
    this.noResultButtonTapped = this.noResultButtonTapped.bind(this);
    this.navBarButtonTapped = this.navBarButtonTapped.bind(this);
    this.closeKeyboard = this.closeKeyboard.bind(this);
    this.settingKeyboardCancelButton = this.settingKeyboardCancelButton.bind(
      this
    );
    this.onCancelButtonPress = this.onCancelButtonPress.bind(this);
    this.dateButtonTapped = this.dateButtonTapped.bind(this);
  }
  componentWillUnmount() {
    this.clearData();
  }
  onAppear() {
    if (this.state.navBarNeedsToBeAdded) {
      ReactTPRoutes.addNavbarRightButtons([
        { image: "icon_plus_white_small" },
        { image: "icon_filter_small" }
      ]);

      this.setState({
        navBarNeedsToBeAdded: false
      });
    }

    this.subscription = nativeTabEmitter.addListener(
      "navBarButtonTapped",
      index => {
        this.navBarButtonTapped(index);
      }
    );

    if (this.props.isNeedRefresh) {
      this.refreshData();
    }
  }
  onDisappear() {
    this.subscription.remove();
  }

  clearData() {
    this.props.clearPromoList(reduxKey);
    this.props.resetFilter(reduxKey);
  }
  refreshData() {
    ReactTPRoutes.addNavbarRightButtons([
      { image: "icon_plus_white_small" },
      { image: "icon_filter_small" }
    ]);

    if (this.refs.searchBar) {
      this.refs.searchBar.clearText();
      this.closeKeyboard();
    }

    if (this.props.promoListType == 0) {
      this.props.getGroupAds({
        shopId: this.props.authInfo.shop_id,
        startDate: this.props.startDate.format("YYYY-MM-DD"),
        endDate: this.props.endDate.format("YYYY-MM-DD"),
        keyword: "",
        status: this.props.filter.status,
        groupId: this.props.filter.group.group_id,
        page: 1,
        key: reduxKey
      });
    } else {
      this.props.getProductAds({
        shopId: this.props.authInfo.shop_id,
        startDate: this.props.startDate.format("YYYY-MM-DD"),
        endDate: this.props.endDate.format("YYYY-MM-DD"),
        keyword: "",
        status: this.props.filter.status,
        groupId: this.props.filter.group.group_id,
        page: 1,
        key: reduxKey
      });
    }
  }
  getData() {
    ReactTPRoutes.addNavbarRightButtons([
      { image: "icon_plus_white_small" },
      { image: "icon_filter_small" }
    ]);

    if (this.props.isEndPageReached) {
      return;
    }

    if (this.props.promoListType == 0) {
      this.props.getGroupAds({
        shopId: this.props.authInfo.shop_id,
        startDate: this.props.startDate.format("YYYY-MM-DD"),
        endDate: this.props.endDate.format("YYYY-MM-DD"),
        keyword: this.props.keyword,
        status: this.props.filter.status,
        groupId: this.props.filter.group.group_id,
        page: this.props.page,
        key: reduxKey
      });
    } else {
      this.props.getProductAds({
        shopId: this.props.authInfo.shop_id,
        startDate: this.props.startDate.format("YYYY-MM-DD"),
        endDate: this.props.endDate.format("YYYY-MM-DD"),
        keyword: this.props.keyword,
        status: this.props.filter.status,
        groupId: this.props.filter.group.group_id,
        page: this.props.page,
        key: reduxKey
      });
    }
  }
  searchData(theKeyword) {
    this.closeKeyboard();

    if (this.props.promoListType == 0) {
      this.props.getGroupAds({
        shopId: this.props.authInfo.shop_id,
        startDate: this.props.startDate.format("YYYY-MM-DD"),
        endDate: this.props.endDate.format("YYYY-MM-DD"),
        keyword: theKeyword,
        status: this.props.filter.status,
        group: this.props.filter.group.group_id,
        page: 1,
        key: reduxKey
      });
    } else {
      this.props.getProductAds({
        shopId: this.props.authInfo.shop_id,
        startDate: this.props.startDate.format("YYYY-MM-DD"),
        endDate: this.props.endDate.format("YYYY-MM-DD"),
        keyword: theKeyword,
        status: this.props.filter.status,
        group: this.props.filter.group.group_id,
        page: 1,
        key: reduxKey
      });
    }
  }

  renderItem(item, adType) {
    return (
      <TouchableOpacity onPress={() => this.cellSelected(item)}>
        <View>
          {item.index == 0 ? <View style={styles.separator} /> : null}
          <PromoInfoCell isLoading={false} ad={item.item} adType={adType} />
          <View style={styles.separator} />
        </View>
      </TouchableOpacity>
    );
  }
  renderSeparator() {
    return <View style={styles.separator} />;
  }
  renderNoResult() {
    if (!this.props.isNoPromo) {
      return null;
    }

    if (this.props.isFailedRequest) {
      ReactTPRoutes.addNavbarRightButtons([]);
      return (
        <NoResultView
          title={"Gagal Mendapatkan Data"}
          desc={"Terjadi masalah pada saat pengambilan data"}
          buttonTitle={"Coba Lagi"}
          buttonAction={this.noResultButtonTapped}
        />
      );
    }

    if (this.props.isNoSearchResult || this.props.isFilterApplied) {
      return (
        <NoResultView
          title={"Hasil Tidak Ditemukan"}
          desc={"Silahkan coba lagi atau ganti kata kunci."}
        />
      );
    }

    ReactTPRoutes.addNavbarRightButtons([]);
    const item = this.props.promoListType == 0 ? "grup" : "produk";
    const itemU = item.charAt(0).toUpperCase() + item.slice(1);
    const alertTitle =
      this.props.promoListType == 0
        ? "Grup Promo Anda Kosong"
        : "Promo Produk Anda Kosong";
    const buttonTitle =
      this.props.promoListType == 0
        ? "Tambah Grup Promo"
        : "Tambah Promo Produk";
    const desc =
      this.props.promoListType == 0
        ? "Gunakan Grup Promo dan nikmati kemudahan mengatur Promo Anda dalam sekali pengaturan."
        : "Promosikan produk Anda agar lebih mudah ditemukan pembeli untuk mendapatkan lebih banyak pengunjung dan meningkatkan pembelian.";
    return (
      <NoResultView
        title={alertTitle}
        desc={desc}
        buttonTitle={buttonTitle}
        buttonAction={this.noResultButtonTapped}
      />
    );
  }
  renderContent() {
    const placeholder =
      this.props.promoListType == 0 ? "Cari Grup" : "Cari Produk";
    return (
      <View style={styles.container}>
        <SearchBar
          ref="searchBar"
          placeholder={placeholder}
          onFocus={this.settingKeyboardCancelButton}
          onSearchButtonPress={keyword => this.searchData(keyword)}
          barTintColor={color.backgroundGrey}
          showsCancelButton={this.state.searchCancelButtonShown}
          onCancelButtonPress={this.onCancelButtonPress}
        />
        {this.props.isNoPromo &&
        (this.props.isNoSearchResult || this.props.isFilterApplied)
          ? this.renderNoResult()
          : this.renderSubContent()}
      </View>
    );
  }
  renderSubContent() {
    return (
      <View style={{ flex: 1 }}>
        <DateSettingsButton
          currentDateRange={{
            startDate: this.props.startDate,
            endDate: this.props.endDate
          }}
          buttonTapped={this.dateButtonTapped}
        />
        <FlatList
          contentInset={{ top: 15, left: 0, bottom: 0, right: 0 }}
          contentOffset={{ x: 0, y: -15 }}
          style={styles.tableView}
          keyExtractor={promo => (promo.ad_id ? promo.ad_id : promo.group_id)}
          data={this.props.promoListDataSource}
          renderItem={item => this.renderItem(item, this.props.promoListType)}
          onEndReached={this.getData}
          refreshControl={
            <RefreshControl
              refreshing={this.props.isLoading}
              onRefresh={this.refreshData}
            />
          }
        />
      </View>
    );
  }
  render() {
    const hasNoPromoAtAll =
      this.props.isNoPromo &&
      (!this.props.isNoSearchResult && !this.props.isFilterApplied);
    return (
      <Navigator.Config
        title={this.props.promoListType == 0 ? "Grup" : "Produk"}
        onAppear={this.onAppear}
        onDisappear={this.onDisappear}
      >
        {hasNoPromoAtAll ? this.renderNoResult() : this.renderContent()}
      </Navigator.Config>
    );
  }

  navBarButtonTapped(index) {
    if (index == 0) {
      AlertIOS.alert(
        "Tambah Promo Tidak Tersedia",
        "Saat ini tambah promo hanya bisa dilakukan dari komputer.",
        [{ text: "OK" }]
      );
    } else {
      ReactTPRoutes.addNavbarRightButtons([]);
      this.setState({
        navBarNeedsToBeAdded: true
      });
      Navigator.push("FilterPage", {
        shopId: this.props.authInfo.shop_id,
        reduxKey: reduxKey
      });
    }
  }
  settingKeyboardCancelButton() {
    if (!this.state.searchCancelButtonShown) {
      this.setState({
        searchCancelButtonShown: true
      });
    }
  }
  onCancelButtonPress() {
    this.refreshData();
  }
  closeKeyboard() {
    this.refs.searchBar.unFocus();
  }
  dateButtonTapped() {
    ReactTPRoutes.addNavbarRightButtons([]);
    this.setState({
      navBarNeedsToBeAdded: true
    });
    Navigator.push("DateSettingsPage", {
      changeDateActionId: "CHANGE_DATE_RANGE_PROMOLIST",
      reduxKey: reduxKey
    });
  }
  cellSelected(item) {
    // this.props.needRefreshPromoList(reduxKey);

    const newReduxKey =
      this.props.promoListType == 0
        ? `D${item.item.group_id}`
        : `D${item.item.ad_id}`;
    this.props.setInitialDataPromoDetail({
      promoType: this.props.promoListType,
      promo: item.item,
      selectedPresetDateRangeIndex: this.props.selectedPresetDateRangeIndex,
      startDate: this.props.startDate,
      endDate: this.props.endDate,
      key: newReduxKey
    });

    ReactTPRoutes.addNavbarRightButtons([]);
    this.setState({
      navBarNeedsToBeAdded: true
    });
    Navigator.push("PromoDetailPage", {
      authInfo: this.props.authInfo,
      promoType: this.props.promoListType,
      keyword: this.props.keyword,
      reduxKey: newReduxKey
    });
  }
  noResultButtonTapped() {
    if (this.props.isFailedRequest) {
      ReactTPRoutes.addNavbarRightButtons([
        { image: "icon_plus_white_small" },
        { image: "icon_filter_small" }
      ]);
      this.refreshData();
    } else {
      AlertIOS.alert(
        "Tambah Promo Tidak Tersedia",
        "Saat ini tambah promo hanya bisa dilakukan dari komputer.",
        [{ text: "OK" }]
      );
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
  searchbarContainer: {
    height: 50,
    backgroundColor: "red"
  },
  tableView: {},
  separator: {
    height: 1,
    backgroundColor: color.lineGrey
  }
});

export default connect(mapStateToProps, mapDispatchToProps)(PromoListPage);
