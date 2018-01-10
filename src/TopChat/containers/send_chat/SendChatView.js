import React, { Component } from 'react'
import {
  Text,
  View,
  StyleSheet,
  Image,
  TextInput,
  TouchableOpacity,
  KeyboardAvoidingView,
} from 'react-native'
import {
  TKPReactAnalytics,
  TKPReactURLManager,
  ReactNetworkManager,
  ReactInteractionHelper,
  ReactUserManager,
} from 'NativeModules'
import Navigator from 'native-navigation'
import { Subject } from 'rxjs'
import { Loading } from '@TopChat/components'
import sendButton from '@img/sendButton.png'
import ChatTemplate from '@TopChat/containers/chat_template/ChatTemplateContainers'

const styles = StyleSheet.create({
  main: {
    flexDirection: 'column',
    flex: 1,
    backgroundColor: 'rgb(248, 248, 248)',
    justifyContent: 'space-between',
  },
  container: {
    flexDirection: 'column',
    borderTopWidth: 1,
    borderTopColor: 'rgba(224, 224, 224, 0.7)',
    backgroundColor: 'rgb(255,255,255)',
  },
  attachmentView: {
    justifyContent: 'center',
  },
  composerView: {
    flexDirection: 'row',
    maxHeight: 100,
  },
  attachmentTitle: {
    fontSize: 12,
    color: 'rgba(0, 0, 0, 0.54)',
    lineHeight: 20,
    marginTop: 16,
    marginLeft: 20,
  },
  attachmentURL: {
    fontSize: 14,
    color: 'rgba(0, 0, 0, 0.7)',
    lineHeight: 20,
    marginLeft: 20,
    marginRight: 20,
    marginBottom: 16,
  },
  textView: {
    marginLeft: 20,
    marginTop: 16,
    marginBottom: 16,
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
    fontSize: 14,
    paddingBottom: 4,
    minHeight: 20,
  },
  sendButton: {
    marginRight: 20,
    marginLeft: 8,
    marginBottom: 16,
    marginTop: 16,
  },
  sendButtonWrapper: {
    justifyContent: 'flex-end',
    minHeight: 20,
    maxHeight: 100,
  },
})

export default class SendChatMessageComposer extends Component {
  constructor(props) {
    super(props)
    this.state = {
      messageText: '',
      composerHeight: 0,
      wrapperHeight: 0,
      loading: true,
      isLogin: false,
    }

    this.sendButton$ = new Subject()
  }

  componentWillMount() {
    ReactUserManager.userIsLogin((_, isLogin) => {
      if (isLogin) {
        if (this.props.chatTemplate.templates.length === 0) {
          this.fetchTemplate()
        } else {
          this.setState({ isLogin, loading: false })
        }
      } else {
        this.setState({ loading: false })
      }
    })
  }

  componentDidMount() {
    TKPReactAnalytics.trackScreenName('send message room')

    this.sendButtonSubcriber = this.sendButton$
      .take(1)
      .subscribe(({ message, to_shop_id, to_user_id }) => {
        const source = this.props.data.source
        ReactNetworkManager.request({
          method: 'POST',
          baseUrl: TKPReactURLManager.topChatURL,
          path: '/tc/v1/send',
          params: {
            message,
            to_shop_id,
            to_user_id,
            source,
          },
        })
          .then(response => {
            if (response.data.is_success) {
              const trackerParams = {
                name: 'ClickMessageRoom',
                category: 'send message room',
                action: 'click on kirim',
                label: '',
              }
              TKPReactAnalytics.trackEvent(trackerParams)
              ReactInteractionHelper.showStickyAlert('Chat sukses terkirim.')
              Navigator.pop()
            }
          })
          .catch(() => {
            ReactInteractionHelper.showErrorStickyAlert(
              'Terjadi kendala saaat mengirim pesan.',
            )
          })
      })
  }

