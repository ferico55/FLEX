/* @flow */

import React, { Component } from 'react'
import {
  View,
  Text,
  StyleSheet,
  Dimensions,
  ActivityIndicator,
  Image,
} from 'react-native'
import Navigator from 'native-navigation'
import { Subject } from 'rxjs'
import _ from 'lodash'
import {
  MessageContainer,
  Loading,
  StickyAlert,
  EmptyState,
} from '@components/'
import types from '@redux/web_socket/Actions'
import { getOnlineStatus } from '@helpers/Requests'
import { getTimeFromNow } from '@helpers/TimeConverters'
import {
  TKPReactAnalytics,
  ReactTPRoutes,
  TKPReactURLManager,
} from 'NativeModules'

import topChatWelcome from '@img/topChatWelcome.png'
import historyIcon from '@img/historyIcon.png'

const { IS_TYPING_CODE, END_TYPING_CODE } = types
const { height } = Dimensions.get('window')
const WINDOW_HEIGHT = height

const styles = StyleSheet.create({
  container: {
    flex: 1,
  },
  timeMachineText: {
    fontSize: 11,
    color: 'rgba(0, 0, 0, 0.54)',
    lineHeight: 16,
  },
  timeMachineButton: {
    fontWeight: '500',
    color: '#42b549',
  },
})

class DetailView extends Component {
  constructor(props) {
    super(props)
    this.state = {
      isLoading: true,
      isError: false,
      messageText: '',
      ipadInitial: true,
      isOnline: '',
      showHistoryOnTop: false,
    }

    const {
      shop_id,
      attributes: { contact: { id, role, attributes: { domain, name } } },
    } = props
    const is_seller = role === 'shop'
    this.page = 1
    this.onKeyFirstChange$ = new Subject()
    this.onPressSend$ = new Subject()
    this.onPressUrl$ = new Subject()
    this.refSectionList = null
    this.role = null
    this.title = name
    this.onlineStatusParams = {
      type: is_seller ? 'shop' : 'user',
      id,
    }
    this.shopParams = {
      shop_id: is_seller ? id : shop_id,
      shop_domain: is_seller ? domain : '',
    }
  }

  setOnlineStatus = () => {
    if (this.props.messages.current_msg_id !== null) {
      getOnlineStatus(this.onlineStatusParams)
        .then(({ data: { is_online, timestamp } }) => {
          if (!is_online) {
            this.setState({
              isOnline: `Terakhir online ${getTimeFromNow(timestamp)}`,
            })
          } else {
            this.setState({
              isOnline: 'Online',
            })
          }
        })
        .catch(err => {
          console.log(err)
        })
    }
  }

  componentWillMount() {
    this.onPressSubscribtion = this.onPressUrl$
      .throttleTime(500)
      .subscribe(url => ReactTPRoutes.navigate(url))

    this.onKeyFirstChangeSubcription = this.onKeyFirstChange$
      .do(() => {
        this.props.sendTyping(
          this.props.messages.current_msg_id,
          IS_TYPING_CODE,
        )
      })
      .debounceTime(1000)
      .subscribe(() =>
        this.props.sendTyping(
          this.props.messages.current_msg_id,
          END_TYPING_CODE,
        ),
      )

    this.onPressSendSubcription = this.onPressSend$
      .filter(({ message }) => message.trim() !== '')
      .do(() => {
        const params = {
          animated: true,
          itemIndex: 0,
          sectionIndex: 0,
          viewOffset: 0,
        }
        this.sectionList.scrollToLocation(params)
      })
      .subscribe(data => {
        const trackerParams = {
          name: 'ClickChatDetail',
          category: 'chat detail',
          action: 'click on send button',
          label: '',
        }
        TKPReactAnalytics.trackEvent(trackerParams)
        this.props.sendMessage(data)
      })

    if (!this.props.fromIpad && this.props.searchKeyword === null) {
      this.props.fetchReplyList(this.props.msg_id, this.page)
    } else if (!this.props.fromIpad && this.props.searchKeyword !== null) {
      this.props.fetchReplyListForSearch(
        this.props.msg_id,
        this.props.reply_id,
        this.props.section,
        this.props.searchKeyword,
      )
    }
  }

