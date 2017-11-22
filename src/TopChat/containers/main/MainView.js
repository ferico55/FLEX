import React, { Component } from 'react'
import { View, StyleSheet, NetInfo } from 'react-native'
import PropTypes from 'prop-types'
import ChatListContainers from './list/ChatListContainers'
import { Loading, StickyAlert } from '@components/'
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
      this.handleFirstConnectivityChange,
    )
  }

  componentDidMount() {
    this.fetchInboxList(1, this.props.msg_id_applink)

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

  handleFirstConnectivityChange = isConnected => {
    this.props.toggleConnectedNetwork(isConnected)
  }

  shouldComponentUpdate({ inboxList: { success }, webSocket }) {
    // we wont this component re-render on first init of websocket
    if (success === null && webSocket) {
      return false
    }

    return true
  }

  componentWillReceiveProps(nextProps) {
    if (nextProps.inboxList.success) {
      this.setState({
        isLoading: false,
      })
    } else if (nextProps.inboxList.message_error !== null) {
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
                  this.fetchInboxList(1, nextProps.msg_id_applink)
                },
              )
            },
          )
        },
      )
    }
  }

  onRightBarButtonTapped(isEditing) {
    this.props.toggleEditMode(!isEditing)
  }

  fetchInboxList = (page = 1, msg_id_applink = null) => {
    this.props.fetchChatList(
      'all',
      page,
      msg_id_applink,
      this.props.authInfo,
      this.props.fromIpad,
    )
  }

  fetchArchiveList = (page = 1) => {
    // In this version, this will not be released yet
    // this.props.fetchArchiveChatList('all', page)
  }

  onChangeText = text => {
    this.setState({
      searchKeyword: text,
    })
  }

  onSearchButtonPress = () => this.onSearch$.next(this.state.searchKeyword)

  onCancelButtonPress = () => {
    this.props.resetSearchAllChat()
  }

  onBlur = () => {
    this.setState(prevState => ({
      showsCancelButton: prevState.searchKeyword !== '',
      overlay: false,
    }))
  }

  onFocus = () => {
    this.setState({ showsCancelButton: true, overlay: true })
  }

  rightButonParams = isOverlay => {
    let rightButton = {
      rightTitle: '',
      onRightPress: () => {},
    }

    if (!isOverlay && this.props.inboxList.data.list.length !== 0) {
      rightButton = {
        rightTitle: this.props.inboxList.isEditing ? 'Selesai' : 'Atur',
        onRightPress: () =>
          this.onRightBarButtonTapped(this.props.inboxList.isEditing),
      }
    }

    return rightButton
  }

  onAppear = () => {
    TKPReactAnalytics.trackScreenName('inbox-chat')
  }

  componentWillUnmount() {
    this.onSearchSubscriber.unsubscribe()
    this.connectionSubscriber.remove()
    this.props.disconnectWebSocket(true)
    this.props.resetSearchAllChat()
    this.props.resetAllState()
  }

  render() {
    if (this.state.isLoading) {
      return <Loading />
    }

    return (
      <Navigator.Config
        onAppear={this.onAppear}
        title={'Chat'}
        {...this.rightButonParams(this.state.overlay)}
        {...this.leftButtonParams(this.props.fromIpad)}
      >
        <View style={styles.container}>
          <SearchBar
            ref="chatSearchBar"
            placeholder="Cari chat atau pengguna"
            backgroundColor="#f1f1f1"
            onChangeText={this.onChangeText}
            onBlur={this.onBlur}
            onFocus={this.onFocus}
            onCancelButtonPress={this.onCancelButtonPress}
            showsCancelButton={this.state.showsCancelButton}
            onSearchButtonPress={this.onSearchButtonPress}
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
            msg={
              !this.props.webSocket ? (
                'Terjadi gangguan pada koneksi'
              ) : (
                'Terhubung'
              )
            }
            show={!this.props.webSocket}
            showLoading
            alertType={!this.props.webSocket ? 'error' : 'success'}
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
  msg_id_applink: null,
}

export default MainView
