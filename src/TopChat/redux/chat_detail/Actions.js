import { getReplyList, reply } from '@TopChatHelpers/Requests'
import { Observable } from 'rxjs'
import _ from 'lodash'
import { unixConverter } from '@TopChatHelpers/TimeConverters'
import Navigator from 'native-navigation'
import { ReactInteractionHelper } from 'NativeModules'

import {
  setMsgId,
  replaceMessage,
  IS_RECEIVE_MESSAGE,
  MESSAGES_RECEIVED,
  UNSET_MSG_ID,
  SEND_WITH_API,
  SEND_WITH_API_SUCCESS,
  SEND_WITH_API_ERROR,
} from '@TopChatRedux/messages/Actions'

// list of type
export const FETCH_REPLY_LIST = 'FETCH_REPLY_LIST'
export const FETCH_REPLY_LIST_ERROR = 'FETCH_REPLY_LIST_ERROR'
export const FETCH_REPLY_LIST_COMPLETE = 'FETCH_REPLY_LIST_COMPLETE'
export const FETCH_REPLY_LIST_ALL_LOADED = 'FETCH_REPLY_LIST_ALL_LOADED'
export const DUMP_REPLY_LIST = 'DUMP_REPLY_LIST'
export const FETCH_REPLY_LIST_FOR_SEARCH = 'FETCH_REPLY_LIST_FOR_SEARCH'
export const FETCH_REPLY_LIST_FOR_SEARCH_COMPLETE =
  'FETCH_REPLY_LIST_FOR_SEARCH_COMPLETE'
export const FETCH_REPLY_LIST_FOR_SEARCH_ERROR =
  'FETCH_REPLY_LIST_FOR_SEARCH_ERROR'
export const MERGE_REPLY_LIST = 'MERGE_REPLY_LIST'
export const MERGE_REPLY_LIST_COMPLETE = 'MERGE_REPLY_LIST_COMPLETE'
export const RESET_SCROLL_PARAMS = 'RESET_SCROLL_PARAMS'
export const SET_IPAD_ATTRIBUTES = 'SET_IPAD_ATTRIBUTES'
export const UNSET_IPAD_ATTRIBUTES = 'UNSET_IPAD_ATTRIBUTES'

// list of actions
export const fetchReplyList = (messageId, page = 1, per_page = 25) => ({
  type: FETCH_REPLY_LIST,
  payload: messageId,
  page,
  per_page,
})

export const setIpadAttributes = ({ attributes, shop_id }) => ({
  type: SET_IPAD_ATTRIBUTES,
  payload: {
    shop_id,
    attributes,
  },
})

export const unsetIpadAttributes = () => ({
  type: UNSET_IPAD_ATTRIBUTES,
})

const fetchReplyListComplete = (payload, page, msg_id) => ({
  type: FETCH_REPLY_LIST_COMPLETE,
  payload,
  page,
  msg_id,
})

export const fetchReplyListForSearch = (
  messageId,
  reply_id,
  section,
  keyword,
) => ({
  type: FETCH_REPLY_LIST_FOR_SEARCH,
  payload: messageId,
  reply_id,
  section,
  keyword,
})

export const mergeReplyListAfterSearch = (payload, page, next = true) => ({
  type: MERGE_REPLY_LIST,
  payload,
  next,
  page,
})

export const resetScrollParams = () => ({
  type: RESET_SCROLL_PARAMS,
})

