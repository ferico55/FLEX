import DateTimePicker from 'react-native-modal-datetime-picker'
import Navigator from 'native-navigation'
import React, { Component } from 'react'
import { StyleSheet, Text, View, TouchableOpacity, Image } from 'react-native'
import moment from 'moment'
import { bindActionCreators } from 'redux'
import { connect } from 'react-redux'

import color from '../Helper/Color'
import AboveTabBar from '../Components/AboveTabBar'
import * as Actions from '../Redux/Actions/GeneralActions'

import checkImg from '../Icon/check.png'
import arrowDownGreenImg from '../Icon/arrow_down_green.png'

let reduxKey = ''

function mapStateToProps(state, ownProps) {
  reduxKey = ownProps.reduxKey
  switch (ownProps.changeDateActionId) {
    case 'CHANGE_DATE_RANGE_DASHBOARD':
      return state.topAdsDashboardReducer
    case 'CHANGE_DATE_RANGE_PROMOLIST':
      return state.promoListPageReducer[reduxKey]
    case 'CHANGE_DATE_RANGE_PROMODETAIL':
      return state.promoDetailPageReducer[reduxKey]
    case 'CHANGE_DATE_RANGE_STATDETAIL':
      return state.statDetailReducer
    default:
      return state
  }
}

function mapDispatchToProps(dispatch) {
  return bindActionCreators(Actions, dispatch)
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: 'white',
  },
  defaultView: {
    flex: 1,
  },
  tableView: {
    marginTop: 5,
    flex: 1,
    backgroundColor: 'white',
  },
  cellTouchable: {
    height: 72,
  },
  cellContainer: {
    flex: 1,
    backgroundColor: color.lineGrey,
  },
  cellSubContainer: {
    flex: 1,
    backgroundColor: 'white',
    flexDirection: 'row',
    alignItems: 'center',
    paddingHorizontal: 20,
    marginBottom: 1,
  },
  cellDateLabelContainer: {
    flex: 1,
    justifyContent: 'center',
  },
  cellDateLabelTop: {
    fontSize: 12,
    color: color.greyText,
  },
  cellDateLabelBottom: {
    fontSize: 16,
    color: color.blackText,
  },
  cellChecklistContainer: {
    width: 16,
    alignItems: 'center',
    justifyContent: 'center',
  },
  cellChecklistView: {
    height: 16,
    width: 16,
    borderWidth: 1,
    borderRadius: 8,
    borderColor: color.darkerGrey,
    overflow: 'hidden',
  },
  cellChecklistImageView: {
    height: 16,
    width: 16,
    overflow: 'hidden',
  },
  customDateContainer: {
    flex: 1,
    marginTop: 5,
    paddingTop: 30,
    backgroundColor: 'white',
  },
  customDateView: {
    marginHorizontal: 20,
    marginBottom: 50,
    height: 45,
    backgroundColor: 'white',
  },
  customDateTitleLabel: {
    height: 15,
    fontSize: 12,
    color: color.greyText,
  },
  customDateValueContainer: {
    flex: 1,
    flexDirection: 'row',
    alignItems: 'center',
    marginBottom: 1.5,
  },
  customDateValueLabel: {
    fontSize: 16,
    color: color.mainGreen,
    flex: 1,
  },
  customDateValueArrow: {
    width: 12,
    height: 8,
  },
  customDateUnderline: {
    height: 1,
    backgroundColor: color.lineGrey,
  },
})

class DateSettingsPage extends Component {
  constructor(props) {
    super(props)
    this.state = {
      selectedTabIndex: 0,
      isDateTimePickerVisible: false,
      selectedCellIndex: this.props.selectedPresetDateRangeIndex,
      momentPresetDateRanges: [],
      tempStartDate: this.props.startDate,
      tempEndDate: this.props.endDate,
      isCustomStartDate: false,
    }
  }
  componentWillMount = () => {
    this.calculatePresetDateRanges()
    if (this.state.selectedCellIndex < 0) {
      this.setState({
        selectedTabIndex: 1,
      })
    }
  }

  showDateTimePicker = isStartDate =>
    this.setState({
      isDateTimePickerVisible: true,
      isCustomStartDate: isStartDate,
      selectedCellIndex: -1,
    })

  hideDateTimePicker = () => this.setState({ isDateTimePickerVisible: false })

