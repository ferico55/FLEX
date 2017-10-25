import Navigator from 'native-navigation'
import DeviceInfo from 'react-native-device-info'
import { TKPReactAnalytics } from 'NativeModules'
import React, { Component } from 'react'
import { bindActionCreators } from 'redux'
import { connect } from 'react-redux'
import {
  StyleSheet,
  Text,
  View,
  TouchableOpacity,
  ScrollView,
  Dimensions,
} from 'react-native'

import DateSettingsButton from '../Components/DateSettingsButton'
import StatisticChart from '../Components/StatisticChart'
import color from '../Helper/Color'

import * as Actions from '../Redux/Actions/StatDetailActions'

const { width } = Dimensions.get('window')
let totalContentWidth = 0
const tabTracker = [
  'Impression',
  'Click',
  'CTR',
  'Conversion',
  'Average Conversion',
  'CPC',
]
const tabMenus = [
  'Tampil',
  'Klik',
  'Persentase Klik',
  'Konversi',
  'Rata-Rata',
  'Terpakai',
]
const selectedComponentRefArray = [
  'tab0',
  'tab1',
  'tab2',
  'tab3',
  'tab4',
  'tab5',
]

function mapStateToProps(state) {
  return {
    ...state.statDetailReducer,
  }
}

function mapDispatchToProps(dispatch) {
  return bindActionCreators(Actions, dispatch)
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: color.backgroundGrey,
  },
  defaultView: {
    flex: 1,
  },
  separator: {
    height: 1,
    backgroundColor: color.lineGrey,
  },
  aboveTabBarContainer: {
    height: 45,
    flexDirection: 'row',
    backgroundColor: 'white',
  },
  aboveTabTitleLabel: {
    color: color.mainGreen,
    fontSize: 14,
    fontWeight: '500',
  },
  aboveTabTextContainer: {
    flex: 9,
    alignItems: 'center',
    justifyContent: 'center',
  },
  aboveTabBottomStripOn: {
    height: 3,
    backgroundColor: color.mainGreen,
  },
})

class StatDetailPage extends Component {
  constructor(props) {
    super(props)
    this.state = {
      isCenterTab: false,
      tabBarOffset: 0,
    }
  }
  componentDidMount = () => {
    if (width >= 640) {
      this.setState({
        isCenterTab: true,
      })
    }
  }
  onAppear = () => {
    this.adjustTabBarScrollPosition(this.props.selectedTabIndex)
    if (this.props.isNeedRefresh) {
      this.refreshData()
    }
  }
  refreshData = () => {
    this.props.getStatDetailStatistic({
      shopId: this.props.authInfo.shop_id,
      type: this.props.promoType,
      startDate: this.props.startDate.format('YYYY-MM-DD'),
      endDate: this.props.endDate.format('YYYY-MM-DD'),
    })
  }
  tabBarTapped = index => {
    TKPReactAnalytics.trackEvent({
      name: 'topadsios',
      category: this.props.promoType === 2 ? 'ta- shop' : 'ta - product',
      action: 'Click',
      label: `Statistic Bar - ${tabTracker[index]}`,
    })
    this.props.changeStatDetailTab(index)
    this.adjustTabBarScrollPosition(index)
  }
  adjustTabBarScrollPosition = index => {
    if (index > this.props.selectedTabIndex) {
      if (totalContentWidth <= 0) {
        for (let i = 0; i < 6; i++) {
          this.refs[
            `${selectedComponentRefArray[i]}`
          ].measure((fx, fy, compWidth, compHeight, px, py) => {
            totalContentWidth += compWidth
          })
        }
      }

      this.refs[
        `${selectedComponentRefArray[index]}`
      ].measure((fx, fy, compWidth, compHeight, px, py) => {
        const maxScrollOffset = totalContentWidth - width
        const scrolToPosition = fx - 50
        this.refs.scrollView.scrollTo({
          x:
            scrolToPosition <= maxScrollOffset
              ? scrolToPosition
              : maxScrollOffset,
          y: 0,
          animated: true,
        })
      })
    } else {
      this.refs[
        `${selectedComponentRefArray[index]}`
      ].measure((fx, fy, compWidth, compHeight, px, py) => {
        const scrolToPosition = fx - width + compWidth + 50
        this.refs.scrollView.scrollTo({
          x: scrolToPosition > 0 ? scrolToPosition : 0,
          y: 0,
          animated: true,
        })
      })
    }
  }
  renderTabBar = () => {
    return (
      <View style={styles.aboveTabBarContainer}>
        <ScrollView
          ref="scrollView"
          horizontal
          centerContent={this.state.isCenterTab}
          showsHorizontalScrollIndicator={false}
          contentOffset={{ x: this.state.tabBarOffset, y: 0 }}
        >
          {tabMenus.map((item, index) => (
            <TouchableOpacity
              ref={`tab${index}`}
              onPress={() => this.tabBarTapped(index)}
              key={index}
            >
              <View>
                <View style={{ height: 42, paddingHorizontal: 20 }}>
                  <View style={styles.aboveTabTextContainer}>
                    <Text style={styles.aboveTabTitleLabel}>{item}</Text>
                  </View>
                </View>
                <View
                  style={
                    this.props.selectedTabIndex == index ? (
                      styles.aboveTabBottomStripOn
                    ) : (
                      {}
                    )
                  }
                />
              </View>
            </TouchableOpacity>
          ))}
        </ScrollView>
      </View>
    )
  }
  render() {
    const isScrollable =
      DeviceInfo.getModel() == 'iPhone 5' ||
      DeviceInfo.getModel() == 'iPhone 5s' ||
      DeviceInfo.getModel() == 'iPhone 4' ||
      DeviceInfo.getModel() == 'iPhone 5s' ||
      DeviceInfo.getModel() == 'iPod Touch'
    return (
      <Navigator.Config title={'Statistik'} onAppear={this.onAppear}>
        <View style={styles.container}>
          {this.renderTabBar()}
          <DateSettingsButton
            currentDateRange={{
              startDate: this.props.startDate,
              endDate: this.props.endDate,
            }}
            buttonTapped={this.dateButtonTapped}
          />
          <ScrollView scrollEnabled={isScrollable}>
            <StatisticChart
              dataSource={this.props.dataSource}
              selectedTabIndex={this.props.selectedTabIndex}
              isLoading={this.props.isLoading}
            />
          </ScrollView>
        </View>
      </Navigator.Config>
    )
  }

  dateButtonTapped = () => {
    Navigator.push('DateSettingsPage', {
      changeDateActionId: 'CHANGE_DATE_RANGE_STATDETAIL',
      trackerFromStatisticPage: true,
    })
  }
}

export default connect(mapStateToProps, mapDispatchToProps)(StatDetailPage)
