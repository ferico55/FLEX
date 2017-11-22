import React, { PureComponent } from 'react'
import { Text, Image, View, StyleSheet, TouchableOpacity } from 'react-native'
import Navigator from 'native-navigation'
import PropTypes from 'prop-types'
import striptags from 'striptags'
import { TKPReactAnalytics } from 'NativeModules'
import { unixConverter, lastReplyTime } from '@helpers/TimeConverters'
import radioButton from '@img/radioButton.png'
import checkList from '@img/checkList.png'

const styles = StyleSheet.create({
  container: {
    flexDirection: 'row',
    flex: 1,
    alignItems: 'center',
  },
  image: {
    aspectRatio: 1,
    height: 40,
    width: 40,
    borderRadius: 20,
  },
  nameActive: {
    fontSize: 16,
    fontWeight: '500',
    marginRight: 5,
    maxWidth: 150,
  },
  nameInactive: {
    fontSize: 16,
    marginRight: 5,
    maxWidth: 150,
  },
  userLabelContainer: {
    borderColor: '#42b549',
    borderWidth: 1,
    borderRadius: 5,
    opacity: 0.7,
    padding: 3,
    height: 18,
    justifyContent: 'center',
  },
  userLabel: {
    fontSize: 10,
    color: '#42b549',
    alignSelf: 'center',
  },
  timestamp: {
    marginLeft: 12,
    fontSize: 11,
    color: 'rgba(0, 0, 0, 0.38)',
  },
  message: {
    fontSize: 13,
    color: 'rgba(0, 0, 0, 0.54)',
    lineHeight: 18,
    maxWidth: 196.5,
  },
  unreadMessage: {
    fontSize: 13,
    color: 'rgba(0, 0, 0, 0.54)',
    lineHeight: 18,
    maxWidth: 196.5,
    fontWeight: '500',
  },
  isTyping: {
    fontStyle: 'italic',
    fontSize: 13,
    color: '#42b549',
  },
  unreadContainer: {
    borderRadius: 100,
    backgroundColor: '#42b549',
    padding: 3,
    minWidth: 20,
    height: 20,
    alignItems: 'center',
  },
  unreadText: {
    color: '#ffffff',
    fontSize: 10,
    fontWeight: '500',
  },
  subcontainer1: {
    flexDirection: 'column',
    flex: 1,
    paddingRight: 14,
    borderBottomWidth: 1,
    borderBottomColor: 'rgba(0, 0, 0, 0.05)',
  },
  subcontainer2: {
    flexDirection: 'row',
    marginTop: 14,
    flex: 1,
    justifyContent: 'space-between',
    alignItems: 'center',
  },
  subcontainer3: {
    flexDirection: 'row',
    flex: 1,
  },
  subcontainer4: {
    flexDirection: 'row',
    flex: 1,
    alignItems: 'flex-start',
    justifyContent: 'space-between',
  },
})

class ChatCell extends PureComponent {
  setUnread(amount) {
    if (amount === 0) {
      return null
    }

    return (
      <View style={styles.unreadContainer}>
        <Text style={styles.unreadText}>{this.props.attributes.unreads}</Text>
      </View>
    )
  }

  setName(unreadAmount) {
    if (unreadAmount === 0) {
      return (
        <Text style={styles.nameInactive} numberOfLines={1}>
          {this.props.attributes.contact.attributes.name}
        </Text>
      )
    }

    return (
      <Text style={styles.nameActive} numberOfLines={1}>
        {this.props.attributes.contact.attributes.name}
      </Text>
    )
  }

