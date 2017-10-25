import Navigator from 'native-navigation'
import { TKPReactAnalytics } from 'NativeModules'
import DateTimePicker from 'react-native-modal-datetime-picker'
import moment from 'moment'
import { bindActionCreators } from 'redux'
import { connect } from 'react-redux'
import React, { Component } from 'react'
import {
  StyleSheet,
  Text,
  View,
  TouchableOpacity,
  TouchableWithoutFeedback,
  Keyboard,
  Image,
  ActivityIndicator,
} from 'react-native'

import color from '../Helper/Color'
import BigGreenButton2 from '../Components/BigGreenButton2'
import * as AddPromoActions from '../Redux/Actions/AddPromoActions'
import * as DashboardActions from '../Redux/Actions/DashboardActions'

import checkImg from '../Icon/check.png'
import arrowDownGreenImg from '../Icon/arrow_down_green.png'

function mapStateToProps(state) {
  return {
    ...state.addPromoReducer,
  }
}

function mapDispatchToProps(dispatch) {
  return bindActionCreators(
    { ...AddPromoActions, ...DashboardActions },
    dispatch,
  )
}

const styles = StyleSheet.create({
  progressBarContainer: {
    height: 2,
    flexDirection: 'row',
  },
  progressBarValueSide: {
    backgroundColor: color.mainGreen,
  },
  progressBarEmptySide: {
    backgroundColor: color.backgroundGrey,
  },
  container: {
    flex: 1,
    paddingHorizontal: 15,
    backgroundColor: 'white',
  },
  separator: {
    height: 1,
    flex: 1,
    backgroundColor: color.lineGrey,
  },
  aboveLabel: {
    marginTop: 25,
    fontSize: 24,
    fontWeight: '300',
    marginBottom: 25,
  },
  cellOuterContainer: {
    marginBottom: 10,
  },
  cellContainer: {
    height: 34,
    marginLeft: 2,
    flexDirection: 'row',
    alignItems: 'center',
  },
  cellChecklistContainer: {
    width: 16,
    marginRight: 19,
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
  },
  customDateContainer: {
    flex: 1,
    marginTop: 5,
    paddingTop: 30,
    backgroundColor: 'white',
  },
  customDateView: {
    marginBottom: 30,
    height: 45,
    backgroundColor: 'transparent',
  },
  customDateTitleLabel: {
    height: 15,
    fontSize: 12,
    color: color.greyText,
  },
  customDateValueContainer: {
    flex: 1,
    backgroundColor: 'transparent',
    flexDirection: 'row',
    alignItems: 'center',
    marginBottom: 1.5,
  },
  customDateValueLabel: {
    fontSize: 16,
    color: color.mainGreen,
    backgroundColor: 'transparent',
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

class AddPromoPageStep3 extends Component {
  constructor(props) {
    super(props)
    this.state = {
      isDateTimePickerVisible: false,
      isStartDate: false,
      isSelectingTime: false,
    }
  }
  componentDidUpdate = () => {
    if (this.props.isDonePost) {
      if (this.props.isMakeNewFromEdit) {
        Navigator.pop()
        this.props.changeIsNeedRefreshDashboard(true)
      } else if (this.props.isEdit) {
        Navigator.pop()
        this.props.resetAddPromoGroupRequestState()
        if (this.props.groupType === 3) {
          this.props.changeIsNeedRefreshDashboard(true)
        }
      } else {
        Navigator.dismiss()
        this.props.resetProgressAddPromo()
        this.props.changeIsNeedRefreshDashboard(true)
      }
    }
  }
  componentWillUnmount = () => {
    if (!this.props.isMakeNewFromEdit) {
      this.props.resetAddPromoGroupRequestState()
    }
  }
  showDateTimePicker = (isStartDate, isSelectingTime) =>
    this.setState({
      isDateTimePickerVisible: true,
      isStartDate,
      isSelectingTime,
    })
  hideDateTimePicker = () => this.setState({ isDateTimePickerVisible: false })
  handleDatePicked = (date, isStartDate) => {
    if (isStartDate) {
      const theEndDate =
        moment(date) > this.props.endDate ? moment(date) : this.props.endDate
      this.props.setScheduleAddPromo(moment(date), theEndDate)
    } else {
      this.props.setScheduleAddPromo(this.props.startDate, moment(date))
    }

    this.hideDateTimePicker()
  }
  cellSelected = index => {
    this.props.changeScheduleTypeAddPromo(index)
  }
  nextButtonTapped = () => {
    if (this.props.isEdit) {
      if (this.props.groupType == 2) {
        if (this.props.isMakeNewFromEdit) {
          TKPReactAnalytics.trackEvent({
            name: 'topadsios',
            category: 'ta - product',
            action: 'Click',
            label: `Edit Product Promo - Atur Grup Tanpa Grup`,
          })
        } else {
          TKPReactAnalytics.trackEvent({
            name: 'topadsios',
            category: 'ta - product',
            action: 'Click',
            label: `Edit Product Promo - Jadwal Tampil ${this.props
              .scheduleType === 0
              ? 'Otomatis'
              : 'Atur tanggal mulai dan berhenti'}`,
          })
        }
        this.props.patchProductPromo({
          status: this.props.status,
          adId: this.props.adId,
          groupId: this.props.isMakeNewFromEdit
            ? '0'
            : `${this.props.existingGroup.group_id}`,
          shopId: this.props.authInfo.shop_id,
          maxPrice: this.props.maxPrice,
          budgetType: this.props.budgetType,
          budgetPerDay: this.props.budgetPerDay,
          scheduleType: this.props.scheduleType,
          startDate: this.props.startDate,
          endDate: this.props.endDate,
        })
      } else if (this.props.groupType == 3) {
        this.props.patchProductPromo({
          status: this.props.status,
          adId: this.props.adId,
          groupId: this.props.isMakeNewFromEdit
            ? '0'
            : `${this.props.existingGroup.group_id}`,
          shopId: this.props.authInfo.shop_id,
          maxPrice: this.props.maxPrice,
          budgetType: this.props.budgetType,
          budgetPerDay: this.props.budgetPerDay,
          scheduleType: this.props.scheduleType,
          startDate: this.props.startDate,
          endDate: this.props.endDate,
        })
      } else {
        TKPReactAnalytics.trackEvent({
          name: 'topadsios',
          category: 'ta - product',
          action: 'Click',
          label: `Edit Group Promo - Jadwal Tampil ${this.props.scheduleType ===
          0
            ? 'Otomatis'
            : 'Atur tanggal mulai dan berhenti'}`,
        })
        this.props.patchGroupPromo({
          status: this.props.status,
          groupId: `${this.props.existingGroup.group_id}`,
          shopId: this.props.authInfo.shop_id,
          newGroupName: this.props.newGroupName,
          maxPrice: this.props.maxPrice,
          budgetType: this.props.budgetType,
          budgetPerDay: this.props.budgetPerDay,
          scheduleType: this.props.scheduleType,
          startDate: this.props.startDate,
          endDate: this.props.endDate,
        })
      }
    } else if (this.props.isCreateShop) {
      TKPReactAnalytics.trackEvent({
        name: 'topadsios',
        category: 'ta - shop',
        action: 'Click',
        label: `Add Shop Promo Show Time Step 2 - ${this.props.scheduleType ===
        0
          ? 'Otomatis'
          : 'Atur tanggal mulai dan berhenti'}`,
      })
      this.props.postAddPromo({
        shopId: this.props.authInfo.shop_id,
        groupId: '0',
        selectedProducts: [],
        maxPrice: this.props.maxPrice,
        scheduleType: this.props.scheduleType,
        startDate: this.props.startDate,
        endDate: this.props.endDate,
        budgetType: this.props.budgetType,
        budgetPerDay: this.props.budgetPerDay,
      })
    } else {
      TKPReactAnalytics.trackEvent({
        name: 'topadsios',
        category: 'ta - product',
        action: 'Click',
        label: `New Promo Step 3 - ${this.props.scheduleType === 0
          ? 'Otomatis'
          : 'Atur tanggal mulai dan berhenti'}`,
      })
      this.props.postAddPromoGroup({
        newGroupName: this.props.newGroupName,
        shopId: this.props.authInfo.shop_id,
        selectedProducts: this.props.selectedProducts,
        maxPrice: this.props.maxPrice,
        scheduleType: this.props.scheduleType,
        startDate: this.props.startDate,
        endDate: this.props.endDate,
        budgetType: this.props.budgetType,
        budgetPerDay: this.props.budgetPerDay,
      })
    }
  }
  renderProgressBar = () => (
    <View style={styles.progressBarContainer}>
      <View
        style={[
          styles.progressBarValueSide,
          { flex: this.props.stepCount - (this.props.stepCount - 3) },
        ]}
      />
      <View
        style={[
          styles.progressBarEmptySide,
          { flex: this.props.stepCount - 3 },
        ]}
      />
    </View>
  )
  renderCell = (title, index) => (
    <TouchableOpacity onPress={() => this.cellSelected(index)}>
      <View style={styles.cellContainer}>
        <View style={styles.cellChecklistContainer}>
          <View
            style={{
              height: 34,
              justifyContent: 'center',
              marginRight: 5,
            }}
          >
            {this.props.scheduleType === index ? (
              <Image style={styles.cellChecklistImageView} source={checkImg} />
            ) : (
              <View style={styles.cellChecklistView} />
            )}
          </View>
        </View>
        <Text style={{ fontSize: 16 }}>{title}</Text>
      </View>
    </TouchableOpacity>
  )
  renderDatePicker = isStartDate => {
    const englishStartDate = this.props.startDate
    const englishEndDate = this.props.endDate
    englishStartDate.locale('en')
    englishEndDate.locale('en')

    return (
      <View style={{ flexDirection: 'row' }}>
        <TouchableOpacity
          onPress={() => this.showDateTimePicker(isStartDate, false)}
          style={{
            marginRight: 30,
            flex: 1,
          }}
        >
          <View style={styles.customDateView}>
            <Text style={styles.customDateTitleLabel}>
              {isStartDate ? 'Mulai' : 'Selesai'}
            </Text>
            <View style={styles.customDateValueContainer}>
              <Text style={styles.customDateValueLabel}>
                {isStartDate ? (
                  this.props.startDate.format('D MMM YYYY')
                ) : (
                  this.props.endDate.format('D MMM YYYY')
                )}
              </Text>
              <Image
                style={styles.customDateValueArrow}
                source={arrowDownGreenImg}
              />
            </View>
            <View style={styles.customDateUnderline} />
          </View>
        </TouchableOpacity>
        <TouchableOpacity
          onPress={() => this.showDateTimePicker(isStartDate, true)}
          style={{ flex: 1 }}
        >
          <View style={styles.customDateView}>
            <View style={{ height: 15 }} />
            <View style={styles.customDateValueContainer}>
              <Text style={styles.customDateValueLabel}>
                {isStartDate ? (
                  englishStartDate.format('h:mm A')
                ) : (
                  englishEndDate.format('h:mm A')
                )}
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
  }
  render = () => {
    let navTitle = this.props.isEdit ? 'Jadwal' : '3 dari 3 step'
    navTitle = this.props.isCreateShop ? '2 dari 2 step' : navTitle
    return (
      <Navigator.Config title={navTitle}>
        <View style={{ flex: 1 }}>
          {!this.props.isEdit && this.renderProgressBar()}
          <TouchableWithoutFeedback onPress={Keyboard.dismiss}>
            <View style={styles.container}>
              {!this.props.isEdit ? (
                <Text style={styles.aboveLabel}>Jadwal Tampil</Text>
              ) : (
                <View style={{ height: 10 }} />
              )}
              <View style={styles.cellOuterContainer}>
                {this.renderCell('Tidak Dibatasi', 0)}
              </View>
              <View style={styles.cellOuterContainer}>
                {this.renderCell('Atur Tanggal Mulai dan Berhenti', 1)}
              </View>
              {this.props.scheduleType === 1 && (
                <View style={{ flex: 1 }}>
                  {this.renderDatePicker(true)}
                  {this.renderDatePicker(false)}
                </View>
              )}
            </View>
          </TouchableWithoutFeedback>
          {this.props.isLoadingPost ? (
            <View
              style={{
                height: 52,
                justifyContent: 'center',
                alignItems: 'center',
                position: 'absolute',
                bottom: 0,
                left: 0,
                right: 0,
              }}
            >
              <ActivityIndicator />
            </View>
          ) : (
            <BigGreenButton2
              title={this.props.isFailedPost ? 'Coba Lagi' : 'Simpan'}
              buttonAction={this.nextButtonTapped}
              disabled={false}
            />
          )}

          <DateTimePicker
            isVisible={this.state.isDateTimePickerVisible}
            onConfirm={date =>
              this.handleDatePicked(date, this.state.isStartDate)}
            onCancel={this.hideDateTimePicker}
            mode={this.state.isSelectingTime ? 'time' : 'date'}
            date={
              this.state.isStartDate ? (
                this.props.startDate.toDate()
              ) : (
                this.props.endDate.toDate()
              )
            }
            minimumDate={
              !this.state.isStartDate ? this.props.startDate.toDate() : null
            }
          />
        </View>
      </Navigator.Config>
    )
  }
}

export default connect(mapStateToProps, mapDispatchToProps)(AddPromoPageStep3)