  handleSendButtonPressed = () => {
    if (!this.state.isLogin) {
      ReactInteractionHelper.showErrorStickyAlert(
        'Silahkan login terlebih dahulu untuk mengirim chat ke penjual',
      )
      return
    }

    if (this.state.messageText === '') {
      ReactInteractionHelper.showErrorStickyAlert(
        'Isi chat tidak boleh kosong.',
      )
      return
    }

    let message = this.state.messageText
    if (this.props.data.productURL) {
      message = `${message}\n\nLink Produk:\n${this.props.data.productURL}`
    }

    if (this.props.data.invoiceURL) {
      message = `${message}\n\nINVOICE:\n${this.props.data.invoiceURL}`
    }

    const param = {
      message,
      to_shop_id: this.props.data.shopID ? this.props.data.shopID : '',
      to_user_id: this.props.data.userID ? this.props.data.userID : '',
    }

    this.sendButton$.next(param)
  }

  handleLayoutComposerHeight = ({ nativeEvent: { layout: { height } } }) => {
    this.setState({
      composerHeight: height,
    })
  }

  componentWillUnmount() {
    this.sendButtonSubcriber.unsubscribe()
  }

  fetchTemplate = () =>
    this.props
      .fetchChatTemplate()
      .then(() => {
        this.setState({
          loading: false,
          isLogin: true,
        })
      })
      .catch(() => this.setState({ loading: false }))

  handleLayoutWrapperHeight = ({ nativeEvent: { layout: { height } } }) => {
    this.setState({
      wrapperHeight: height,
    })
  }

  handleTextChanged = messageText => {
    this.setState({
      messageText,
    })
  }

  attachmentView() {
    if (this.props.data.source === 'pdp') {
      return (
        <View style={styles.attachmentView}>
          <Text style={styles.attachmentTitle}>Link Produk:</Text>
          <Text style={styles.attachmentURL}>{this.props.data.productURL}</Text>
        </View>
      )
    }

    if (
      this.props.data.source === 'tx_ask_buyer' ||
      this.props.data.source === 'tx_ask_seller'
    ) {
      return (
        <View style={styles.attachmentView}>
          <Text style={styles.attachmentTitle}>INVOICE:</Text>
          <Text style={styles.attachmentURL}>{this.props.data.invoiceURL}</Text>
        </View>
      )
    }

    return null
  }

  handlePressTemplate = messageText => {
    this.setState(
      prevState => ({
        messageText: `${prevState.messageText}${messageText} `,
      }),
      () => {
        if (this.props.data.source === 'pdp') {
          const trackerParams = {
            name: 'clickProductPage',
            category: 'product page',
            action: 'click on template chat',
            label: '',
          }

          TKPReactAnalytics.trackEvent(trackerParams)
        } else if (this.props.data.source === 'shop') {
          const trackerParams = {
            name: 'clickShopPage',
            category: 'shop page',
            action: 'click on template chat',
            label: '',
          }

          TKPReactAnalytics.trackEvent(trackerParams)
        }
      },
    )
  }

  render() {
    if (this.state.loading) {
      return <Loading />
    }

    return (
      <KeyboardAvoidingView
        behavior={'padding'}
        style={styles.main}
        keyboardVerticalOffset={this.state.composerHeight}
      >
        <View style={{ flex: 1 }} />
        <View
          style={styles.container}
          onLayout={this.handleLayoutWrapperHeight}
        >
          {!this.state.isLogin ? null : (
            <ChatTemplate
              chatTemplate={this.props.chatTemplate}
              onPressTemplate={this.handlePressTemplate}
              bottomOffset={this.state.wrapperHeight}
            />
          )}
          {this.attachmentView()}
          <View
            style={styles.composerView}
            onLayout={this.handleLayoutComposerHeight}
          >
            <TextInput
              style={styles.textView}
              placeholder={'Tulis pesan...'}
              placeholderTextColor={'rgba(0, 0, 0, 0.4)'}
              selectionColor={'rgb(66, 181, 73)'}
              value={this.state.messageText}
              onChangeText={this.handleTextChanged}
              multiline
            />
            <View style={styles.sendButtonWrapper}>
              <TouchableOpacity onPress={this.handleSendButtonPressed}>
                <Image style={styles.sendButton} source={sendButton} />
              </TouchableOpacity>
            </View>
          </View>
        </View>
      </KeyboardAvoidingView>
    )
  }
}
