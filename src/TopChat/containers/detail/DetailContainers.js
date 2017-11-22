import { connect } from 'react-redux'
import { bindActionCreators } from 'redux'
import {
  fetchReplyList,
  fetchReplyListForSearch,
  mergeReplyListAfterSearch,
  resetScrollParams,
} from '@redux/chat_detail/Actions'
import { sendTyping, sendMessage, unsetMsgId } from '@redux/messages/Actions'

import { disconnectingWebSocket } from '@redux/web_socket/Actions'

import DetailView from './DetailView'

const mapStateToProps = state => ({
  messages: state.messages,
  chatDetail: state.chatDetail,
  webSocket: state.webSocket,
  listInboxEmpty: state.chatInbox.isEmpty,
})

const mapDispatchToProps = dispatch => ({
  fetchReplyListForSearch: bindActionCreators(
    fetchReplyListForSearch,
    dispatch,
  ),
  fetchReplyList: bindActionCreators(fetchReplyList, dispatch),
  sendTyping: bindActionCreators(sendTyping, dispatch),
  sendMessage: bindActionCreators(sendMessage, dispatch),
  unsetMsgId: bindActionCreators(unsetMsgId, dispatch),
  disconnectWebSocket: bindActionCreators(disconnectingWebSocket, dispatch),
  mergeReplyList: bindActionCreators(mergeReplyListAfterSearch, dispatch),
  resetScrollParams: bindActionCreators(resetScrollParams, dispatch),
})

export default connect(mapStateToProps, mapDispatchToProps)(DetailView)
