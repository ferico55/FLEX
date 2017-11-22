import _ from 'lodash'

import {
  IS_TYPING_MESSAGE,
  END_TYPING_MESSAGE,
  SEND_CHAT_MESSAGE,
  SET_MSG_ID,
  UNSET_MSG_ID,
} from './Actions'

const initialState = {
  is_typing: false,
  send_typing: false,
  data: {},
  sender_name: '',
  current_msg_id: null,
  role: '',
  shop_profile: {
    shop_id: null,
    shop_domain: null,
    shop_name: null,
  },
}

export default function messagesReducer(state = initialState, actions) {
  switch (actions.type) {
    case SET_MSG_ID:
      return {
        ...state,
        current_msg_id: actions.payload,
      }
    case UNSET_MSG_ID:
      return {
        ...state,
        current_msg_id: null,
      }
    case IS_TYPING_MESSAGE:
      return {
        ...state,
        is_typing: actions.is_typing,
        data: actions.payload,
      }
    case END_TYPING_MESSAGE:
      return {
        ...state,
        is_typing: actions.is_typing,
        data: actions.payload,
      }
    case SEND_CHAT_MESSAGE:
      return {
        ...state,
        sender_name: actions.sender_name,
        role: actions.role,
      }
    default:
      return state
  }
}