  setMessage(isTyping, unread) {
    if (typeof isTyping === 'undefined') {
      return (
        <Text style={styles.message} numberOfLines={1}>
          {striptags(this.props.attributes.last_reply_msg)}
        </Text>
      )
    }

    if (isTyping) {
      return (
        <Text style={styles.isTyping} numberOfLines={1}>
          sedang mengetik...
        </Text>
      )
    }

    if (unread > 0) {
      return (
        <Text style={styles.unreadMessage} numberOfLines={1}>
          {striptags(this.props.attributes.last_reply_msg)}
        </Text>
      )
    }

    return (
      <Text style={styles.message} numberOfLines={1}>
        {striptags(this.props.attributes.last_reply_msg)}
      </Text>
    )
  }

  cellTapped = () => {
    const trackerParams = {
      name: 'ClickInboxChat',
      category: 'inbox-chat',
      action: 'click on chatlist',
      label: '',
    }

    TKPReactAnalytics.trackEvent(trackerParams)

    if (!this.props.fromIpad) {
      Navigator.push('TopChatDetail', {
        ...this.props,
      })
    } else {
      if (
        this.props.currentMsgId !== null &&
        this.props.currentMsgId !== this.props.msg_id
      ) {
        this.props.unsetMsgId(this.props.currentMsgId)
        this.props.unsetIpadAttributes()
      }

      if (
        this.props.currentMsgId === null ||
        this.props.currentMsgId !== this.props.msg_id
      ) {
        this.props.fetchReplyList(this.props.msg_id)
        this.props.setIpadAttributes({
          shop_id: this.props.shop_id,
          attributes: this.props.attributes,
        })
      }
    }
  }

  selectRow = ({ index, msg_id }) => {
    this.props.toggleSelectRow({ index, msg_id })
  }

  userLabel(role) {
    if (role !== 'Pengguna' && typeof role !== 'undefined') {
      return (
        <View style={styles.userLabelContainer}>
          <Text style={styles.userLabel}>{role}</Text>
        </View>
      )
    }

    return null
  }

