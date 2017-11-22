import React, { Component } from 'react'
import {
  View,
  StyleSheet,
  FlatList,
  Dimensions,
  ActivityIndicator,
  PanResponder,
  SectionList,
  TouchableOpacity,
  Text,
  Image,
} from 'react-native'
import _ from 'lodash'
import { Subject } from 'rxjs'
import {
  RNSearchBarManager,
  ReactTPRoutes,
  TKPReactURLManager,
} from 'NativeModules'
import { SearchChatCell, ChatCell, EmptyState, Overlay } from '@components/'
import { resultsFor, renderBehaviours } from '@redux/chat_search/Actions'
import noResultFound from '@img/noResultFound.png'

const { CONTACTS, REPLIES } = resultsFor
const { BOTH, CONTACTS_ONLY, REPLIES_ONLY } = renderBehaviours

const styles = StyleSheet.create({
  container: {
    flex: 1,
  },
  deleteButton: {
    flex: 1,
    alignItems: 'flex-start',
    justifyContent: 'center',
    backgroundColor: '#42b549',
    padding: 20,
  },
  archiveButton: {
    flex: 1,
    alignItems: 'flex-start',
    justifyContent: 'center',
    backgroundColor: 'rgb(211,211,211)',
    padding: 20,
  },
  markAsReadButton: {
    flex: 1,
    alignItems: 'flex-end',
    justifyContent: 'center',
    backgroundColor: 'rgb(41,151,48)',
    paddingRight: 20,
  },
  swipeButtonText: {
    color: 'white',
    fontSize: 14,
  },
  timeMachineText: {
    fontSize: 11,
    color: 'rgba(0, 0, 0, 0.54)',
    lineHeight: 16,
    alignSelf: 'center',
    textAlign: 'center',
  },
  timeMachineButton: {
    fontWeight: '500',
    color: '#42b549',
  },
  imageActive: {
    height: 24,
    width: 24,
    tintColor: 'rgb(66,181,73)',
  },
  imageUnactive: {
    height: 24,
    width: 24,
    tintColor: 'rgba(0,0,0,0.5)',
  },
  textActive: { fontSize: 14, color: 'rgb(66,181,73)' },
  textUnactive: { fontSize: 14, color: 'rgba(0,0,0,0.5)' },
})

const windowHeight = Dimensions.get('window').height

export default class ChatContainer extends Component {
  constructor(props) {
    super(props)
    this.state = {
      isRefreshing: false,
      currentPage: 1,
      isLoadingNextPage: false,
      isLoadingNextSearchResult: false,
      allSearchLoaded: false,
      overlay: false,
      overlayBottom: 0,
      searchCellHeight: 0,
      loadingMoreSearchContacts: false,
      loadingMoreSearchReplies: false,
    }

    this.onPressTimeMachine$ = new Subject()
    this.contactsSize = 20
    this.repliesPage = 2
  }

  componentWillMount() {
    this.overlayPanResponder = PanResponder.create({
      onStartShouldSetPanResponder: () => true,
      onPanResponderRelease: () => {
        this.props.chatSearchBar.unFocus()
      },
    })

    this.onPressSubscribtion = this.onPressTimeMachine$
      .throttleTime(500)
      .subscribe(url => ReactTPRoutes.navigate(url))
  }

  componentWillReceiveProps(nextProps) {
    if (nextProps.dataSource.success) {
      if (!nextProps.dataSource.data.paging_next) {
        this.setState({
          isRefreshing: false,
          isLoadingNextPage: false,
          currentPage: 1,
        })
      } else {
        this.setState({
          isRefreshing: false,
          isLoadingNextPage: false,
        })
      }
    }

    if (nextProps.chatSearch.success) {
      const data = nextProps.chatSearch.data[0]
      const nextPage = typeof data !== 'undefined' ? data.nextPage : false
      let allSearchLoaded = false

      // reset the variable for load more search
      if (nextProps.chatSearch.loading) {
        this.repliesPage = 2
        this.contactsSize = 20
        this.setState({
          allSearchLoaded: false,
        })
      }

      if (nextProps.chatSearch.renderBehaviour === BOTH) {
        this.setState({
          loadingMoreSearchContacts: false,
          loadingMoreSearchReplies: false,
          isLoadingNextSearchResult: false,
        })
      } else if (nextProps.chatSearch.renderBehaviour === CONTACTS_ONLY) {
        if (!nextPage) {
          allSearchLoaded = true
        }
        this.setState({
          loadingMoreSearchContacts: false,
          isLoadingNextSearchResult: false,
          allSearchLoaded,
        })
      } else {
        if (!nextPage) {
          allSearchLoaded = true
        }
        this.setState({
          loadingMoreSearchReplies: false,
          isLoadingNextSearchResult: false,
          allSearchLoaded,
        })
      }
    }
  }

