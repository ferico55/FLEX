/* @flow */

import React, { Component } from 'react'
import {
  View,
  Text,
  StyleSheet,
  TouchableOpacity,
  Image,
  ActivityIndicator,
} from 'react-native'
import { MessageText, ImageProgress } from '@TopChatComponents/'
import { unixConverter, textToTimeAgo } from '@TopChatHelpers/TimeConverters'
import read from '@img/read.png'
import unread from '@img/readUnread.png'
import pending from '@img/readPending.png'
import Icon from 'react-native-vector-icons/FontAwesome'
import isTypingGif from '@img/isTyping.gif'

const SHOP_ADMIN = 'Shop Admin'
const SHOP_OWNER = 'Shop Owner'

const ATTACHMENT_TYPE_SINGLE_IMAGE = 1 // Attachment Type 1, Only Single Image and Go to applink when clicked

export default class BubbleChat extends Component {
  renderSection = () => (
    <View style={styles.timeWrapper}>
      <Text style={styles.timeText}>{textToTimeAgo(this.props.title)}</Text>
    </View>
  )

  renderReadStatus = isRead => {
    if (isRead === true) {
      return (
        <Image
          source={read}
          style={{ width: 11, height: 6, marginRight: 2 }}
          resizeMode={'contain'}
        />
      )
    } else if (isRead === 'pending') {
      return (
        <Image
          source={pending}
          style={{ width: 11, height: 6, marginRight: 2 }}
          resizeMode={'contain'}
        />
      )
    }

    return (
      <Image
        source={unread}
        style={{ width: 11, height: 6, marginRight: 2 }}
        resizeMode={'contain'}
      />
    )
  }

  renderUserData = () => {
    if (this.props.sender_id === this.props.userId) {
      return (
        <View
          style={{
            flexDirection: 'row',
            alignItems: 'center',
            marginBottom: 5,
          }}
        >
          <Text style={styles.nameTag}>Anda</Text>
          <Icon name={'circle'} size={5} color={'rgb(158,158,158)'} />
          <Text style={styles.roleTag}>
            {this.props.role === SHOP_OWNER ? 'Pemilik Toko' : 'Admin Pesan'}
          </Text>
        </View>
      )
    }
    return (
      <View
        style={{ flexDirection: 'row', alignItems: 'center', marginBottom: 5 }}
      >
        <Text style={styles.nameTag}>{this.props.sender_name}</Text>
        <Icon name={'circle'} size={5} color={'rgb(158,158,158)'} />
        <Text style={styles.roleTag}>
          {this.props.role === SHOP_ADMIN ? 'Admin Pesan' : 'Pemilik Toko'}
        </Text>
      </View>
    )
  }

  handlePressAttachment = url => {
    if (this.props.onUrlPress) {
      this.props.onUrlPress(url)
    }
  }

  // This func will be use on next version in regards of attachment
  renderMsg = () => {
    if (this.props.attachment_id !== 0) {
      switch (this.props.attachment.type) {
        case ATTACHMENT_TYPE_SINGLE_IMAGE:
          return (
            <TouchableOpacity
              style={styles[this.props.position].imageWrapper}
              onPress={() =>
                this.handlePressAttachment(
                  this.props.attachment.attributes.url,
                )}
            >
              <ImageProgress
                source={{
                  uri: this.props.attachment.attributes.image_url,
                }}
                resizeMode={'contain'}
              />
            </TouchableOpacity>
          )
        default:
          const fallBackProps = {
            searchKeyword: this.props.searchKeyword,
            onUrlPress: this.props.onUrlPrness,
            position: this.props.position,
            msg: this.props.attachment.fallback_attachment.html,
          }
          return (
            <View>
              <MessageText {...fallBackProps} />
            </View>
          )
      }
    }

    return (
      <TouchableOpacity activeOpacity={1} accessibilityTraits="text">
        <MessageText {...this.props} />
      </TouchableOpacity>
    )
  }

