import React, { Component } from 'react'
import { StyleSheet, Text, View, DeviceEventEmitter } from 'react-native'

import Navigator from 'native-navigation'
import DeviceInfo from 'react-native-device-info'
import { bindActionCreators } from 'redux'
import { connect } from 'react-redux'
import { ReactInteractionHelper, ReactOnboardingHelper } from 'NativeModules'
import { TabViewAnimated, TabBar } from 'react-native-tab-view'
import PropTypes from 'prop-types'

import ReviewScreen from './ReviewScreen'
import * as Actions from '../Redux/Actions'

function mapStateToProps(state) {
  return {
    ...state.inboxReviewReducer,
  }
}

function mapDispatchToProps(dispatch) {
  return bindActionCreators(Actions, dispatch)
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    justifyContent: 'center',
  },
  tabLabel: {
    backgroundColor: 'transparent',
    color: 'rgb(66,181,73)',
    marginVertical: 8,
    alignSelf: 'center',
    marginHorizontal: 4,
  },
})

const onboardingTitle = [
  'Daftar Toko dan Produk untuk Diulas',
  'Riwayat Ulasan',
  'Ulasan dari Pembeli',
]
const onboardingMessage = [
  'Berikan penilaian toko dan ulasan pada produk yang Anda beli.',
  'Lihat seluruh penilaian dan ulasan yang telah Anda isi.',
  'Berikan penilaian dan balas ulasan pembeli.',
]

class InboxReview extends Component {
  constructor(props) {
    super(props)
    const routes = [
      { key: '1', title: 'Menunggu Ulasan' },
      { key: '2', title: 'Ulasan Saya' },
    ]

    if (this.props.authInfo.shop_id !== '0') {
      routes.push({ key: '3', title: 'Ulasan Pembeli' })
    }

    this.state = {
      refreshing: false,
      tabViewState: {
        index: 0,
        routes,
      },
    }

    this.width = 142
    this.windowWidth = 0
    this.onboardingState = -1

    this.tabReactTag = [0, 0, 0]
  }

  componentWillMount() {
    this.props.resetAllInvoice()
  }

  startOnboarding = () => {
    if (this.onboardingState > -1) {
      return
    }
    if (this.props.reputationId) {
      return
    }

    this.setState(
      {
        tabViewState: {
          ...this.state.tabViewState,
          index: 0,
        },
        onboardingState: 0,
      },
      () => {
        this.onboardingState = 0
        setTimeout(() => {
          this.showOnboarding(this.tabReactTag[0], 0)
        }, 100)
      },
    )
  }

  showOnboarding = (target, index) => {
    if (index !== this.onboardingState) {
      return
    }
    setTimeout(() => {
      ReactOnboardingHelper.showInboxOnboarding(
        {
          title: onboardingTitle[index],
          message: onboardingMessage[index],
          currentStep: index + 1,
          totalStep: this.props.authInfo.shop_id === '0' ? 2 : 3,
          anchor: target,
        },
        status => {
          switch (status) {
            case -1:
              // cancel
              this.props.enableOnboardingScroll()
              break
            case 0:
              // prev
              if (this.onboardingState > 0) {
                this.setState(
                  {
                    onboardingState: this.onboardingState - 1,
                    tabViewState: {
                      ...this.state.tabViewState,
                      index: this.onboardingState - 1,
                    },
                  },
                  () => {
                    setTimeout(() => {
                      this.onboardingState -= 1
                      this.showOnboarding(
                        this.tabReactTag[this.onboardingState],
                        this.onboardingState,
                      )
                    }, 200)
                  },
                )
              }
              break
            default:
              if (
                (this.onboardingState < 2 &&
                  this.props.authInfo.shop_id !== '0') ||
                (this.onboardingState < 1 &&
                  this.props.authInfo.shop_id === '0')
              ) {
                this.setState(
                  {
                    onboardingState: this.onboardingState + 1,
                    tabViewState: {
                      ...this.state.tabViewState,
                      index: this.onboardingState + 1,
                    },
                  },
                  () => {
                    setTimeout(() => {
                      this.onboardingState += 1
                      this.showOnboarding(
                        this.tabReactTag[this.onboardingState],
                        this.onboardingState,
                      )
                    }, 200)
                  },
                )
              } else if (
                (this.onboardingState === 2 &&
                  this.props.authInfo.shop_id !== '0') ||
                (this.onboardingState === 1 &&
                  this.props.authInfo.shop_id === '0')
              ) {
                this.props.enableOnboardingScroll()
                ReactOnboardingHelper.disableOnboarding(
                  'inbox_onboarding',
                  `${this.props.authInfo.user_id}`,
                )
              }
              break
          }
        },
      )
    }, 100)
  }