const composeData = (res, state) => {
  const newGroupData = []
  const reverseData = _.reverse(res.data.list).map((v, k) => {
    const user_data = _.find(
      res.data.contacts,
      val => val.user_id === v.sender_id,
    )
    return {
      ...v,
      msg: v.msg,
      reply_date: unixConverter(v.reply_time, 'YYYYMMDD'),
      reply_hm: unixConverter(v.reply_time, 'HHmm'),
      user_data,
    }
  })

  reverseData.map(v => {
    newGroupData[v.reply_date] = newGroupData[v.reply_date] || []
    newGroupData[v.reply_date].push(v)
  })

  const reverseGroupData = _.reverse(Object.keys(newGroupData))
  let dataSource = []
  if (state.data.list.length === 0) {
    dataSource = reverseGroupData.map(key => ({
      title: key,
      data: newGroupData[key],
    }))
  } else {
    // check if key of reverseGroupData is already on prev state
    reverseGroupData.map(key => {
      const findIndex = _.findIndex(state.data.list, v => v.title === key)
      if (findIndex >= 0) {
        dataSource = [
          ...state.data.list.slice(0, findIndex),
          {
            ...state.data.list[findIndex],
            data: [...state.data.list[findIndex].data, ...newGroupData[key]],
          },
          ...state.data.list.slice(findIndex + 1),
        ]
      } else {
        const newObject = {
          data: newGroupData[key],
          title: key,
        }
        if (dataSource.length === 0) {
          dataSource = [...state.data.list, newObject]
        } else {
          dataSource = [...dataSource, newObject]
        }
      }
    })
  }

  return (limit = 0, section = null, reply_id = 0) => {
    if (limit > 0) {
      let chunkData = []
      const findIndexBeforeChunk = _.findIndex(dataSource, ['title', section])
      const countBeforeChunk = dataSource[findIndexBeforeChunk].data.length
      const findIndexItemBeforeChunk = _.findIndex(
        dataSource[findIndexBeforeChunk].data,
        ['reply_id', reply_id],
      )
      const getLengthOfChunk = Math.ceil(countBeforeChunk / limit)
      let choosenIndex = null

      for (let i = 1; i <= getLengthOfChunk; i++) {
        if (limit * i > findIndexItemBeforeChunk) {
          choosenIndex = i - 1
          break
        }
      }

      dataSource.map(v => {
        const title = v.title
        if (v.data.length > limit) {
          _.chunk(v.data, limit).map((val, key) => {
            chunkData = [
              ...chunkData,
              {
                data: [...val],
                title,
                choosenIndex: title === section && key === choosenIndex,
              },
            ]
          })
        } else {
          chunkData = [
            ...chunkData,
            {
              ...v,
              choosenIndex: title === section,
            },
          ]
        }
      })

      return chunkData
    }

    return dataSource
  }
}

// EPIC LIST
export const getReplyListEpic = (action$, store) =>
  action$.ofType(FETCH_REPLY_LIST).mergeMap(action =>
    Observable.from(getReplyList(action.payload, action.page, action.per_page))
      .do(res => {
        if (!res) {
          Navigator.pop()
          ReactInteractionHelper.showErrorStickyAlert(
            'Terjadi gangguan pada server',
          )
        }
      })
      .map(res => {
        if (!res.success) {
          throw res
        }
        const state = store.getState().chatDetail
        if (res.data.list !== null) {
          const dataSource = {
            ...res,
            data: {
              ...res.data,
              list: [...composeData(res, state)()],
            },
          }
          return fetchReplyListComplete(dataSource, action.page, action.payload)
        }
        return { type: FETCH_REPLY_LIST_ALL_LOADED }
      })
      .takeUntil(action$.ofType(FETCH_REPLY_LIST))
      .takeUntil(action$.ofType(UNSET_MSG_ID))
      .catch(res => Observable.of({ type: FETCH_REPLY_LIST_ERROR, res })),
  )

export const getReplyListCompleteEpic = (action$, store) =>
  action$
    .ofType(FETCH_REPLY_LIST_COMPLETE)
    .filter(() => {
      const current_msg_id = store.getState().messages.current_msg_id
      return current_msg_id === null
    })
    .map(action => setMsgId(action.msg_id))