  handleRefresh = () => {
    if (this.props.handleRefreshInbox) {
      this.props.handleRefreshInbox()
    } else if (this.props.handleRefreshArchive) {
      this.props.handleRefreshArchive()
    }

    this.setState({
      isRefreshing: true,
      onEndReached: false,
    })
  }

  renderEmpty = () => {
    if (this.props.fromIpad) {
      return (
        <View
          style={{
            height: windowHeight / 2 - RNSearchBarManager.ComponentHeight,
            alignItems: 'center',
            justifyContent: 'flex-end',
          }}
        >
          <Text
            style={{ fontSize: 16, lineHeight: 20, color: 'rgba(0,0,0,0.4)' }}
          >
            Tidak ada chat
          </Text>
        </View>
      )
    }

    return (
      <EmptyState
        handleOpenTimeMachine={this.handleOpenTimeMachine}
        navigationBarHeight={
          RNSearchBarManager.ComponentHeight + this.props.navigationBarHeight
        }
      />
    )
  }

  markAsRead(messageIDs) {
    if (this.props.markAsRead) {
      this.props.markAsRead(messageIDs)
    }
  }

  handleOpenTimeMachine = () => {
    this.onPressTimeMachine$.next(
      `${TKPReactURLManager.mobileSiteUrl}/inbox-message-old.pl`,
    )
  }

  handleScrolling = ({
    nativeEvent: { contentOffset: { y }, contentSize: { height } },
  }) => {
    if (windowHeight + y >= height) {
      if (!this.state.isLoadingNextPage) {
        if (this.props.dataSource.data.paging_next) {
          this.setState(
            {
              isLoadingNextPage: true,
              currentPage: this.state.currentPage + 1,
            },
            () => {
              this.props.loadNextPage(this.state.currentPage)
            },
          )
        }
      }
    }
  }

  onKeyboardWillShow = ({ endCoordinates: { height } }) => {
    this.setState({
      overlayBottom: height,
    })
  }

  onKeyboardWillHide = () => {
    this.setState({
      overlayBottom: 0,
    })
  }

  /* SEARCH RESULT VOID START HERE */

  handleScrollingSearchResult = ({
    nativeEvent: { contentOffset: { y }, contentSize: { height } },
  }) => {
    if (windowHeight + y >= height) {
      if (
        !this.state.isLoadingNextSearchResult &&
        !this.state.allSearchLoaded
      ) {
        this.setState(
          {
            isLoadingNextSearchResult: true,
          },
          () => {
            if (
              this.props.chatSearch.renderBehaviour === CONTACTS_ONLY &&
              this.props.chatSearch.data[0].nextPage
            ) {
              this.loadMoreSearchAllChat(CONTACTS)
            } else if (
              this.props.chatSearch.renderBehaviour === REPLIES_ONLY &&
              this.props.chatSearch.data[0].nextPage
            ) {
              this.loadMoreSearchAllChat(REPLIES)
            } else if (this.props.chatSearch.data[1].nextPage) {
              this.loadMoreSearchAllChat(REPLIES)
            }
          },
        )
      }
    }
  }

  renderItemSearch = ({ item, section: { renderKey, resultFor }, index }) => (
    <SearchChatCell
      item={item}
      fromIpad={this.props.fromIpad}
      fetchReplyList={this.props.fetchReplyList}
      fetchReplyListForSearch={this.props.fetchReplyListForSearch}
      currentMsgId={this.props.currentMsgId}
      unsetMsgId={this.props.unsetMsgId}
      renderKey={renderKey}
      resultFor={resultFor}
      searchKeyword={this.props.searchKeyword}
      currentUser={{
        full_name: this.props.authInfo.full_name,
        user_id: this.props.authInfo.user_id,
        shop_id: this.props.authInfo.shop_id,
      }}
      setIpadAttributes={this.props.setIpadAttributes}
      unsetIpadAttributes={this.props.unsetIpadAttributes}
    />
  )