  componentDidMount() {
    TKPReactAnalytics.trackScreenName('chat detail')
  }

  componentWillReceiveProps(nextProps) {
    // we do a lot of comparasion for make sure that we only setState for once
    if (
      nextProps.chatDetail.success &&
      !nextProps.chatDetail.loading &&
      nextProps.messages.current_msg_id === null
    ) {
      if (this.role === null) {
        this.role = _.find(nextProps.chatDetail.data.contacts, [
          'user_id',
          parseInt(nextProps.user_id),
        ]).role
      }

      this.setState({
        isLoading: false,
        isError: false,
        ipadInitial: false,
      })
    } else if (!nextProps.chatDetail.success && !nextProps.chatDetail.loading) {
      // meanwhile this one is error phase
      this.setState({
        isLoading: false,
        isError: true,
        ipadInitial: this.props.fromIpad, // only for ipad purposes
      })
    }

    if (nextProps.fromIpad && nextProps.chatDetail.ipadAttributes.is_set) {
      const {
        shop_id,
        attributes: { contact: { id, role, attributes: { domain, name } } },
      } = nextProps.chatDetail.ipadAttributes
      const is_seller = role === 'shop'
      this.title = name
      this.onlineStatusParams = {
        type: is_seller ? 'shop' : 'user',
        id,
      }
      this.shopParams = {
        shop_id: is_seller ? id : shop_id,
        shop_domain: is_seller ? domain : '',
      }
    }
  }

  loadPage = page => {
    this.props.fetchReplyList(this.props.messages.current_msg_id, page)
  }

  onContentSizeChange = (contentHeight, chatWindowHeight) => {
    // 50 is height of renderShowHistory() component
    if (contentHeight < chatWindowHeight - 50) {
      // this approach is made to avoiding redudant re-render
      if (!this.state.showHistoryOnTop) {
        this.setState({
          showHistoryOnTop: true,
        })
      }
    } else {
      // this approach is made to avoiding redudant re-render on ipad
      if (this.state.showHistoryOnTop) {
        this.setState({
          showHistoryOnTop: false,
        })
      }
    }
  }

  loadingIndicator = () => {
    // if not from search, and next paging is false, and not show history on top
    if (
      !this.props.chatDetail.data.paging_next &&
      this.props.chatDetail.searchKeyword === null &&
      !this.state.showHistoryOnTop
    ) {
      return this.renderShowHistory(false)
    } else if (
      this.props.chatDetail.searchKeyword !== null &&
      !this.props.chatDetail.data.showLoadingPrev
    ) {
      return null
    } else if (this.state.showHistoryOnTop) {
      return null
    }

    return (
      <View style={{ marginVertical: 50 }}>
        <ActivityIndicator size={'small'} animating />
      </View>
    )
  }

  onScroll = ({
    nativeEvent: { contentOffset: { y }, contentSize: { height } },
  }) => {
    const {
      mergeReplyList,
      chatDetail: { loading, data, searchKeyword },
    } = this.props

    if (WINDOW_HEIGHT + y >= height) {
      if (!loading && searchKeyword === null) {
        if (data.paging_next) {
          this.page += 1
          this.loadPage(this.page)
        }
      } else if (!loading) {
        const { prevPage, cacheList } = data
        if (prevPage !== false) {
          mergeReplyList(cacheList, prevPage, false)
        }
      }
    } else if (
      y < 0 &&
      searchKeyword !== null &&
      data.originIndex > 0 &&
      typeof data.nextPage !== 'boolean' &&
      !loading
    ) {
      const { nextPage, cacheList } = data
      mergeReplyList(cacheList, nextPage)
    }
  }

