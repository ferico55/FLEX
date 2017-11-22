import types from '@redux/web_socket/Actions'
import { getTime, getUnixTime } from '@helpers/TimeConverters'
import _ from 'lodash'

export const IS_TYPING_MESSAGE = 'IS_TYPING_MESSAGE'
export const END_TYPING_MESSAGE = 'END_TYPING_MESSAGE'

export const IS_RECEIVE_MESSAGE = 'IS_RECEIVE_MESSAGE'
export const MESSAGES_RECEIVED = 'MESSAGES_RECEIVED'

export const SEND_TYPING = 'SEND_TYPING'
export const SEND_CHAT_MESSAGE = 'SEND_CHAT_MESSAGE'

export const SEND_READ_MESSAGE = 'SEND_READ_MESSAGE'

export const SET_MSG_ID = 'SET_MSG_ID'
export const UNSET_MSG_ID = 'UNSET_MSG_ID'

export const SEND_WITH_API = 'SEND_WITH_API'
export const SEND_WITH_API_SUCCESS = 'SEND_WITH_API_SUCCESS'
export const SEND_WITH_API_ERROR = 'SEND_WITH_API_ERROR'

const { SEND_MESSAGE_CODE } = types

export const receiveMessage = (
  payload,
  is_current_msg_id_set,
  current_msg_id,
) => ({
  type: IS_RECEIVE_MESSAGE,
  payload,
  section: getUnixTime('YYYYMMDD').unixFormat(),
  reply_time: getUnixTime().unixNanoSecond,
  is_current_msg_id_set,
  current_msg_id,
})

export const sendMessage = ({
  message_id,
  message,
  sender_name,
  sender_id,
  role,
}) => ({
  type: SEND_CHAT_MESSAGE,
  payload: {
    code: SEND_MESSAGE_CODE,
    data: {
      message_id,
      message,
      start_time: getTime(),
    },
  },
  sender_name,
  sender_id,
  role,
  section: getUnixTime('YYYYMMDD').unixFormat(),
  reply_time: getUnixTime().unixNanoSecond,
  is_opposite: false,
  message_is_read: false,
})

export const sendReplyWithAPI = (payload, sender_id) => ({
  type: SEND_WITH_API,
  payload,
  sender_id,
})

export const replaceMessage = (msg, sender_id) => ({
  type: 'REPLACE_MSG',
  msg,
  reply_id: parseInt(_.uniqueId(`${sender_id}`) - 1, 10),
  section: getUnixTime('YYYYMMDD').unixFormat(),
})

export const isTyping = msg => ({
  type: IS_TYPING_MESSAGE,
  payload: msg,
  is_typing: true,
})

export const endTyping = msg => ({
  type: END_TYPING_MESSAGE,
  payload: msg,
  is_typing: false,
})

export const sendTyping = (msg_id, code) => ({
  type: SEND_TYPING,
  payload: {
    code,
    data: {
      msg_id,
    },
  },
  send_typing: code === 203,
})

export const setMsgId = msg_id => ({
  type: SET_MSG_ID,
  payload: msg_id,
})

export const unsetMsgId = () => ({
  type: UNSET_MSG_ID,
})