  handleIndexChange = index => {
    if (DeviceInfo.isTablet()) {
      this.props.changeInvoicePage(index)
      DeviceEventEmitter.emit('SET_INVOICE')
    }
  }

  handleLayout = event => {
    if (this.windowWidth > 0) {
      return
    }
    const divisor = this.props.authInfo.shop_id === '0' ? 2 : 3
    this.width = event.nativeEvent.layout.width / divisor
    if (this.width < 142) {
      this.width = 142
    }
    this.windowWidth = event.nativeEvent.layout.width
    this.setState({
      tabViewState: { ...this.state.tabViewState, index: 0 },
    })
  }

  renderLabel = scene => (
    <Text
      style={[
        styles.tabLabel,
        scene.focused === 1 ? {} : { color: 'rgba(0,0,0,0.38)', zIndex: 500 },
      ]}
      numberOfLines={1}
    >
      {scene.route.title}
    </Text>
  )

  renderDummy = item => (
    <View
      style={{
        width: this.width,
        height: 49,
        position: 'absolute',
        left: 0,
        top: 0,
        opacity: 0,
      }}
      onLayout={event => {
        this.tabReactTag[item.index] = event.target
        if (item.index === 0) {
          ReactOnboardingHelper.getOnboardingStatus(
            'inbox_onboarding',
            `${this.props.authInfo.user_id}`,
            isOnboardingShown => {
              if (!isOnboardingShown) {
                this.props.disableOnboardingScroll()
                this.startOnboarding()
              }
            },
          )
        }
      }}
    />
  )

  renderHeader = props => (
    <TabBar
      onTabPress={item => {
        if (item.index === this.state.tabViewState.index) {
          return
        }
        if (!this.props.isOnboardingScrollEnabled) {
          return
        }
        this.setState({
          tabViewState: { ...this.state.tabViewState, index: item.index },
        })
        if (DeviceInfo.isTablet()) {
          this.props.changeInvoicePage(item.index)
          DeviceEventEmitter.emit('SET_INVOICE')
        }
      }}
      renderIcon={this.renderDummy}
      scrollEnabled
      renderLabel={this.renderLabel}
      indicatorStyle={{
        backgroundColor: 'rgb(66,181,73)',
        height: 3,
      }}
      style={{
        backgroundColor: 'white',
        shadowOffset: { height: 2, width: 0 },
        shadowColor: 'black',
        shadowOpacity: 0.2,
        shadowRadius: 6,
      }}
      tabStyle={{
        width: this.width,
      }}
      render
      {...props}
    />
  )

  renderScene = ({ route }) => {
    switch (route.key) {
      case '1':
        return (
          <ReviewScreen
            role={1}
            status={1}
            pageIndex={0}
            authInfo={this.props.authInfo}
          />
        )
      case '2':
        return (
          <ReviewScreen
            role={1}
            status={2}
            pageIndex={1}
            authInfo={this.props.authInfo}
          />
        )
      case '3':
        return (
          <ReviewScreen
            role={2}
            status={3}
            pageIndex={2}
            authInfo={this.props.authInfo}
          />
        )
      default:
        return <ReviewScreen />
    }
  }

  render() {
    let leftImage = null
    if (DeviceInfo.isTablet()) {
      leftImage = {
        uri: 'icon_arrow_white',
        scale: 2,
      }
    }
    return (
      <Navigator.Config
        title="Ulasan"
        leftImage={leftImage}
        onLeftPress={() => {
          if (this.props.isInteractionBlocked) {
            return
          }
          ReactInteractionHelper.dismiss(() => {})
        }}
      >
        <View style={{ flex: 1 }} onLayout={this.handleLayout}>
          <TabViewAnimated
            lazy
            style={styles.container}
            swipeEnabled={this.props.isOnboardingScrollEnabled}
            navigationState={this.state.tabViewState}
            renderScene={this.renderScene}
            renderHeader={this.renderHeader}
            onIndexChange={this.handleIndexChange}
          />
        </View>
      </Navigator.Config>
    )
  }
}

InboxReview.propTypes = {
  authInfo: PropTypes.object.isRequired,
  resetInvoice: PropTypes.func.isRequired,
  changeInvoicePage: PropTypes.func.isRequired,
  isInteractionBlocked: PropTypes.bool.isRequired,
  resetAllInvoice: PropTypes.func.isRequired,
}

export default connect(mapStateToProps, mapDispatchToProps)(InboxReview)
