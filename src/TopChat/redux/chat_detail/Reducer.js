import _ from 'lodash'

import {
  FETCH_REPLY_LIST,
  FETCH_REPLY_LIST_ERROR,
  FETCH_REPLY_LIST_COMPLETE,
  FETCH_REPLY_LIST_ALL_LOADED,
  MERGE_REPLY_LIST,
  MERGE_REPLY_LIST_COMPLETE,
  RESET_SCROLL_PARAMS,
  SET_IPAD_ATTRIBUTES,
  UNSET_IPAD_ATTRIBUTES,
  FETCH_REPLY_LIST_FOR_SEARCH,
} from './Actions'

import {
  IS_RECEIVE_MESSAGE,
  SEND_CHAT_MESSAGE,
  MESSAGES_RECEIVED,
  UNSET_MSG_ID,
} from '@redux/messages/Actions'

const initialState = {
  data: {
    contacts: [],
    list: [],
    paging_next: false,
  },
  server: null,
  server_process_time: null,
  status: null,
  success: 0,
  loading: false,
  ipadAttributes: {
    shop_id: null,
    attributes: {},
    is_set: false,
  },
  searchKeyword: null,
}

export default function chatDetailReducer(state = initialState, actions) {
  switch (actions.type) {
    case FETCH_REPLY_LIST_FOR_SEARCH:
      return {
        ...state,
        loading: true,
        searchKeyword: actions.keyword,
      }
    case FETCH_REPLY_LIST:
      return {
        ...state,
        loading: true,
      }
    case FETCH_REPLY_LIST_COMPLETE:
      return {
        ...state,
        ...actions.payload,
        all_loaded: false,
        loading: false,
      }
    case MERGE_REPLY_LIST:
      return {
        ...state,
        data: {
          ...state.data,
        },
        loading: true,
      }
    case MERGE_REPLY_LIST_COMPLETE:
      return {
        ...actions.payload,
        loading: false,
      }
    case RESET_SCROLL_PARAMS:
      return {
        ...state,
        data: {
          ...state.data,
          scrollParams: undefined,
        },
      }
    case SET_IPAD_ATTRIBUTES:
      return {
        ...state,
        ipadAttributes: {
          ...actions.payload,
          is_set: true,
        },
      }
    case UNSET_IPAD_ATTRIBUTES:
      return {
        ...state,
        ipadAttributes: initialState.ipadAttributes,
      }
    case MESSAGES_RECEIVED:
    case SEND_CHAT_MESSAGE:
      const findSectionIndex = _.findIndex(
        state.data.list,
        v => v.title === actions.section,
      )

      const mockup = {
        msg: actions.payload.data.message.replace(/<br>/gi, '\n'),
        reply_date: actions.section,
        reply_time: actions.reply_time,
        message_is_read: actions.type === SEND_CHAT_MESSAGE ? 'pending' : false,
        is_opposite: actions.is_opposite,
        sender_name: actions.sender_name,
        sender_id: actions.sender_id,
        role: actions.role,
        reply_id: parseInt(_.uniqueId(`${actions.sender_id}`)),
      }

      if (findSectionIndex < 0) {
        const mockupList = {
          data: [mockup],
          title: actions.section,
        }

        const unshiftList = state.data.list
        unshiftList.unshift(mockupList)

        return {
          ...state,
          data: {
            ...state.data,
            list: [...unshiftList],
          },
        }
      }

      const unshiftData = state.data.list[findSectionIndex].data
      unshiftData.unshift(mockup)

      return {
        ...state,
        data: {
          ...state.data,
          list: [
            ...state.data.list.slice(0, findSectionIndex),
            {
              ...state.data.list[findSectionIndex],
              data: [...unshiftData],
            },
            ...state.data.list.slice(findSectionIndex + 1),
          ],
        },
      }
    case 'REPLACE_MSG':
      findSectionIndex = _.findIndex(
        state.data.list,
        v => v.title === actions.section,
      )

      const findItemIndex = _.findIndex(
        state.data.list[findSectionIndex].data,
        v => v.reply_id === actions.reply_id,
      )

      return {
        ...state,
        data: {
          ...state.data,
          list: [
            ...state.data.list.slice(0, findSectionIndex),
            {
              ...state.data.list[findSectionIndex],
              data: [
                ...state.data.list[findSectionIndex].data.slice(
                  0,
                  findItemIndex,
                ),
                {
                  ...state.data.list[findSectionIndex].data[findItemIndex],
                  msg: actions.msg,
                  message_is_read: false,
                },
                ...state.data.list[findSectionIndex].data.slice(
                  findItemIndex + 1,
                ),
              ],
            },
            ...state.data.list.slice(findSectionIndex + 1),
          ],
        },
      }

      return state
    case 'CHANGE_READ_STATUS':
      if (state.success) {
        let remakeData = state.data.list[0]
        const filterData = _.filter(
          remakeData.data,
          v => !v.is_opposite && !v.message_is_read,
        )
        filterData.map((v, index) => {
          if (!v.message_is_read && !v.is_opposite) {
            remakeData = {
              ...remakeData,
              data: [
                ...remakeData.data.slice(0, index),
                {
                  ...remakeData.data[index],
                  message_is_read: true,
                },
                ...remakeData.data.slice(index + 1),
              ],
            }
          }
        })

        return {
          ...state,
          data: {
            ...state.data,
            list: [
              ...state.data.list.slice(0, 0),
              {
                ...remakeData,
              },
              ...state.data.list.slice(0 + 1),
            ],
          },
        }
      }

      return state
    case FETCH_REPLY_LIST_ALL_LOADED:
      return {
        ...state,
        all_loaded: true,
      }
    case FETCH_REPLY_LIST_ERROR:
      return {
        ...state,
        success: 0,
        all_loaded: false,
      }
    case UNSET_MSG_ID:
      return initialState
    default:
      return state
  }
}