export const receiveMessageEpic = (action$, store) =>
  action$
    .ofType(IS_RECEIVE_MESSAGE)
    .filter(
      ({ payload: { msg_id } }) =>
        msg_id === store.getState().messages.current_msg_id,
    )
    .map(action => {
      const contacts = store.getState().chatDetail.data.contacts
      const user_id = _.parseInt(store.getState().webSocket.user_id)
      // sender role
      const role = _.find(contacts, [
        'user_id',
        _.parseInt(action.payload.from_uid),
      ]).role
      // receiver role
      const ourRole = _.find(contacts, ['user_id', user_id]).role
      // check wheter is_opposite or not
      const is_opposite = (senderRole = role, receiverRole = ourRole) => {
        if (receiverRole !== 'User' && senderRole !== 'User') {
          // messages must be opposite
          return false
        }

        return true
      }

      return {
        type: MESSAGES_RECEIVED,
        payload: {
          ...action.payload,
          data: {
            message: action.payload.message.censored_reply,
          },
        },
        reply_time: action.reply_time,
        section: action.section,
        is_opposite: is_opposite(),
        message_is_read: true,
        sender_name: action.payload.from,
        sender_id: action.payload.from_uid,
        role,
      }
    })

export const fetchListForSearchEpic = (action$, store) =>
  action$.ofType(FETCH_REPLY_LIST_FOR_SEARCH).mergeMap(action =>
    Observable.from(getReplyList(action.payload, 1, 0, action.keyword))
      .map(res => {
        if (!res.success) {
          throw res
        }
        const replyId = action.reply_id
        const sectionName = action.section
        const state = store.getState().chatDetail
        const data = composeData(res, state)(25, sectionName, replyId)
        const findIndex = _.findIndex(data, ['choosenIndex', true])
        const findDataIndex = _.findIndex(data[findIndex].data, [
          'reply_id',
          replyId,
        ])
        const dataSource = {
          ...res,
          data: {
            ...res.data,
            list: [data[findIndex]],
            nextPage: findIndex === 0 ? false : findIndex - 1,
            prevPage: findIndex === data.length - 1 ? false : findIndex + 1,
            originIndex: findIndex,
            maxIndex: data.length - 1,
            itemIndex: findDataIndex,
            cacheList: [...data],
            scrollParams: {
              animated: true,
              sectionIndex: 0,
              itemIndex: findDataIndex,
            },
            showLoadingPrev: findIndex !== data.length - 1,
            // showLoadingNext: findIndex === 0,
          },
        }

        return fetchReplyListComplete(dataSource, 1, action.payload)
      })
      .catch(res =>
        Observable.of({ type: FETCH_REPLY_LIST_FOR_SEARCH_ERROR, res }),
      ),
  )

export const mergeReplyListEpic = (action$, store) =>
  action$.ofType(MERGE_REPLY_LIST).mergeMap(action => {
    const state = store.getState().chatDetail

    const list = state.data.list.concat(action.payload.slice(action.page))

    let newData = {
      ...state,
      data: {
        ...state.data,
        list,
        prevPage: false,
        showLoadingPrev: false,
      },
    }

    if (action.next) {
      // next it means unshift
      newData = {
        ...state,
        data: {
          ...state.data,
          list: [
            ...action.payload.slice(0, state.data.originIndex),
            ...state.data.list,
          ],
          nextPage: false,
          showLoadingNext: false,
        },
      }
    }

    return Observable.of(newData)
      .delay(250)
      .map(payload => ({
        type: MERGE_REPLY_LIST_COMPLETE,
        payload,
      }))
  })

export const sendReplyWithAPIEpic = action$ =>
  action$.ofType(SEND_WITH_API).mergeMap(action => {
    const { data: { message, message_id } } = action.payload
    const payload = {
      msg_id: message_id,
      message_reply: message,
    }
    return Observable.from(reply(payload))
      .mergeMap(res => {
        if (!res.success) {
          throw res
        }

        return [
          {
            type: SEND_WITH_API_SUCCESS,
            payload: res.data.is_success,
          },
          replaceMessage(res.data.chat.msg, action.sender_id),
        ]
      })
      .catch(err => Observable.of({ type: SEND_WITH_API_ERROR, err }))
  })
