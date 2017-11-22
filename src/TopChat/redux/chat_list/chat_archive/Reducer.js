import {
  FETCH_ARCHIVE_CHAT_LIST_SUCCESS,
  FETCH_ARCHIVE_CHAT_LIST_ERROR,
} from './Actions'

export default function chatArchiveReducer(state = [], actions) {
  switch (actions.type) {
    case FETCH_ARCHIVE_CHAT_LIST_SUCCESS:
      return actions.payload
    case FETCH_ARCHIVE_CHAT_LIST_ERROR:
      return {
        success: 0,
      }
    default:
      return state
  }
}
