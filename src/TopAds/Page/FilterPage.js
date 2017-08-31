"use strict";

import Navigator from "native-navigation";
import SelectableCell from "../Components/SelectableCell";
import BigGreenButton from "../Components/BigGreenButton";
import { color } from "../Helper/Color";
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
  FlatList
} from "react-native";

import { bindActionCreators } from "redux";
import { connect } from "react-redux";
import * as Actions from "../Redux/Actions";

let reduxKey = "";

function mapStateToProps(state, ownProps) {
  reduxKey = ownProps.reduxKey;
  return state.promoListPageReducer[reduxKey];
}

function mapDispatchToProps(dispatch) {
  return bindActionCreators(Actions, dispatch);
}

class FilterPage extends Component {
  constructor(props) {
    super(props);
    this.state = {
      isStatusMenuOpened: false,
      statuses: [
        { id: 0, value: "Semua Status", isSelected: false },
        { id: 1, value: "Aktif", isSelected: false },
        { id: 2, value: "Tidak Terkirim", isSelected: false },
        { id: 3, value: "Tidak Aktif", isSelected: false }
      ],
      selectedIndex: this.props.filter.status
    };
    this.statusCellSelected = this.statusCellSelected.bind(this);
    this.resetFilter = this.resetFilter.bind(this);
    this.selectButtonTapped = this.selectButtonTapped.bind(this);
  }
  componentDidMount() {
    this.props.changeTempGroupFilter({
      tempGroup: {
        group_id: this.props.filter.group.group_id,
        group_name: this.props.filter.group.group_name
      },
      key: reduxKey
    });
  }
  renderStatusMenu() {
    return this.state.statuses.map((status, index) =>
      <View key={status.id}>
        <SelectableCell
          currentIndex={status.id}
          cellSelected={this.statusCellSelected}
          title={status.value}
          isSelected={index == this.state.selectedIndex}
        />
        {index < this.state.statuses.length - 1
          ? <View style={styles.separator} />
          : null}
      </View>
    );
  }
  render() {
    const tempSelectedGroupName =
      this.generateSelectedGroupName() == "Semua Grup"
        ? ""
        : this.generateSelectedGroupName();
    const isNoNewFilterFilter =
      this.state.selectedIndex == this.props.filter.status &&
      tempSelectedGroupName == this.props.filter.group.group_name;

    return (
      <Navigator.Config
        title="Filter"
        rightTitle="Reset"
        onRightPress={this.resetFilter}
        hidesBackButton={false}
      >
        <View style={styles.container}>
          <View style={styles.mainCellContainer}>
            <TouchableOpacity onPress={() => this.statusMenuTapped()}>
              <View style={styles.mainCell}>
                <View
                  style={{
                    height: 64,
                    width: 50,
                    justifyContent: "center",
                    marginRight: 5
                  }}
                >
                  <Text style={{ fontSize: 16, color: color.blackText }}>
                    Status
                  </Text>
                </View>
                <View style={styles.valueSubContainer}>
                  <Image
                    style={
                      this.state.isStatusMenuOpened
                        ? styles.arrowImageViewDown
                        : styles.arrowImageViewRight
                    }
                    source={
                      this.state.isStatusMenuOpened
                        ? require("../Icon/arrow_down.png")
                        : require("../Icon/arrow_right.png")
                    }
                  />
                  <Text style={styles.greenValueLabel}>
                    {this.state.statuses[this.state.selectedIndex].value}
                  </Text>
                </View>
              </View>
            </TouchableOpacity>
            {this.state.isStatusMenuOpened ? this.renderStatusMenu() : null}
            <View style={styles.separator} />
          </View>
          <View style={styles.mainCellContainer}>
            <View style={styles.separator} />
            <TouchableOpacity onPress={() => this.groupMenuTapped()}>
              <View style={styles.mainCell}>
                <View
                  style={{
                    height: 64,
                    width: 50,
                    justifyContent: "center",
                    marginRight: 5
                  }}
                >
                  <Text style={styles.titleLabel}>Grup</Text>
                </View>
                <View style={styles.valueSubContainer}>
                  <Image
                    style={styles.arrowImageViewRight}
                    source={require("../Icon/arrow_right.png")}
                  />
                  <Text style={styles.greenValueLabel}>
                    {this.generateSelectedGroupName()}
                  </Text>
                </View>
              </View>
            </TouchableOpacity>
            <View style={styles.separator} />
          </View>
          <View style={styles.selectButton}>
            <BigGreenButton
              title={"Simpan"}
              buttonAction={this.selectButtonTapped}
              disabled={isNoNewFilterFilter}
            />
          </View>
        </View>
      </Navigator.Config>
    );
  }

  resetFilter() {
    // this.props.resetFilter({key: reduxKey})
    this.props.changeTempGroupFilter({
      tempGroup: {
        group_id: "",
        group_name: ""
      },
      key: reduxKey
    });

    this.setState({
      selectedIndex: 0,
      isStatusMenuOpened: false
    });
  }
  statusMenuTapped() {
    this.setState({
      isStatusMenuOpened: !this.state.isStatusMenuOpened
    });
  }
  groupMenuTapped() {
    Navigator.push("FilterGrupPage", {
      shopId: this.props.shopId,
      reduxKey: reduxKey
    });
  }
  selectButtonTapped() {
    this.props.changePromoListFilter({
      status: this.state.selectedIndex,
      key: reduxKey
    });
    Navigator.pop();
  }
  statusCellSelected(index) {
    this.setState({
      selectedIndex: index
    });
  }
  generateSelectedGroupName() {
    var name = "";
    if (
      this.props.filter.tempGroup.group_name ==
      this.props.filter.group.group_name
    ) {
      name = this.props.filter.group.group_name;
    } else {
      name = this.props.filter.tempGroup.group_name;
    }
    return name != "" ? name : "Semua Grup";
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
    marginBottom: 20
  },
  mainCell: {
    backgroundColor: "white",
    flexDirection: "row",
    alignItems: "center",
    paddingHorizontal: 10
  },
  titleLabel: {
    fontSize: 16,
    color: color.blackText
  },
  greenValueLabel: {
    fontSize: 16,
    color: color.mainGreen
  },
  valueSubContainer: {
    flexDirection: "row-reverse",
    alignItems: "center",
    flex: 1
  },
  arrowImageViewDown: {
    height: 8,
    width: 12,
    marginLeft: 6
  },
  arrowImageViewRight: {
    height: 12,
    width: 8,
    marginLeft: 6
  },
  selectButton: {
    position: "absolute",
    left: 10,
    right: 10,
    bottom: 10
  }
});

export default connect(mapStateToProps, mapDispatchToProps)(FilterPage);
