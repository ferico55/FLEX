import React, { Component } from 'react'
import {
  Text,
  View,
  StyleSheet,
  Image,
  TextInput,
  TouchableOpacity,
  SectionList,
  Dimensions,
  KeyboardAvoidingView,
  NativeModules,
  ActivityIndicator,
} from 'react-native'

import { ReactInteractionHelper } from 'NativeModules'
import Navigator from 'native-navigation'
import replyTime from '@FeedHelpers/ReplyTime'
import DeviceInfo from 'react-native-device-info'
import KOLBadge from '@FeedResources/icon_kol_badge.png'
import SendButton from '@FeedResources/sendButton.png'
import _ from 'lodash'
import Swipeout from 'react-native-swipeout'

const styles = StyleSheet.create({
  container: {
    flex: 1,
    flexDirection: 'column',
    alignItems: 'center',
    backgroundColor: '#f1f1f1',
  },
  subcontainer: {
    flex: 1,
    flexDirection: 'column',
    width: DeviceInfo.isTablet() ? 560 : Dimensions.get('window').width,
  },
  sectionList: {
    flex: 1,
  },
  postContainer: {
    flexDirection: 'row',
    borderWidth: 1,
    borderColor: '#e0e0e0',
    backgroundColor: 'white',
  },
  commentContainer: {
    flexDirection: 'row',
    backgroundColor: 'white',
    borderRightWidth: 1,
    borderLeftWidth: 1,
    borderColor: '#e0e0e0',
  },
  postAuthorImageContainer: {
    alignItems: 'flex-start',
    paddingTop: 10,
    paddingLeft: 10,
    paddingRight: 10,
  },
  postAuthorImage: {
    height: 40,
    width: 40,
    borderRadius: 20,
  },
  postContentContainer: {
    paddingTop: 10,
    paddingRight: 10,
    flexDirection: 'column',
    flex: 1,
  },
  badge: {
    height: 14,
    width: 14,
  },
  postContent: {
    fontSize: 12,
    lineHeight: 18,
    textAlign: 'left',
    fontWeight: '500',
    color: '#000000b3',
    alignItems: 'center',
    flexDirection: 'column',
  },
  timestamp: {
    color: '#00000061',
    fontSize: 11,
    lineHeight: 17,
    textAlign: 'left',
    marginTop: 5,
    marginBottom: 7,
  },
  horizontalLine: {
    height: 1,
    color: '#e0e0e0',
  },
  commentComposerContainer: {
    flexDirection: 'row',
    maxHeight: 100,
    borderWidth: 1,
    borderColor: '#e0e0e0',
    bottom: 0,
    left: 0,
    right: 0,
    backgroundColor: 'white',
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
  seePreviousView: {
    paddingLeft: 10,
    height: 40,
    justifyContent: 'center',
    backgroundColor: 'white',
    borderRightWidth: 1,
    borderLeftWidth: 1,
    borderColor: '#e0e0e0',
  },
  seePreviousText: {
    fontSize: 12,
    color: '#42b549',
    fontWeight: '500',
  },
})

export default class Screen extends Component {
  constructor(props) {
    super(props)

    this.state = {
      isLoading: true,
      currentCursor: '',
      comments: [],
      messageText: '',
      error: null,
    }
  }

  componentWillReceiveProps(nextProps) {
    this.setState({
      isLoading: nextProps.isLoading,
      currentCursor: '',
      comments: nextProps.comments,
      messageText: '',
      error: nextProps.error,
    })
  }

  sectionList() {
    return (
      <SectionList
        ref={ref => {
          this.sectionListRef = ref
        }}
        stickySectionHeadersEnabled={false}
        keyExtractor={(item, index) => index}
        style={styles.sectionList}
        renderSectionHeader={this.renderSectionHeader}
        sections={[
          {
            data: [{ key: 'a' }],
            renderItem: this.renderContent,
            title: 'post',
          },
          {
            data: this.state.comments,
            renderItem: this.renderComment.bind(this),
            title: 'comments',
          },
        ]}
      />
    )
  }

  handleDeletePressed = idComment => {
    this.props
      .deleteComment({
        idComment,
      })
      .then(({ data }) => {
        if (
          data.delete_comment_kol.data.success === 0 ||
          data.delete_comment_kol.error !== null
        ) {
          ReactInteractionHelper.showErrorStickyAlert(
            'Mohon maaf, terjadi kendala pada server. Silakan coba kembali.',
          )
          return
        }

        const foundIndex = _.findIndex(
          this.state.comments,
          v => v.id === idComment,
        )

        this.setState({
          comments: [
            ...this.state.comments.slice(0, foundIndex),
            ...this.state.comments.slice(foundIndex + 1),
          ],
        })

        NativeModules.NotificationCenter.post('OnDeleteComment', {
          state: this.props.cardState,
        })
      })
      .catch(() => {})
  }

  handleTextChanged = messageText => {
    this.setState({
      messageText,
    })
  }

  handleSendButtonPressed = () => {
    if (this.state.messageText === '') {
      ReactInteractionHelper.showErrorStickyAlert(
        'Isi komentar tidak boleh kosong.',
      )
      return
    }

    const message = this.state.messageText

    this.props
      .createComment({
        idPost: this.props.cardState.cardID,
        comment: message,
      })
      .then(({ data }) => {
        this.setState(
          {
            comments: [
              ...this.state.comments,
              {
                id: data.create_comment_kol.data.id,
                comment: data.create_comment_kol.data.comment,
                create_time: data.create_comment_kol.data.create_time,
                isKol: data.create_comment_kol.data.user.iskol,
                userID: data.create_comment_kol.data.user.id,
                userName: data.create_comment_kol.data.user.name,
                userPhoto: data.create_comment_kol.data.user.photo,
                isCommentOwner: true,
              },
            ],
          },
          () => {
            this.sectionListRef.scrollToLocation({
              animated: true,
              itemIndex: this.state.comments.length - 1,
              sectionIndex: 1,
              viewPosition: 0.9,
              viewOffset: -57,
            })
          },
        )
        this.textInputRef.clear()

        NativeModules.NotificationCenter.post('OnCreateComment', {
          state: this.props.cardState,
        })
      })
      .catch(() => {})
  }

  renderSectionHeader = ({ section }) => {
    const loadMoreEntries = this.props.loadMoreEntries
    if (section.title === 'comments' && this.props.hasNextPage) {
      return (
        <TouchableOpacity onPress={loadMoreEntries}>
          <View style={styles.seePreviousView}>
            <Text style={styles.seePreviousText}>
              Lihat Comments Sebelumnya
            </Text>
          </View>
        </TouchableOpacity>
      )
    }

    return null
  }

  renderUserBadge = isKOL => {
    if (isKOL) {
      return (
        <View style={{ width: 17, height: 14 }}>
          <View style={{ width: 14, height: 14, paddingTop: 2 }}>
            <Image style={styles.badge} source={KOLBadge} />
          </View>
          <View style={{ width: 3, height: 1 }} />
        </View>
      )
    }

    return null
  }

  renderSwipeOrNot = comment => {
    let swipeProps = {
      right: [
        {
          text: 'Hapus',
          backgroundColor: '#f02222',
          onPress: () => {
            this.handleDeletePressed(comment.id)
          },
          type: 'delete',
        },
      ],
    }

    if (!comment.isCommentOwner) {
      swipeProps = {}
    }

    return swipeProps
  }

  renderComment({ item }) {
    return (
      <Swipeout {...this.renderSwipeOrNot(item)} autoClose>
        <View style={styles.commentContainer}>
          <View style={styles.postAuthorImageContainer}>
            <View
              style={{
                borderRadius: 20,
                borderWidth: 1,
                borderColor: '#e0e0e0',
              }}
            >
              <Image
                style={styles.postAuthorImage}
                source={{ uri: item.userPhoto }}
              />
            </View>
          </View>
          <View style={styles.postContentContainer}>
            <Text style={styles.postContent}>
              {this.renderUserBadge(item.isKol)}
              {item.userName}
              <View style={{ width: 5, height: 1 }} />
              <Text style={{ fontWeight: 'normal', color: '#0000008a' }}>
                {item.comment}
              </Text>
            </Text>
            <Text style={styles.timestamp}>{replyTime(item.create_time)}</Text>
          </View>
        </View>
      </Swipeout>
    )
  }

  renderContent = () => (
    <View style={styles.postContainer}>
      <View style={styles.postAuthorImageContainer}>
        <View
          style={{
            borderRadius: 20,
            borderWidth: 1,
            borderColor: '#e0e0e0',
          }}
        >
          <Image
            style={styles.postAuthorImage}
            source={{ uri: this.props.cardState.userPhoto }}
          />
        </View>
      </View>
      <View style={styles.postContentContainer}>
        <Text style={styles.postContent}>
          <View style={{ width: 14, height: 14, paddingTop: 2 }}>
            <Image style={styles.badge} source={KOLBadge} />
          </View>
          <View style={{ width: 3, height: 1 }} />
          {this.props.cardState.userName}
          <View style={{ width: 5, height: 1 }} />
          <Text style={{ fontWeight: 'normal', color: '#0000008a' }}>
            {this.props.cardState.description}
          </Text>
        </Text>
        <Text style={styles.timestamp}>
          {replyTime(this.props.cardState.createTime)}
        </Text>
      </View>
    </View>
  )

  render() {
    if (this.state.isLoading) {
      return (
        <Navigator.Config title="Comments">
          <View
            style={{ flex: 1, alignItems: 'center', justifyContent: 'center' }}
          >
            <ActivityIndicator />
          </View>
        </Navigator.Config>
      )
    }

    const subcontainer = [styles.subcontainer]

    if (DeviceInfo.isTablet()) {
      subcontainer.push({ width: 560 })
    }

    return (
      <Navigator.Config title="Comments">
        <View style={styles.container}>
          <KeyboardAvoidingView
            style={{ flex: 1 }}
            behavior={'padding'}
            keyboardVerticalOffset={60}
          >
            <View style={subcontainer}>
              {this.sectionList()}
              <View style={styles.commentComposerContainer}>
                <TextInput
                  ref={ref => {
                    this.textInputRef = ref
                  }}
                  style={styles.textView}
                  placeholder={'Tulis komentar...'}
                  selectionColor={'#42b549'}
                  placeholderTextColor={'#00000061'}
                  onChangeText={this.handleTextChanged}
                  multiline
                />
                <View
                  style={{
                    justifyContent: 'flex-end',
                    minHeight: 20,
                    maxHeight: 100,
                  }}
                >
                  <TouchableOpacity
                    onPress={this.handleSendButtonPressed.bind(this)}
                  >
                    <Image style={styles.sendButton} source={SendButton} />
                  </TouchableOpacity>
                </View>
              </View>
            </View>
          </KeyboardAvoidingView>
        </View>
      </Navigator.Config>
    )
  }
}