  loadMoreSearchAllChat = resultFor => {
    if (resultFor === CONTACTS) {
      if (!this.state.loadingMoreSearchContacts) {
        this.setState(
          {
            loadingMoreSearchContacts: true,
          },
          () => {
            this.props.loadMoreSearchAllChat(
              this.props.searchKeyword,
              1,
              resultFor,
              this.contactsSize,
            )
            this.contactsSize += 10
          },
        )
      }
    } else if (!this.state.loadingMoreSearchReplies) {
      this.setState(
        {
          loadingMoreSearchReplies: true,
        },
        () => {
          this.props.loadMoreSearchAllChat(
            this.props.searchKeyword,
            this.repliesPage,
            resultFor,
            10,
          )
          this.repliesPage += 1
        },
      )
    }
  }

  renderSectionFooterSearch = ({ section: { resultFor, nextPage } }) => {
    if (
      nextPage &&
      this.props.chatSearch.renderBehaviour === BOTH &&
      resultFor === CONTACTS
    ) {
      return (
        <View
          style={{
            height: 40,
            alignItems: 'center',
            justifyContent: 'center',
          }}
        >
          <TouchableOpacity
            onPress={() => this.loadMoreSearchAllChat(CONTACTS)}
          >
            <Text style={{ color: 'rgb(66,181,73)', fontSize: 11 }}>
              Muat lebih banyak
            </Text>
          </TouchableOpacity>
        </View>
      )
    } else if (nextPage) {
      return (
        <View style={{ marginVertical: 10 }}>
          <ActivityIndicator size={'small'} animating />
        </View>
      )
    }

    return null
  }

  renderSectionHeaderSearch = ({ section }) => (
    <View
      style={{
        height: 30,
        justifyContent: 'center',
        backgroundColor: 'white',
      }}
    >
      <Text
        style={{
          paddingLeft: 16,
          fontSize: 11,
          color: 'rgba(0,0,0,0.7)',
        }}
      >
        {section.title}
      </Text>
    </View>
  )

  /* SEARCH RESULT VOID END HERE */

  renderFooter = () => {
    if (_.isEmpty(this.props.dataSource.data.list) && this.props.fromIpad) {
      return null
    }

    if (_.isEmpty(this.props.dataSource.data.list)) {
      return null
    }

    if (!this.props.dataSource.data.paging_next) {
      const message = `Untuk melihat percakapan sebelumnya,\nkunjungi `
      return (
        <View style={{ marginTop: 32, marginBottom: 32 }}>
          <Text style={styles.timeMachineText}>
            {message}
            <Text
              style={styles.timeMachineButton}
              onPress={this.handleOpenTimeMachine}
            >
              Riwayat Pesan
            </Text>
          </Text>
        </View>
      )
    }

    return (
      <View style={{ marginVertical: 10 }}>
        <ActivityIndicator size={'small'} animating />
      </View>
    )
  }

  renderItem = ({ item, index }) => {
    if (typeof item.attributes === 'undefined') {
      return null
    }

    return (
      <ChatCell
        {...item}
        {...this.props.authInfo}
        fromIpad={this.props.fromIpad}
        fetchReplyList={this.props.fetchReplyList}
        currentMsgId={this.props.currentMsgId}
        unsetMsgId={this.props.unsetMsgId}
        editMode={this.props.editMode}
        index={index}
        toggleSelectRow={this.props.toggleSelectRow}
        selectedData={this.props.dataSource.selectedData}
        setIpadAttributes={this.props.setIpadAttributes}
        unsetIpadAttributes={this.props.unsetIpadAttributes}
      />
    )
  }

  deleteSelectedChat = () => {
    if (this.props.deleteSelectedChat) {
      this.props.deleteSelectedChat()
    }
  }

  selectedAllChat = () => {
    if (this.props.toggleSelectAllRow) {
      this.props.toggleSelectAllRow()
    }
  }