  render() {
    const tagFlex =
      this.props.attributes.contact.attributes.tag !== 'Pengguna' &&
      typeof this.props.attributes.contact.attributes.tag !== 'undefined'
        ? 1
        : 0
    if (this.props.editMode) {
      return (
        <TouchableOpacity
          disabled={this.props.disabled}
          activeOpacity={0.95}
          onPress={() =>
            this.selectRow({
              index: this.props.index,
              msg_id: this.props.msg_id,
            })}
          style={{
            flex: 1,
            flexDirection: 'row',
            backgroundColor:
              this.props.selectedData[this.props.msg_id] === this.props.index
                ? '#f3fef3'
                : 'white',
          }}
        >
          <View
            style={{
              flex: 1,
              flexDirection: 'row',
            }}
          >
            <View
              style={{
                width: 46,
                alignItems: 'center',
                justifyContent: 'center',
              }}
            >
              <Image
                source={
                  this.props.selectedData[this.props.msg_id] ===
                  this.props.index ? (
                    checkList
                  ) : (
                    radioButton
                  )
                }
                resizeMode={'contain'}
                style={{ width: 18, height: 18 }}
              />
            </View>
            <View style={{ flex: 1, flexDirection: 'row' }}>
              <View
                style={{
                  alignItems: 'center',
                  justifyContent: 'center',
                  paddingVertical: 16,
                  paddingRight: 12,
                }}
              >
                <Image
                  source={{
                    uri: this.props.attributes.contact.attributes.thumbnail,
                  }}
                  style={styles.image}
                />
              </View>
              <View
                style={{
                  flex: 1,
                  borderBottomWidth: 1,
                  borderBottomColor: 'rgba(0,0,0,0.05)',
                  paddingTop: 16,
                  paddingBottom: 15,
                  paddingRight: 16,
                }}
              >
                <View style={{ flex: 0.5 }}>
                  <View style={{ flex: 1, flexDirection: 'row' }}>
                    <View style={{ flex: 1, flexDirection: 'row' }}>
                      {this.setName(this.props.attributes.unreads)}
                      {this.userLabel(
                        this.props.attributes.contact.attributes.tag,
                      )}
                    </View>
                    <View
                      style={{
                        flex: tagFlex,
                        justifyContent: 'center',
                        alignItems: 'flex-end',
                      }}
                    >
                      <Text style={styles.timestamp}>
                        {lastReplyTime(
                          unixConverter(
                            this.props.attributes.last_reply_time,
                            'YYYY MMM D HH:mm',
                          ),
                        )}
                      </Text>
                    </View>
                  </View>
                </View>
                <View style={{ flex: 0.5, justifyContent: 'center' }}>
                  <View style={{ flexDirection: 'row' }}>
                    {this.setMessage(
                      this.props.is_typing,
                      this.props.attributes.unreads,
                    )}
                    <View style={{ flex: 1, alignItems: 'flex-end' }}>
                      {this.setUnread(this.props.attributes.unreads)}
                    </View>
                  </View>
                </View>
              </View>
            </View>
          </View>
        </TouchableOpacity>
      )
    }

    return (
      <TouchableOpacity
        disabled={this.props.disabled}
        onPress={this.cellTapped}
        style={{
          backgroundColor:
            this.props.fromIpad && this.props.msg_id === this.props.currentMsgId
              ? '#f3fef3'
              : 'white',
        }}
      >
        <View
          style={{
            flex: 1,
          }}
        >
          <View style={{ flex: 1, flexDirection: 'row' }}>
            <View
              style={{
                alignItems: 'center',
                justifyContent: 'center',
                paddingVertical: 16,
                paddingLeft: 16,
                paddingRight: 12,
              }}
            >
              <Image
                source={{
                  uri: this.props.attributes.contact.attributes.thumbnail,
                }}
                style={styles.image}
              />
            </View>
            <View
              style={{
                flex: 1,
                borderBottomWidth: 1,
                borderBottomColor: 'rgba(0,0,0,0.05)',
                paddingTop: 16,
                paddingBottom: 15,
                paddingRight: 16,
              }}
            >
              <View style={{ flex: 0.5 }}>
                <View style={{ flex: 1, flexDirection: 'row' }}>
                  <View style={{ flex: 1, flexDirection: 'row' }}>
                    {this.setName(this.props.attributes.unreads)}
                    {this.userLabel(
                      this.props.attributes.contact.attributes.tag,
                    )}
                  </View>
                  <View
                    style={{
                      flex: tagFlex,
                      justifyContent: 'center',
                      alignItems: 'flex-end',
                    }}
                  >
                    <Text style={styles.timestamp}>
                      {lastReplyTime(
                        unixConverter(
                          this.props.attributes.last_reply_time,
                          'YYYY MMM D HH:mm',
                        ),
                      )}
                    </Text>
                  </View>
                </View>
              </View>
              <View style={{ flex: 0.5, justifyContent: 'center' }}>
                <View style={{ flexDirection: 'row' }}>
                  {this.setMessage(
                    this.props.is_typing,
                    this.props.attributes.unreads,
                  )}
                  <View style={{ flex: 1, alignItems: 'flex-end' }}>
                    {this.setUnread(this.props.attributes.unreads)}
                  </View>
                </View>
              </View>
            </View>
          </View>
        </View>
      </TouchableOpacity>
    )
  }
}

ChatCell.defaultProps = {
  is_typing: false,
  currentMsgId: 0,
  msg_id: 0,
  attributes: {},
  fromIpad: false,
  fetchReplyList: () => {},
  unsetMsgId: () => {},
}

ChatCell.propTypes = {
  attributes: PropTypes.shape({
    contact: PropTypes.object,
    unreads: PropTypes.number,
    last_reply_time: PropTypes.number,
    last_reply_msg: PropTypes.string,
  }),
  is_typing: PropTypes.bool,
  currentMsgId: PropTypes.number,
  msg_id: PropTypes.number,
  fromIpad: PropTypes.bool,
  fetchReplyList: PropTypes.func,
  unsetMsgId: PropTypes.func,
}

export default ChatCell