  onChangeText = () => {
    this.onKeyFirstChange$.next()
  }

  onPressSend = (message, sectionList) => {
    this.sectionList = sectionList
    const { user_id, full_name, messages: { current_msg_id } } = this.props
    const data = {
      message_id: current_msg_id,
      message,
      sender_name: full_name,
      sender_id: parseInt(user_id, 10),
      role: this.role,
    }

    this.onPressSend$.next(data)
  }

  onPressAttachment = sectionList => {
    this.sectionList = sectionList
    const sendChatAttr = {
      message_id: this.props.messages.current_msg_id,
      sender_name: this.props.full_name,
      sender_id: parseInt(this.props.user_id, 10),
      role: this.role,
    }

    const trackerParams = {
      name: 'ClickChatDetail',
      category: 'chat detail',
      action: 'click on insert button',
      label: '',
    }

    TKPReactAnalytics.trackEvent(trackerParams)

    Navigator.present(
      'ProductAttachTopChat',
      {
        params: this.shopParams,
        sendChatAttr,
        fromIpad: this.props.fromIpad,
      },
      {
        modalPresentationStyle: this.props.fromIpad ? 'formSheet' : 'fullScreen',
      },
    ).then(() => {
      this.sectionList.scrollToLocation({
        animated: true,
        itemIndex: 0,
        sectionIndex: 0,
        viewOffset: 0,
      })
    })
  }

  handleOpenTimeMachine = () => {
    this.onPressUrl$.next(
      `${TKPReactURLManager.mobileSiteUrl}/inbox-message-old.pl`,
    )
  }

  renderShowHistory = (showAbsolute = true) => {
    const historyMsg = `Untuk melihat percakapan sebelumnya,kunjungi\n`

    if (!showAbsolute) {
      return (
        <View
          style={{
            height: 50,
            backgroundColor: 'rgb(251,251,251)',
            justifyContent: 'center',
          }}
        >
          <View
            style={{
              flexDirection: 'row',
              padding: 15,
            }}
          >
            <View style={{ justifyContent: 'center' }}>
              <Image
                source={historyIcon}
                style={{ width: 22, height: 24 }}
                resizeMode={'contain'}
              />
            </View>
            <View style={{ paddingHorizontal: 15 }}>
              <Text style={styles.timeMachineText}>
                {historyMsg}
                <Text
                  style={styles.timeMachineButton}
                  onPress={this.handleOpenTimeMachine}
                >
                  Riwayat Pesan
                </Text>
              </Text>
            </View>
          </View>
        </View>
      )
    }

    return (
      <View
        style={{
          position: 'absolute',
          top: 0,
          left: 0,
          right: 0,
          height: 50,
          backgroundColor: 'rgb(251,251,251)',
          justifyContent: 'center',
        }}
      >
        <View
          style={{
            flexDirection: 'row',
            padding: 15,
          }}
        >
          <View style={{ justifyContent: 'center' }}>
            <Image
              source={historyIcon}
              style={{ width: 22, height: 24 }}
              resizeMode={'contain'}
            />
          </View>
          <View style={{ paddingHorizontal: 15 }}>
            <Text style={styles.timeMachineText}>
              {historyMsg}
              <Text
                style={styles.timeMachineButton}
                onPress={this.handleOpenTimeMachine}
              >
                Riwayat Pesan
              </Text>
            </Text>
          </View>
        </View>
      </View>
    )
  }

  componentWillUnmount() {
    this.onPressSubscribtion.unsubscribe()
    this.onKeyFirstChangeSubcription.unsubscribe()
    this.onPressSendSubcription.unsubscribe()
    this.props.unsetMsgId()
  }

  onUrlPress = url => {
    this.onPressUrl$.next(url)
  }