  handleDatePicked = (date, isStartDate) => {
    console.log('A date has been picked: ', date)

    if (isStartDate) {
      let theEndDate =
        moment(date) > this.state.tempEndDate
          ? moment(date)
          : this.state.tempEndDate
      if (theEndDate.diff(moment(date), 'days') > 60) {
        theEndDate = moment(date).add(2, 'month')
      }

      this.setState({
        isDateTimePickerVisible: false,
        tempStartDate: moment(date),
        tempEndDate: theEndDate,
      })
    } else {
      this.setState({
        isDateTimePickerVisible: false,
        tempEndDate: moment(date),
      })
    }
  }
  saveDate = () => {
    const actionId = this.props.changeDateActionId
    this.props.changeDateRange({
      actionId,
      theSelectedIndex: this.state.selectedCellIndex,
      theStartDate: this.state.tempStartDate,
      theEndDate: this.state.tempEndDate,
      key: reduxKey,
    })
    Navigator.pop()
  }
  tabBarSelected = index => {
    this.setState({ selectedTabIndex: index })
  }
  cellSelected = index => {
    this.setState({
      selectedCellIndex: index,
      tempStartDate: this.state.momentPresetDateRanges[index].startDate,
      tempEndDate: this.state.momentPresetDateRanges[index].endDate,
    })
  }
  calculatePresetDateRanges = () => {
    const tempArray = []
    tempArray.push({
      title: 'Hari Ini',
      startDate: moment(),
      endDate: moment(),
    })
    tempArray.push({
      title: 'Kemarin',
      startDate: moment().subtract(1, 'day'),
      endDate: moment().subtract(1, 'day'),
    })
    tempArray.push({
      title: '7 Hari Terakhir',
      startDate: moment().subtract(6, 'days'),
      endDate: moment(),
    })
    tempArray.push({
      title: '30 Hari Terakhir',
      startDate: moment().subtract(29, 'days'),
      endDate: moment(),
    })
    tempArray.push({
      title: 'Bulan Ini',
      startDate: moment().startOf('month'),
      endDate: moment(),
    })

    this.setState({
      momentPresetDateRanges: tempArray,
    })
  }
  renderTableView = () => (
    <View style={styles.tableView}>
      {this.state.momentPresetDateRanges.map((dateRange, index) => (
        <TouchableOpacity
          key={index}
          style={styles.cellTouchable}
          onPress={() => this.cellSelected(index)}
        >
          <View style={styles.cellContainer}>
            <View style={styles.cellSubContainer}>
              <View style={styles.cellDateLabelContainer}>
                <Text style={styles.cellDateLabelTop}>{dateRange.title}</Text>
                <Text style={styles.cellDateLabelBottom}>
                  {dateRange.startDate.format('D MMMM YYYY') ===
                  dateRange.endDate.format('D MMMM YYYY') ? (
                    dateRange.startDate.format('D MMMM YYYY')
                  ) : dateRange.startDate.format('YYYY') ===
                  dateRange.endDate.format('YYYY') ? (
                    `${dateRange.startDate.format(
                      'D MMMM',
                    )} - ${dateRange.endDate.format('D MMMM YYYY')}`
                  ) : (
                    `${dateRange.startDate.format(
                      'D MMMM YYYY',
                    )} - ${dateRange.endDate.format('D MMMM YYYY')}`
                  )}
                </Text>
              </View>
              <View style={styles.cellChecklistContainer}>
                {this.state.selectedCellIndex == index ? (
                  <Image
                    style={styles.cellChecklistImageView}
                    source={checkImg}
                  />
                ) : (
                  <View style={styles.cellChecklistView} />
                )}
              </View>
            </View>
          </View>
        </TouchableOpacity>
      ))}
    </View>
  )
  renderCustomDate = () => (
    <View style={styles.customDateContainer}>
      <TouchableOpacity onPress={() => this.showDateTimePicker(true)}>
        <View style={styles.customDateView}>
          <Text style={styles.customDateTitleLabel}>Tanggal Mulai</Text>
          <View style={styles.customDateValueContainer}>
            <Text style={styles.customDateValueLabel}>
              {this.state.tempStartDate.format('D MMMM YYYY')}
            </Text>
            <Image
              style={styles.customDateValueArrow}
              source={arrowDownGreenImg}
            />
          </View>
          <View style={styles.customDateUnderline} />
        </View>
      </TouchableOpacity>
      <TouchableOpacity onPress={() => this.showDateTimePicker(false)}>
        <View style={styles.customDateView}>
          <Text style={styles.customDateTitleLabel}>Tanggal Selesai</Text>
          <View style={styles.customDateValueContainer}>
            <Text style={styles.customDateValueLabel}>
              {this.state.tempEndDate.format('D MMMM YYYY')}
            </Text>
            <Image
              style={styles.customDateValueArrow}
              source={arrowDownGreenImg}
            />
          </View>
          <View style={styles.customDateUnderline} />
        </View>
      </TouchableOpacity>
    </View>
  )
  render = () => {
    const endDateMinimum = this.state.tempStartDate
    let endDateMaximum = moment(endDateMinimum)
    endDateMaximum = endDateMaximum.add(2, 'month')

    return (
      <Navigator.Config
        title="Atur Tanggal"
        rightTitle="Simpan"
        onRightPress={this.saveDate}
      >
        <View style={styles.container}>
          <AboveTabBar
            firstTabTitle="Periode"
            secondTabTitle="Kustom"
            selectedTabIndex={this.state.selectedTabIndex}
            tabBarSelected={this.tabBarSelected}
          />
          {this.state.selectedTabIndex === 0 ? (
            this.renderTableView()
          ) : (
            this.renderCustomDate()
          )}
          <DateTimePicker
            isVisible={this.state.isDateTimePickerVisible}
            onConfirm={date =>
              this.handleDatePicked(date, this.state.isCustomStartDate)}
            onCancel={this.hideDateTimePicker}
            date={
              this.state.isCustomStartDate ? (
                this.state.tempStartDate.toDate()
              ) : (
                this.state.tempEndDate.toDate()
              )
            }
            minimumDate={
              !this.state.isCustomStartDate ? endDateMinimum.toDate() : null
            }
            maximumDate={
              !this.state.isCustomStartDate ? endDateMaximum.toDate() : null
            }
          />
        </View>
      </Navigator.Config>
    )
  }
}

export default connect(mapStateToProps, mapDispatchToProps)(DateSettingsPage)
