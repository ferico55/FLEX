import { createStore, applyMiddleware } from 'redux'
import { createEpicMiddleware } from 'redux-observable'
import { combineEpics } from 'redux-observable'
import logger from 'redux-logger'

import {
  getReplyListEpic,
  receiveMessageEpic,
  getReplyListCompleteEpic,
  fetchListForSearchEpic,
  mergeReplyListEpic,
  sendReplyWithAPIEpic
} from '@redux/chat_detail/Actions'
import {
  getChatListEpic,
  markAsReadEpic,
  onReceiveNewMessageEpic,
  onSendNewMessageEpic,
  deleteSelectedDataEpic,
} from '@redux/chat_list/chat_inbox/Actions'
import {
  searchAllChatEpic,
  loadMoreSearchAllChatEpic,
} from '@redux/chat_search/Actions'
import { getArchiveChatListEpic } from '@redux/chat_list/chat_archive/Actions'
import {
  webSocketEpic,
  reconnectWebSocketEpic,
  connectedWebSocketEpic,
} from '@redux/web_socket/Actions'
import { fetchShopProductsEpic } from '@redux/products/Actions'

import AppReducers from '@redux/AppReducers'
import socketMiddleware from '@helpers/SocketMiddleware'

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
  sendReplyWithAPIEpic
)

const epicMiddleware = createEpicMiddleware(epics)


let middleware = [socketMiddleware, epicMiddleware]

if (__DEV__) {
  middleware = [
    ...middleware,
    logger
  ]
}

const enchancer = applyMiddleware(...middleware)
const store = createStore(AppReducers, enchancer)

export default store