  navigationBarParams = () => {
    const navbarParams = {
      title: this.title,
      titleColor: 'rgba(0,0,0,0.7)',
    }

    // will be use on next version
    // if (this.props.chatDetail.data.textarea_reply) {
    //   navbarParams = {
    //     ...navbarParams,
    //     subtitle: this.state.isOnline,
    //     subtitleColor: 'rgba(0,0,0,0.38)',
    //   }
    // }

    return navbarParams
  }

  render() {
    // initial load from iphone device
    if (this.state.isLoading) {
      return (
        <Navigator.Config {...this.navigationBarParams()} hidden={false}>
          <Loading />
        </Navigator.Config>
      )
    }

    // this load only appear on ipad
    if (
      this.props.fromIpad &&
      this.props.messages.current_msg_id === null &&
      this.props.chatDetail.loading
    ) {
      return (
        <Navigator.Config {...this.navigationBarParams()} hidden={false}>
          <Loading />
        </Navigator.Config>
      )
    }

    if (this.state.ipadInitial && this.props.fromIpad) {
      if (this.props.listInboxEmpty === null) {
        return (
          <Navigator.Config hidden>
            <Loading />
          </Navigator.Config>
        )
      }

      return (
        <Navigator.Config hidden>
          {this.props.listInboxEmpty ? (
            <EmptyState handleOpenTimeMachine={this.handleOpenTimeMachine} />
          ) : (
            <View
              style={{
                flex: 1,
                alignItems: 'center',
                justifyContent: 'center',
              }}
            >
              <Image
                source={topChatWelcome}
                style={{ width: 160, height: 98 }}
                resizeMode={'contain'}
              />
              <Text
                style={{
                  marginTop: 10,
                  marginBottom: 5,
                  fontSize: 16,
                  color: 'rgba(0,0,0,0.7)',
                  fontWeight: 'bold',
                }}
              >
                Selamat Datang di Chat
              </Text>
              <Text
                style={{
                  fontSize: 14,
                  color: 'rgba(0,0,0,0.5)',
                  fontWeight: '500',
                  lineHeight: 22,
                }}
              >
                Silakan memilih chat untuk memulai percakapan
              </Text>
            </View>
          )}
        </Navigator.Config>
      )
    }

    return (
      <Navigator.Config {...this.navigationBarParams()} hidden={false}>
        <View style={styles.container}>
          <MessageContainer
            loadingIndicator={this.loadingIndicator}
            onScroll={this.onScroll}
            onChangeText={this.onChangeText}
            onPressSend={this.onPressSend}
            onPressAttachment={this.onPressAttachment}
            messageText={this.state.messageText}
            data={this.props.chatDetail.data}
            messages={this.props.messages}
            userId={parseInt(this.props.user_id, 10)}
            replyId={this.props.replyId}
            searchKeyword={this.props.chatDetail.searchKeyword}
            resetScrollParams={this.props.resetScrollParams}
            connectedToWS={this.props.webSocket.connectedToInternet}
            onContentSizeChange={this.onContentSizeChange}
            onUrlPress={this.onUrlPress}
            setOnlineStatus={this.setOnlineStatus}
          />
          {this.state.showHistoryOnTop ? this.renderShowHistory() : null}
          <StickyAlert
            msg={
              !this.props.webSocket.connectedToInternet ? (
                'Terjadi gangguan pada koneksi'
              ) : (
                'Terhubung'
              )
            }
            show={
              !this.props.webSocket.connectedToInternet && !this.props.fromIpad
            }
            alertType={
              !this.props.webSocket.connectedToInternet ? 'error' : 'success'
            }
            listenOnChangeProps
          />
        </View>
      </Navigator.Config>
    )
  }
}

DetailView.defaultProps = {
  fromIpad: false,
  fromSearch: false,
  statusBarHeight: 0,
  reply_id: null,
  section: null,
  searchKeyword: null,
  shop_id: 0,
  attributes: {
    contact: {
      id: 0,
      role: '',
      attributes: {
        domain: '',
        name: '',
      },
    },
  },
}

export default DetailView
