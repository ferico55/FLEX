import { connect } from 'react-redux'
import { bindActionCreators } from 'redux'
import {
  toggleSelectRow,
  deleteSelectedData,
  toggleSelectAllRow,
} from '@TopChatRedux/chat_list/chat_inbox/Actions'
import { loadMoreSearchAllChat } from '@TopChatRedux/chat_search/Actions'
import {
  fetchReplyList,
  fetchReplyListForSearch,
  setIpadAttributes,
  unsetIpadAttributes,
} from '@TopChatRedux/chat_detail/Actions'
import { unsetMsgId } from '@TopChatRedux/messages/Actions'
import ChatListView from './ChatListView'

const mapStateToProps = ({
  chatInbox,
  chatSearch: { fromChatList },
  messages: { current_msg_id },
  webSocket: { connectedToInternet },
}) => ({
  chatInbox,
  chatSearch: fromChatList,
  currentMsgId: current_msg_id,
  connectedToInternet,
})

const mapDispatchToProps = dispatch => ({
  toggleSelectRow: bindActionCreators(toggleSelectRow, dispatch),
  toggleSelectAllRow: bindActionCreators(toggleSelectAllRow, dispatch),
  deleteSelectedData: bindActionCreators(deleteSelectedData, dispatch),
  loadMoreSearchAllChat: bindActionCreators(loadMoreSearchAllChat, dispatch),
  fetchReplyList: bindActionCreators(fetchReplyList, dispatch),
  fetchReplyListForSearch: bindActionCreators(
    fetchReplyListForSearch,
    dispatch,
  ),
  setIpadAttributes: bindActionCreators(setIpadAttributes, dispatch),
  unsetIpadAttributes: bindActionCreators(unsetIpadAttributes, dispatch),
  unsetMsgId: bindActionCreators(unsetMsgId, dispatch),
})

export default connect(mapStateToProps, mapDispatchToProps)(ChatListView)
