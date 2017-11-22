import React, { PureComponent } from 'react'
import {
  Text,
  Image,
  View,
  StyleSheet,
  TouchableOpacity,
  // Dimensions,
} from 'react-native'
import Navigator from 'native-navigation'
import HTMLView from 'react-native-htmlview'

import { unixConverter, lastReplyTime } from '@helpers/TimeConverters'
import { resultsFor } from '@redux/chat_search/Actions'

// const WINDOW_WIDTH = Dimensions.get('window').width
const { CONTACTS, REPLIES } = resultsFor

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
    borderRadius: 20.0,
  },
  nameActive: {
    fontSize: 16,
    fontWeight: '500',
    // marginRight: 5,
    maxWidth: 150,
  },
  nameInactive: {
    fontSize: 16,
    // marginRight: 5,
    maxWidth: 200,
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
    maxWidth: 200,
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
    borderRadius: 10,
    backgroundColor: '#42b549',
    padding: 3,
    minWidth: 20,
    alignItems: 'center',
    marginLeft: 12,
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

class SearchCell extends PureComponent {
  setName(resultFor, renderKey) {
    if (resultFor === CONTACTS) {
      return (
        <HTMLView
          style={{ flexDirection: 'row' }}
          value={this.props.item.contact.attributes[renderKey]}
          renderNode={(node, index, siblings, parent, defaultRenderer) =>
            this.renderNodeHtml(
              'nameInactive',
              node,
              index,
              siblings,
              parent,
              defaultRenderer,
            )}
        />
      )
    }

    return (
      <Text style={styles.nameInactive} numberOfLines={1}>
        {this.props.item.contact.attributes.name}
      </Text>
    )
  }

  setMessage(resultFor, renderKey) {
    if (resultFor === REPLIES) {
      return (
        <HTMLView
          style={{ flexDirection: 'row' }}
          value={this.props.item[renderKey]}
          renderNode={(node, index, siblings, parent, defaultRenderer) =>
            this.renderNodeHtml(
              'message',
              node,
              index,
              siblings,
              parent,
              defaultRenderer,
            )}
        />
      )
    }

    return (
      <Text style={styles.message} numberOfLines={1}>
        {this.props.item.last_message}
      </Text>
    )
  }

  cellTapped = () => {
    const {
      item: { msg_id, reply_id, create_time, last_message, contact },
      currentUser: { user_id, full_name, shop_id },
      resultFor,
      currentMsgId,
    } = this.props
    const searchKeyword =
      resultFor === CONTACTS
        ? null
        : last_message.match(/<span.*?>(.*?)<\/span>/)[1]
    const section = unixConverter(create_time, 'YYYYMMDD', false)

    if (!this.props.fromIpad) {
      Navigator.push('TopChatDetail', {
        user_id,
        full_name,
        msg_id,
        reply_id: resultFor === REPLIES ? reply_id : null,
        section,
        fromSearch: true,
        searchKeyword,
        attributes: {
          contact,
        },
      })
    } else {
      if (currentMsgId !== null && currentMsgId !== msg_id) {
        this.props.unsetMsgId(this.props.currentMsgId)
        this.props.unsetIpadAttributes()
      }

      if (searchKeyword === null) {
        this.props.fetchReplyList(msg_id, 1)
      } else {
        this.props.fetchReplyListForSearch(
          msg_id,
          resultFor === REPLIES ? reply_id : null,
          section,
          searchKeyword,
        )
      }

      this.props.setIpadAttributes({
        shop_id,
        attributes: {
          contact,
        },
      })
    }
  }

  renderNodeHtml = (styleName, node, index) => {
    if (index < 4) {
      if (node.type === 'tag') {
        const textToShow = node.children.length > 0 ? node.children[0].data : ''
        return (
          <Text
            key={index}
            style={[styles[styleName], { color: 'rgb(66,181,73)' }]}
            numberOfLines={1}
          >
            {textToShow}
          </Text>
        )
      }

      if (node.type === 'text') {
        return (
          <Text key={index} style={styles[styleName]} numberOfLines={1}>
            {node.data}
          </Text>
        )
      }
    } else if (index === 4) {
      return (
        <Text key={index} style={{ fontSize: 13, lineHeight: 18 }}>
          ...
        </Text>
      )
    }

    return null
  }

  render() {
    const { resultFor, renderKey } = this.props

    return (
      <TouchableOpacity
        disabled={this.props.disabled}
        onPress={this.cellTapped}
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
                  uri: this.props.item.contact.attributes.thumbnail,
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
                  {this.setName(resultFor, renderKey)}
                  <View
                    style={{
                      flex: 1,
                      justifyContent: 'center',
                      alignItems: 'flex-end',
                    }}
                  >
                    <Text style={styles.timestamp}>
                      {lastReplyTime(
                        unixConverter(
                          this.props.item.create_time,
                          'YYYY MMM D HH:mm',
                          false,
                        ),
                      )}
                    </Text>
                  </View>
                </View>
              </View>
              <View style={{ flex: 0.5, justifyContent: 'center' }}>
                <View style={{ flexDirection: 'row' }}>
                  {this.setMessage(resultFor, renderKey)}
                </View>
              </View>
            </View>
          </View>
        </View>
      </TouchableOpacity>
    )
  }
}

export default SearchCell
