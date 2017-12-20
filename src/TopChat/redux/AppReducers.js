import { combineReducers } from 'redux'

import chatDetail from '@TopChatRedux/chat_detail/Reducer'
import chatInbox from '@TopChatRedux/chat_list/chat_inbox/Reducer'
import chatArchive from '@TopChatRedux/chat_list/chat_archive/Reducer'
import messages from '@TopChatRedux/messages/Reducer'
import webSocket from '@TopChatRedux/web_socket/Reducer'
import chatSearch from '@TopChatRedux/chat_search/Reducer'
import products from '@TopChatRedux/products/Reducer'
import chatTemplate from '@TopChatRedux/chat_template/Reducer'

const AppReducers = combineReducers({
  chatDetail,
  chatInbox,
  chatArchive,
  messages,
  webSocket,
  chatSearch,
  products,
  chatTemplate,
})

export default AppReducers
