/* @flow */

import React, { Component } from 'react'
import {
  View,
  StyleSheet,
  Animated,
  SectionList,
  ActivityIndicator,
  Text,
} from 'react-native'
import _ from 'lodash'
import { textToTimeAgo } from '@helpers/TimeConverters'
import { BubbleChat, MessageComposer } from '@components/'

export default class MessageContainer extends Component {
  constructor(props) {
    super(props)

    this.state = {
      wrapperBottomOffset: 40,
      isInitialized: false,
      containerHeight: 0,
      innerContainerHeight: 0,
      dataSource: [],
      showHistoryFooter: false,
      isScrollToHighlight: false,
    }

    this.limiter = 1
    this.containerHeight = new Animated.Value(0)
    this.wrapperBottomOffset = new Animated.Value(40)
  }

  // will be use on next version
  // componentWillReceiveProps(nextProps) {
  //   if (
  //     nextProps.messages.current_msg_id !== null &&
  //     this.props.data.textarea_reply &&
  //     this.limiter === 1
  //   ) {
  //     this.props.setOnlineStatus()
  //     this.limiter += 1
  //   }
  // }

  renderItem = ({ item, index, section: { title, data } }) => (
    <BubbleChat
      position={item.is_opposite ? 'left' : 'right'}
      {...item}
      index={index}
      title={title}
      count={data.length - 1}
      lastSection={this.props.data.list[0].title}
      showUserData={this.props.data.contacts.length > 2}
      userId={this.props.userId}
      searchKeyword={this.props.searchKeyword}
      onUrlPress={this.props.onUrlPress}
    />
  )

  onKeyboardWillShow = ({ endCoordinates: { height } }) => {
    Animated.timing(this.containerHeight, {
      toValue: this.state.containerHeight - height,
      duration: 200,
      bounciness: 0,
    }).start()
    this.setState({
      innerContainerHeight: this.state.containerHeight - height - 40,
    })
  }

  onKeyboardWillHide = () => {
    Animated.timing(this.containerHeight, {
      toValue: this.state.containerHeight,
      duration: 200,
      bounciness: 0,
    }).start()
    this.setState({
      innerContainerHeight: this.state.containerHeight - 40,
    })
  }

  onLayoutInitialized = ({ nativeEvent: { layout: { height } } }) => {
    Animated.timing(this.containerHeight, {
      toValue: height,
      bounciness: 0,
      duration: 200,
    }).start(() => {
      this.setState({
        isInitialized: true,
        containerHeight: height,
        innerContainerHeight: height - 40,
      })
    })
  }

  onPressSend = message => {
    if (this.props.onPressSend) {
      this.props.onPressSend(message, this.sectionList)
    }
  }

  onPressAttachment = () => {
    if (this.props.onPressAttachment) {
      this.props.onPressAttachment(this.sectionList)
    }
  }

  renderIsTyping = () => {
    if (
      this.props.messages.is_typing &&
      this.props.messages.data.data.msg_id ===
        this.props.messages.current_msg_id
    ) {
      return (
        <View style={{ marginVertical: 20 }}>
          <BubbleChat position={'left'} isTyping />
        </View>
      )
    }

    return null
  }

  onLayoutComposer = ({ nativeEvent: { layout: { height } } }) => {
    this.setState({
      wrapperBottomOffset: height,
    })
  }

  renderSectionFooter = ({ section: { title } }) => (
    <View style={styles.timeWrapper}>
      <Text style={styles.timeText}>{textToTimeAgo(title)}</Text>
    </View>
  )

  scrollToHighlight = scrollParams => {
    let error = null
    try {
      if (typeof scrolParams !== 'undefined') {
        throw 'undefined scrollParams'
      } else {
        this.sectionList.scrollToLocation(scrollParams)
      }
    } catch (e) {
      error = e
    }
    return error
  }

  render() {
    if (this.state.isInitialized) {
      return (
        <Animated.View style={{ height: this.containerHeight }}>
          <Animated.View
            style={{
              position: 'absolute',
              bottom: this.props.data.textarea_reply
                ? this.state.wrapperBottomOffset
                : 0,
              left: 0,
              right: 0,
              height: this.props.data.textarea_reply
                ? this.state.innerContainerHeight
                : this.state.innerContainerHeight + 40,
            }}
          >
            <SectionList
              ref={ref => {
                this.sectionList = ref
              }}
              onContentSizeChange={(contentWidth, contentHeight) => {
                this.props.onContentSizeChange(
                  contentHeight,
                  this.state.innerContainerHeight,
                )
                if (this.props.searchKeyword !== null) {
                  const scrollToTop = this.scrollToHighlight(
                    this.props.data.scrollParams,
                  )
                  if (scrollToTop === null) {
                    this.setState(
                      {
                        isScrollToHighlight: true,
                      },
                      () => this.props.resetScrollParams(),
                    )
                  }
                }
              }}
              inverted
              renderSectionFooter={this.renderSectionFooter}
              onScroll={this.props.onScroll}
              renderItem={this.renderItem}
              keyExtractor={(item, index) => item.reply_id}
              sections={this.props.data.list}
              onKeyboardWillShow={this.onKeyboardWillShow}
              onKeyboardWillHide={this.onKeyboardWillHide}
              ListFooterComponent={this.props.loadingIndicator}
              ListHeaderComponent={this.renderIsTyping}
              keyboardDismissMode={'on-drag'}
            />
          </Animated.View>
          {!this.props.data.textarea_reply ? null : (
            <View
              style={{
                position: 'absolute',
                bottom: 0,
                right: 0,
                left: 0,
                borderTopColor: 'rgb(224,224,224)',
                borderTopWidth: 1,
              }}
            >
              <MessageComposer
                showComposer={this.props.data.textarea_reply}
                onPressAttachment={this.onPressAttachment}
                onChangeText={this.props.onChangeText}
                onPressSend={this.onPressSend}
                messageText={this.props.messageText}
                onLayoutComposer={this.onLayoutComposer}
                connectedToWS={this.props.connectedToWS}
              />
            </View>
          )}
          {!this.state.isScrollToHighlight &&
          this.props.searchKeyword !== null ? (
            <View
              style={{
                backgroundColor: 'rgb(255,255,255)',
                position: 'absolute',
                top: 0,
                bottom: 0,
                right: 0,
                left: 0,
              }}
            >
              <View
                style={{
                  flex: 1,
                  alignItems: 'center',
                  justifyContent: 'center',
                }}
              >
                <ActivityIndicator animating />
              </View>
            </View>
          ) : null}
        </Animated.View>
      )
    }

    return (
      <View
        style={[
          styles.container,
          { alignItems: 'center', justifyContent: 'center' },
        ]}
        onLayout={this.onLayoutInitialized}
      >
        <ActivityIndicator size={'small'} animating />
      </View>
    )
  }
}

MessageContainer.defaultProps = {
  data: {
    list: [],
  },
  paging_next: false,
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
  },
  timeWrapper: {
    alignItems: 'center',
    justifyContent: 'center',
    height: 25,
  },
  timeText: {
    fontSize: 11,
    color: 'rgba(0,0,0,0.3)',
  },
})
