import { combineReducers } from 'redux'

import chatDetail from '@redux/chat_detail/Reducer'
import chatInbox from '@redux/chat_list/chat_inbox/Reducer'
import chatArchive from '@redux/chat_list/chat_archive/Reducer'
import messages from '@redux/messages/Reducer'
import webSocket from '@redux/web_socket/Reducer'
import chatSearch from '@redux/chat_search/Reducer'
import products from '@redux/products/Reducer'

const AppReducers = combineReducers({
  chatDetail,
  chatInbox,
  chatArchive,
  messages,
  webSocket,
  chatSearch,
  products,
})

export default AppReducers
