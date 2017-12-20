import _ from 'lodash'
import {
  FETCH_CHAT_LIST_SUCCESS,
  FETCH_CHAT_LIST_ERROR,
  SORT_LIST_SUCCESS,
  MARK_AS_READ_SUCCESS,
  TOGGLE_SELECT_ROW,
  TOGGLE_SELECT_ALL_ROW,
  TOGGLE_EDIT_MODE,
  DELETE_SELECTED_DATA_SUCCESS,
} from './Actions'
import {
  IS_TYPING_MESSAGE,
  END_TYPING_MESSAGE,
  IS_RECEIVE_MESSAGE,
  SET_MSG_ID,
} from '@TopChatRedux/messages/Actions'

const initialState = {
  data: {
    list: [],
    paging_next: false,
    page: 0,
  },
  isEmpty: null,
  status: null,
  selectedData: {},
  isEditing: false,
  success: null,
  message_error: null,
}

const selectedData = (state, { index, msg_id }) => {
  const findIndex = state[msg_id]
  if (typeof findIndex !== 'undefined') {
    return _.omit(state, msg_id)
  }
  return {
    ...state,
    [msg_id]: index,
  }
}

const selectAllData = (state, toggle) => {
  const data = {}
  if (toggle) {
    state.map((v, k) => {
      data[v.msg_id] = k
    })
  }
  return {
    ...data,
  }
}

export default function chatInboxReducer(state = initialState, actions) {
  switch (actions.type) {
    case FETCH_CHAT_LIST_SUCCESS:
      return {
        ...state,
        ...actions.payload,
      }
    case FETCH_CHAT_LIST_ERROR:
      return {
        ...state,
        ...actions.payload,
      }
    case DELETE_SELECTED_DATA_SUCCESS:
      return {
        ...state,
        data: {
          ...state.data,
          list: actions.payload,
        },
        selectedData: {},
        isEditing: false,
      }
    case TOGGLE_SELECT_ALL_ROW:
      return {
        ...state,
        selectedData: selectAllData(state.data.list, actions.payload),
      }
    case TOGGLE_SELECT_ROW:
      return {
        ...state,
        selectedData: selectedData(state.selectedData, actions.payload),
      }
    case TOGGLE_EDIT_MODE:
      return {
        ...state,
        selectedData: {},
        isEditing: actions.payload,
      }
    case IS_TYPING_MESSAGE:
      const messageID = actions.payload.data.msg_id

      const foundIndex = _.findIndex(
        state.data.list,
        v => v.msg_id === messageID,
      )

      if (foundIndex >= 0) {
        return {
          ...state,
          data: {
            ...state.data,
            list: [
              ...state.data.list.slice(0, foundIndex),
              {
                ...state.data.list[foundIndex],
                is_typing: true,
              },
              ...state.data.list.slice(foundIndex + 1),
            ],
          },
        }
      }

      return state
    case END_TYPING_MESSAGE:
      messageID = actions.payload.data.msg_id

      foundIndex = _.findIndex(state.data.list, v => v.msg_id === messageID)

      if (foundIndex >= 0) {
        return {
          ...state,
          data: {
            ...state.data,
            list: [
              ...state.data.list.slice(0, foundIndex),
              {
                ...state.data.list[foundIndex],
                is_typing: false,
              },
              ...state.data.list.slice(foundIndex + 1),
            ],
          },
        }
      }

      return state
    case IS_RECEIVE_MESSAGE:
      const newObject = {
        attributes: {
          contact: {
            attributes: {
              name: actions.payload.from,
              thumbnail: actions.payload.thumbnail,
            },
            id: actions.payload.from_uid,
          },
          last_reply_msg: actions.payload.message.censored_reply,
          last_reply_time: actions.reply_time,
          unreads: 1,
        },
        msg_id: actions.payload.msg_id,
      }

      if (state.data.list.length === 0) {
        return {
          ...state,
          data: {
            ...state.data,
            list: [newObject],
          },
        }
      }

      messageID = actions.payload.msg_id
      const current_msg_id = actions.current_msg_id
      // const is_current_msg_id_set = actions.is_current_msg_id_set
      const newMessage = actions.payload.message.censored_reply
      foundIndex = _.findIndex(state.data.list, v => v.msg_id === messageID)

      if (foundIndex < 0) {
        return {
          ...state,
          data: {
            ...state.data,
            list: [newObject, ...state.data.list],
          },
        }
      }

      const unread = state.data.list[foundIndex].attributes.unreads

      return {
        ...state,
        data: {
          ...state.data,
          list: [
            ...state.data.list.slice(0, foundIndex),
            {
              ...state.data.list[foundIndex],
              attributes: {
                ...state.data.list[foundIndex].attributes,
                last_reply_msg: newMessage,
                unreads:
                  typeof current_msg_id !== 'undefined' &&
                  current_msg_id === messageID
                    ? 0
                    : unread + 1,
                last_reply_time: actions.reply_time,
              },
            },
            ...state.data.list.slice(foundIndex + 1),
          ],
        },
      }
    case SORT_LIST_SUCCESS:
      return {
        ...state,
        data: {
          ...state.data,
          list: actions.payload,
        },
      }
    case SET_MSG_ID:
      if (typeof state.data !== 'undefined' && state.data.list.length > 0) {
        foundIndex = _.findIndex(
          state.data.list,
          v => v.msg_id === actions.payload,
        )
        if (foundIndex < 0) {
          return state
        }

        return {
          ...state,
          data: {
            ...state.data,
            list: [
              ...state.data.list.slice(0, foundIndex),
              {
                ...state.data.list[foundIndex],
                attributes: {
                  ...state.data.list[foundIndex].attributes,
                  unreads: 0,
                },
              },
              ...state.data.list.slice(foundIndex + 1),
            ],
          },
        }
      }

      return state
    case MARK_AS_READ_SUCCESS:
      return {
        ...state,
        data: {
          ...state.data,
          list: actions.payload,
        },
      }
    case 'RESET_ALL_STATE':
      return initialState
    default:
      return state
  }
}
