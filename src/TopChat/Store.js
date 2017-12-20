import { createStore, applyMiddleware } from 'redux'
import { createEpicMiddleware } from 'redux-observable'
import { combineEpics } from 'redux-observable'
import logger from 'redux-logger'
import thunk from 'redux-thunk'

import {
  getReplyListEpic,
  receiveMessageEpic,
  getReplyListCompleteEpic,
  fetchListForSearchEpic,
  mergeReplyListEpic,
  sendReplyWithAPIEpic,
} from '@TopChatRedux/chat_detail/Actions'
import {
  getChatListEpic,
  markAsReadEpic,
  onReceiveNewMessageEpic,
  onSendNewMessageEpic,
  deleteSelectedDataEpic,
} from '@TopChatRedux/chat_list/chat_inbox/Actions'
import {
  searchAllChatEpic,
  loadMoreSearchAllChatEpic,
} from '@TopChatRedux/chat_search/Actions'
import { getArchiveChatListEpic } from '@TopChatRedux/chat_list/chat_archive/Actions'
import {
  webSocketEpic,
  reconnectWebSocketEpic,
  connectedWebSocketEpic,
} from '@TopChatRedux/web_socket/Actions'
import { fetchShopProductsEpic } from '@TopChatRedux/products/Actions'

import AppReducers from '@TopChatRedux/AppReducers'
import socketMiddleware from '@TopChatHelpers/SocketMiddleware'

const epics = combineEpics(
  getReplyListEpic,
  getChatListEpic,
  getArchiveChatListEpic,
  receiveMessageEpic,
  getReplyListCompleteEpic,
  onReceiveNewMessageEpic,
  webSocketEpic,
  reconnectWebSocketEpic,
  markAsReadEpic,
  onSendNewMessageEpic,
  searchAllChatEpic,
  loadMoreSearchAllChatEpic,
  fetchListForSearchEpic,
  mergeReplyListEpic,
  deleteSelectedDataEpic,
  fetchShopProductsEpic,
  connectedWebSocketEpic,
  sendReplyWithAPIEpic,
)

const epicMiddleware = createEpicMiddleware(epics)

let middleware = [socketMiddleware, epicMiddleware, thunk]

if (__DEV__) {
  middleware = [...middleware, logger]
}

const enchancer = applyMiddleware(...middleware)
const store = createStore(AppReducers, enchancer)

export default store
