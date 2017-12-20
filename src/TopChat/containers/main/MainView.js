import React, { Component } from 'react'
import { View, StyleSheet, NetInfo } from 'react-native'
import ChatListContainers from './list/ChatListContainers'
import { Loading, StickyAlert } from '@TopChatComponents/'
import SearchBar from 'react-native-search-bar'
import Navigator from 'native-navigation'
import { TKPReactAnalytics, ReactInteractionHelper } from 'NativeModules'
import { Subject } from 'rxjs'

const styles = StyleSheet.create({
  container: {
    flex: 1,
  },
})

class MainView extends Component {
  constructor(props) {
    super(props)
    this.state = {
      isLoading: true,
      searchKeyword: '',
      showsCancelButton: false,
      overlay: false,
    }

    this.onSearch$ = new Subject()
    this.leftButtonParams = fromIpad => {
      if (fromIpad) {
        return {
          onLeftPress: () => ReactInteractionHelper.dismiss(() => {}),
          leftImage: {
            uri: 'icon_arrow_white',
            scale: 2,
          },
        }
      }
    }
  }

  componentWillMount() {
    this.props.connectToWebSocket(
      this.props.authInfo.device_token,
      this.props.authInfo.user_id,
    )

    this.connectionSubscriber = NetInfo.isConnected.addEventListener(
      'connectionChange',
      this.props.toggleConnectedNetwork,
    )
  }

  componentDidMount() {
    this.fetchInboxList(1, this.props.msgIdAppLink)

    this.onSearchSubscriber = this.onSearch$.throttleTime(1000).subscribe(v => {
      if (v.trim() === '' && v.length < 1) {
        this.props.resetSearchAllChat()
      } else if (v.trim() !== '') {
        const trackerParams = {
          name: 'ClickInboxChat',
          category: 'inbox-chat',
          action: 'click enter on search on chatlist',
          label: '',
        }
        TKPReactAnalytics.trackEvent(trackerParams)
        this.props.searchAllChat(v, 1)
      }
    })
  }

  componentWillReceiveProps(nextProps) {
    // if success get remote response
    if (nextProps.inboxList.success) {
      this.setState({
        isLoading: false,
      })
    } else if (nextProps.inboxList.message_error !== null) {
      // if the error messages is not null
      this.setState(
        {
          isLoading: false,
        },
        () => {
          const message_error = nextProps.inboxList.message_error
          ReactInteractionHelper.showErrorStickyAlertWithCallback(
            message_error,
            () => {
              this.setState(
                {
                  isLoading: true,
                },
                () => {
                  this.fetchInboxList(1, nextProps.msgIdAppLink)
                },
              )
            },
          )
        },
      )
    }
  }

  shouldComponentUpdate({ inboxList: { success }, connectedToInternet }) {
    // we wont this component re-render on first init of websocket (connectedInternet)
    if (success === null && connectedToInternet) {
      return false
    }

    return true
  }

  handleChangeText = text => {
    this.setState({
      searchKeyword: text,
    })
  }

  handleSearchButtonPress = () => this.onSearch$.next(this.state.searchKeyword)

  handleCancelButtonPress = () => {
    this.props.resetSearchAllChat()
  }

  handleBlur = () => {
    this.setState(prevState => ({
      showsCancelButton: prevState.searchKeyword !== '',
      overlay: false,
    }))
  }

  handleFocus = () => {
    this.setState({ showsCancelButton: true, overlay: true })
  }

  rightButtonParams = isOverlay => {
    let rightButton = {
      rightTitle: '',
      onRightPress: () => {},
    }

    // if overlay not showing and list of inbox is not null and not in search mode
    if (
      !isOverlay &&
      this.props.inboxList.data.list.length !== 0 &&
      this.state.searchKeyword === ''
    ) {
      rightButton = {
        rightTitle: this.props.inboxList.isEditing ? 'Selesai' : 'Atur',
        onRightPress: () =>
          this.handleRightBarButtonTapped(this.props.inboxList.isEditing),
      }
    }

    return rightButton
  }

  handleAppear = () => {
    TKPReactAnalytics.trackScreenName('inbox-chat')
  }

  componentWillUnmount() {
    this.onSearchSubscriber.unsubscribe()
    this.connectionSubscriber.remove()
    this.props.disconnectWebSocket(true)
    this.props.resetSearchAllChat()
    this.props.resetAllState()
  }

  fetchInboxList = (page = 1, msgIdAppLink = null) => {
    // all the params is snake case
    const parameters = {
      filter: 'all',
      page,
      msg_id_applink: msgIdAppLink,
      auth_info: this.props.authInfo,
      from_ipad: this.props.fromIpad,
    }
    this.props.fetchChatList(parameters)
  }

  handleRightBarButtonTapped(isEditing) {
    this.props.toggleEditMode(!isEditing)
  }

  render() {
    if (this.state.isLoading) {
      return <Loading />
    }

    return (
      <Navigator.Config
        onAppear={this.handleAppear}
        title={'Chat'}
        {...this.rightButtonParams(this.state.overlay)}
        {...this.leftButtonParams(this.props.fromIpad)}
      >
        <View style={styles.container}>
          <SearchBar
            ref="chatSearchBar"
            placeholder="Cari chat atau pengguna"
            backgroundColor="#f1f1f1"
            onChangeText={this.handleChangeText}
            onBlur={this.handleBlur}
            onFocus={this.handleFocus}
            onCancelButtonPress={this.handleCancelButtonPress}
            showsCancelButton={this.state.showsCancelButton}
            onSearchButtonPress={this.handleSearchButtonPress}
          />
          <ChatListContainers
            fromIpad={this.props.fromIpad}
            authInfo={this.props.authInfo}
            navigationBarHeight={this.props.nativeNavigationInitialBarHeight}
            fetchInboxList={this.fetchInboxList}
            chatSearchBar={this.refs.chatSearchBar}
            searchKeyword={this.state.searchKeyword}
            overlay={this.state.overlay}
          />
          <StickyAlert
            message={
              !this.props.connectedToInternet ? (
                'Terjadi gangguan pada koneksi'
              ) : (
                'Terhubung'
              )
            }
            show={!this.props.connectedToInternet}
            showLoading
            alertType={!this.props.connectedToInternet ? 'error' : 'success'}
            listenOnChangeProps
          />
        </View>
      </Navigator.Config>
    )
  }
}

MainView.defaultProps = {
  fromIpad: false,
  authInfo: {},
  nativeNavigationInitialBarHeight: 40,
  currentMsgId: null,
  msgIdAppLink: null,
}

export default MainView
