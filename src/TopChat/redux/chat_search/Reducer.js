import {
  SEARCH_ALL_CHAT,
  SEARCH_ALL_CHAT_SUCCESS,
  RESET_SEARCH_ALL_CHAT,
  LOAD_MORE_SEARCH_ALL_CHAT_SUCCESS,
} from './Actions'

const initialState = {
  fromChatList: {
    loading: false,
    data: [],
    success: 0,
    renderBehaviour: null,
  },
  fromChatDetail: {},
}

export default function chatSearchReducer(state = initialState, actions) {
  switch (actions.type) {
    case SEARCH_ALL_CHAT:
      return {
        ...state,
        fromChatList: {
          ...state.fromChatList,
          loading: true,
        },
      }
    case SEARCH_ALL_CHAT_SUCCESS:
      return {
        ...state,
        fromChatList: {
          data: [...actions.payload],
          loading: false,
          success: 1,
          renderBehaviour: actions.renderBehaviour,
        },
      }
    case RESET_SEARCH_ALL_CHAT:
      return initialState
    case LOAD_MORE_SEARCH_ALL_CHAT_SUCCESS:
      return {
        ...state,
        fromChatList: {
          ...actions.payload,
        },
      }
    default:
      return state
  }
}