  render() {
    /* SEARCH RESULT START HERE */
    if (this.props.chatSearch.renderBehaviour !== null) {
      if (_.isEmpty(this.props.chatSearch.data)) {
        return (
          <View style={{ flex: 1 }}>
            <View
              style={{
                position: 'absolute',
                top: 0,
                left: 0,
                right: 0,
                bottom: this.state.overlayBottom,
                justifyContent: 'center',
                alignItems: 'center',
              }}
              {...this.overlayPanResponder.panHandlers}
            >
              <Image
                source={noResultFound}
                style={{ width: 252, height: 186 }}
                resizeMode={'contain'}
              />
            </View>
            {this.props.chatSearch.loading ? (
              <Overlay
                bottom={this.state.overlayBottom}
                animating={this.props.chatSearch.loading}
                onDismiss={this.props.chatSearchBar.unFocus}
              />
            ) : null}
          </View>
        )
      }

      return (
        <View
          style={[
            styles.container,
            { paddingBottom: this.state.overlayBottom },
          ]}
        >
          <SectionList
            ref={ref => (this.sectionList = ref)}
            renderItem={this.renderItemSearch}
            renderSectionHeader={this.renderSectionHeaderSearch}
            renderSectionFooter={this.renderSectionFooterSearch}
            sections={this.props.chatSearch.data}
            keyExtractor={(item, index) => index}
            onScroll={this.handleScrollingSearchResult}
            onKeyboardWillShow={this.onKeyboardWillShow}
            onKeyboardWillHide={this.onKeyboardWillHide}
            keyboardDismissMode={'on-drag'}
          />
          {this.props.chatSearch.loading ? (
            <Overlay
              bottom={this.state.overlayBottom}
              animating={this.props.chatSearch.loading}
              onDismiss={this.props.chatSearchBar.unFocus}
            />
          ) : null}
        </View>
      )
    }
    /* SEARCH RESULT END HERE */

    return (
      <View style={styles.container}>
        <FlatList
          style={{
            flex: 1,
            marginBottom: this.props.editMode ? 50 : 0,
          }}
          extraData={this.props.editMode}
          data={this.props.dataSource.data.list}
          renderItem={this.renderItem}
          keyExtractor={(item, index) => index}
          refreshing={this.state.isRefreshing}
          onRefresh={this.handleRefresh}
          ListEmptyComponent={this.renderEmpty}
          ListFooterComponent={this.renderFooter}
          onScroll={this.handleScrolling}
          onKeyboardWillShow={this.onKeyboardWillShow}
          onKeyboardWillHide={this.onKeyboardWillHide}
          keyboardDismissMode={'on-drag'}
        />
        {this.props.overlay ? (
          <Overlay
            bottom={this.state.overlayBottom}
            animating={this.props.chatSearch.loading}
            onDismiss={this.props.chatSearchBar.unFocus}
          />
        ) : null}
        {this.props.editMode ? (
          <View
            style={{
              position: 'absolute',
              height: 50,
              left: 0,
              right: 0,
              bottom: 0,
              backgroundColor: 'rgb(249,249,249)',
              borderTopWidth: 1,
              borderTopColor: 'rgb(235,235,235)',
            }}
          >
            <View style={{ flex: 1, flexDirection: 'row' }}>
              <View style={{ flex: 0.25 }}>
                <TouchableOpacity
                  style={{
                    flex: 1,
                    alignItems: 'center',
                    justifyContent: 'center',
                  }}
                  onPress={this.selectedAllChat}
                  disabled={
                    _.keys(this.props.dataSource.selectedData).length === 0
                  }
                >
                  <Text
                    style={
                      _.keys(this.props.dataSource.selectedData).length > 0 ? (
                        styles.textActive
                      ) : (
                        styles.textUnactive
                      )
                    }
                  >
                    Pilih Semua
                  </Text>
                </TouchableOpacity>
              </View>
              <View style={{ flex: 0.5 }} />
              <View style={{ flex: 0.25 }}>
                <TouchableOpacity
                  style={{
                    flex: 1,
                    alignItems: 'center',
                    justifyContent: 'center',
                  }}
                  onPress={this.deleteSelectedChat}
                  disabled={
                    _.keys(this.props.dataSource.selectedData).length === 0
                  }
                >
                  <Text
                    style={
                      _.keys(this.props.dataSource.selectedData).length > 0 ? (
                        styles.textActive
                      ) : (
                        styles.textUnactive
                      )
                    }
                  >
                    Hapus Chat
                  </Text>
                </TouchableOpacity>
              </View>
            </View>
          </View>
        ) : null}
      </View>
    )
  }
}
