import React, { Component } from 'react'
import { StyleSheet, Text, View } from 'react-native'

import Navigator from 'native-navigation'
import DeviceInfo from 'react-native-device-info'
import { bindActionCreators } from 'redux'
import { connect } from 'react-redux'
import { ReactInteractionHelper, ReactOnboardingHelper } from 'NativeModules'
import { TabViewAnimated, TabBar } from 'react-native-tab-view'
import ReviewPage from './ReviewPage'
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
  tabContainer: {
    backgroundColor: 'white',
    shadowColor: 'black',
    shadowOffset: { width: 0, height: 2 },
    shadowOpacity: 0.15,
    shadowRadius: 6,
  },
})

const onboardingTitle = [
  'Daftar Toko dan Produk untuk Diulas',
  'Riwayat Ulasan',
  'Ulasan dari Pembeli',
]
const onboardingMessage = [
  'Berikan penilaian toko dan ulasan pada produk yang Anda beli.',
  'Berikan penilaian toko dan ulasan pada produk yang Anda beli.',
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
    this.props.resetInvoice()
  }

  startOnboarding = () => {
    if (this.onboardingState > -1) {
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
                ReactOnboardingHelper.disableOnboarding(
                  'review_inbox_onboarding',
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
    this.props.changeInvoicePage(index)
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
            'review_inbox_onboarding',
            `${this.props.authInfo.user_id}`,
            isOnboardingShown => {
              if (!isOnboardingShown) {
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
        this.setState({
          tabViewState: { ...this.state.tabViewState, index: item.index },
        })
        this.props.changeInvoicePage(item.index)
      }}
      renderIcon={this.renderDummy}
      scrollEnabled
      renderLabel={this.renderLabel}
      indicatorStyle={{
        backgroundColor: 'rgb(66,181,73)',
        height: 3,
      }}
      style={{ backgroundColor: 'white' }}
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
          <ReviewPage
            role={1}
            status={1}
            pageIndex={0}
            authInfo={this.props.authInfo}
          />
        )
      case '2':
        return (
          <ReviewPage
            role={1}
            status={2}
            pageIndex={1}
            authInfo={this.props.authInfo}
          />
        )
      case '3':
        return (
          <ReviewPage
            role={2}
            status={3}
            pageIndex={2}
            authInfo={this.props.authInfo}
          />
        )
      default:
        return <ReviewPage />
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

export default connect(mapStateToProps, mapDispatchToProps)(InboxReview)