  render() {
    if (this.props.isTyping) {
      return (
        <View style={{ flex: 1 }}>
          <View
            style={{
              alignItems: 'flex-start',
              marginLeft: 10,
              paddingBottom: 40, // height of chat template
              marginTop: -110,
            }}
          >
            <Image source={isTypingGif} />
          </View>
        </View>
      )
    }

    let containerStyle = StyleSheet.flatten([styles.container])
    // this only appear on last index on first section because our sectionlist is inverted
    if (this.props.lastSection === this.props.title && this.props.index === 0) {
      containerStyle = {
        ...containerStyle,
        paddingBottom: this.props.showComposer ? 100 : 10,
      }
    }

    return (
      <View style={containerStyle}>
        <View style={[styles[this.props.position].container]}>
          {this.props.showUserData &&
          this.props.position === 'right' &&
          this.props.role !== 'User' ? (
            this.renderUserData()
          ) : null}
          <View style={[styles[this.props.position].wrapper]}>
            <TouchableOpacity activeOpacity={1} accessibilityTraits="text">
              <MessageText {...this.props} />
            </TouchableOpacity>
          </View>
          {this.props.position === 'right' ? (
            <View
              style={{
                flexDirection: 'row',
                alignItems: 'center',
                marginTop: 5,
              }}
            >
              {this.renderReadStatus(this.props.message_is_read)}
              <Text style={styles.timeText}>
                {unixConverter(this.props.reply_time)}
              </Text>
            </View>
          ) : (
            <Text style={[styles.timeText, { marginTop: 5 }]}>
              {unixConverter(this.props.reply_time)}
            </Text>
          )}
        </View>
      </View>
    )
  }
}

const styles = {
  container: {
    flex: 1,
  },
  left: StyleSheet.create({
    container: {
      flex: 1,
      alignItems: 'flex-start',
      marginBottom: 5,
      marginLeft: 10,
    },
    wrapper: {
      borderTopRightRadius: 12,
      borderBottomLeftRadius: 12,
      borderBottomRightRadius: 12,
      backgroundColor: '#f0f0f0',
      marginRight: 60,
      minHeight: 40,
      justifyContent: 'center',
    },
    imageWrapper: {
      overflow: 'hidden',
      borderTopRightRadius: 12,
      borderBottomLeftRadius: 12,
      borderBottomRightRadius: 12,
    },
    containerToNext: {
      borderBottomLeftRadius: 3,
    },
    containerToPrevious: {
      borderTopLeftRadius: 3,
    },
  }),
  right: StyleSheet.create({
    container: {
      flex: 1,
      alignItems: 'flex-end',
      marginBottom: 5,
      marginRight: 10,
    },
    wrapper: {
      borderTopLeftRadius: 12,
      borderBottomLeftRadius: 12,
      borderBottomRightRadius: 12,
      backgroundColor: 'rgb(66,181,73)',
      marginLeft: 60,
      paddingVertical: 5,
      justifyContent: 'center',
    },
    imageWrapper: {
      overflow: 'hidden',
      borderTopLeftRadius: 12,
      borderBottomLeftRadius: 12,
      borderBottomRightRadius: 12,
    },
    containerToNext: {
      borderBottomRightRadius: 3,
    },
    containerToPrevious: {
      borderTopRightRadius: 3,
    },
  }),
  bottom: {
    flexDirection: 'row',
    justifyContent: 'flex-end',
  },
  tick: {
    fontSize: 10,
    backgroundColor: 'transparent',
    color: 'white',
  },
  tickView: {
    flexDirection: 'row',
    marginRight: 10,
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
  nameTag: {
    marginRight: 3,
    color: 'rgba(0,0,0,0.7)',
    fontWeight: '500',
    fontSize: 11,
  },
  roleTag: {
    marginLeft: 3,
    color: 'rgba(0,0,0,0.38)',
    fontSize: 11,
  },
}
