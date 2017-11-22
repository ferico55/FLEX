import { getChatList, markRead, moveToTrash } from '@helpers/Requests'
import { Observable } from 'rxjs'
import { unixConverter } from '@helpers/TimeConverters'
import { IS_RECEIVE_MESSAGE, SEND_CHAT_MESSAGE } from '@redux/messages/Actions'
import {
  fetchReplyList,
  setIpadAttributes,
} from '@redux/chat_detail/Actions'
import { ReactInteractionHelper } from 'NativeModules'
import Navigator from 'native-navigation'
import _ from 'lodash'

// List of types
export const FETCH_CHAT_LIST = 'FETCH_CHAT_LIST'
export const FETCH_CHAT_LIST_SUCCESS = 'FETCH_CHAT_LIST_SUCCESS'
export const FETCH_CHAT_LIST_ERROR = 'FETCH_CHAT_LIST_ERROR'
export const FETCH_CHAT_LIST_LOADED = 'FETCH_CHAT_LIST_LOADED'
export const SORT_LIST_SUCCESS = 'SORT_LIST_SUCCESS'

export const MARK_AS_READ = 'MARK_AS_READ'
export const MARK_AS_READ_SUCCESS = 'MARK_AS_READ_SUCCESS'

export const TOGGLE_SELECT_ROW = 'TOGGLE_SELECT_ROW'
export const TOGGLE_SELECT_ALL_ROW = 'TOGGLE_SELECT_ALL_ROW'
export const TOGGLE_EDIT_MODE = 'TOGGLE_EDIT_MODE'
export const DELETE_SELECTED_DATA = 'DELETE_SELECTED_DATA'
export const DELETE_SELECTED_DATA_SUCCESS = 'DELETE_SELECTED_DATA_SUCCESS'

// List of actions
export const fetchChatList = (
  filter,
  page,
  msg_id_applink,
  auth_info,
  from_ipad,
) => ({
  type: FETCH_CHAT_LIST,
  payload: {
    tab: 'inbox',
    filter,
    page,
  },
  msg_id_applink,
  auth_info,
  from_ipad,
})

const fetchChatListSuccess = payload => ({
  type: FETCH_CHAT_LIST_SUCCESS,
  payload,
})

const fetchSortedList = payload => ({
  type: SORT_LIST_SUCCESS,
  payload,
})

export const markAsRead = payload => ({
  type: MARK_AS_READ,
  payload,
})

const markAsReadSuccess = payload => ({
  type: MARK_AS_READ_SUCCESS,
  payload,
})

export const toggleSelectRow = payload => ({
  type: TOGGLE_SELECT_ROW,
  payload,
})

export const toggleEditMode = payload => ({
  type: TOGGLE_EDIT_MODE,
  payload,
})

export const toggleSelectAllRow = payload => ({
  type: TOGGLE_SELECT_ALL_ROW,
  payload,
})

export const deleteSelectedData = () => ({
  type: DELETE_SELECTED_DATA,
})

const pushToDetail = (result, action, { dispatch }) => {
  const msg_id = _.parseInt(action.msg_id_applink)
  const findChat = _.find(result.data.list, ['msg_id', msg_id])
  const auth_info = action.auth_info
  if (!_.isEmpty(findChat)) {
    if (!action.from_ipad) {
      const propsToPass = {
        ...findChat,
        ...auth_info,
      }
      Navigator.push('TopChatDetail', {
        ...propsToPass,
      })
    } else {
      dispatch(fetchReplyList(msg_id))
      dispatch(
        setIpadAttributes({
          shop_id: auth_info.shop_id,
          attributes: findChat.attributes,
        }),
      )
    }
  }
}

// Epic list
export const getChatListEpic = (action$, store) =>
  action$.ofType(FETCH_CHAT_LIST).mergeMap(action =>
    Observable.from(getChatList(action.payload))
      .do(result => {
        if (result.success && !_.isEmpty(action.msg_id_applink)) {
          pushToDetail(result, action, store)
        }
      })
      .map(result => {
        if (!result.success) {
          throw result
        }
        const state = store.getState().chatInbox
        let chatInbox = []
        const convertedList = result.data.list.map((v, k) => ({
          ...v,
          last_reply_time: unixConverter(v.attributes.last_reply_time, 'HH:mm'),
        }))

        if (state.data.list.length > 0 && action.payload.page > 1) {
          chatInbox = [...state.data.list, ...convertedList]
        } else {
          chatInbox = [...convertedList]
        }

        result = {
          ...result,
          data: {
            ...result.data,
            list: [...chatInbox],
            page: action.payload.page,
          },
          isEmpty: _.isEmpty(chatInbox),
        }
        return fetchChatListSuccess(result)
      })
      .catch(result =>
        Observable.of({
          type: FETCH_CHAT_LIST_ERROR,
          payload: result,
        }),
      ),
  )

export const setUnreadMessageEpic = (action$, store) =>
  action$
    .ofType(IS_RECEIVE_MESSAGE)
    .filter(() => store.getState().messages.current_msg_id === null)
    .mapTo({
      type: 'SET_COUNT_UNREAD_MESSAGES',
    })

export const onReceiveNewMessageEpic = (action$, store) =>
  action$
    .ofType(IS_RECEIVE_MESSAGE)
    .map(result => {
      const state = store.getState().chatInbox
      const list = state.data.list
      const messageID = result.payload.msg_id
      const foundIndex = _.findIndex(
        state.data.list,
        v => v.msg_id === messageID,
      )

      if (foundIndex < 0) {
        throw false
      }

      const changedChat = state.data.list[foundIndex]
      const newList = [
        ...list.slice(0, foundIndex),
        ...list.slice(foundIndex + 1),
      ]

      newList.unshift(changedChat)

      return fetchSortedList(newList)
    })
    .catch(() => Observable.empty())

export const onSendNewMessageEpic = (action$, store) =>
  action$
    .ofType(SEND_CHAT_MESSAGE)
    .map(result => {
      const state = store.getState().chatInbox

      const messageID = result.payload.data.message_id
      const foundIndex = _.findIndex(
        state.data.list,
        v => v.msg_id === messageID,
      )

      if (foundIndex < 0) {
        throw false
      }

      const list = state.data.list

      const newChat = {
        ...list[foundIndex],
        attributes: {
          ...list[foundIndex].attributes,
          last_reply_msg: result.payload.data.message,
          last_reply_time: result.reply_time,
        },
      }

      let newList = [
        ...list.slice(0, foundIndex),
        ...list.slice(foundIndex + 1),
      ]

      newList = [newChat, ...newList]

      return fetchSortedList(newList)
    })
    .catch(() => Observable.empty())

export const markAsReadEpic = (action$, store) =>
  action$.ofType(MARK_AS_READ).mergeMap(action =>
    Observable.from(markRead(action.payload))
      .map(result => {
        const state = store.getState().chatInbox
        let list = result.data.list

        result.data.list.map((e, k) => {
          const foundIndex = _.findIndex(
            state.data.list,
            v => v.msg_id === e.msg_id && e.is_success,
          )

          list = [
            ...list.slice(0, foundIndex),
            {
              ...list[foundIndex],
              attributes: {
                ...list[foundIndex].attributes,
                unreads: 0,
              },
            },
          ]
        })
        return markAsReadSuccess(list)
      })
      .catch(result => Observable.of({ type: 'MARK_AS_READ_ERROR', result })),
  )

export const deleteSelectedDataEpic = (action$, store) =>
  action$.ofType(DELETE_SELECTED_DATA).mergeMap(() => {
    const currentMsgId = store.getState().messages.current_msg_id
    const state = store.getState().chatInbox
    const data = state.data.list
    const selectedIndex = _.values(state.selectedData)
    const selectedKey = _.map(_.keys(state.selectedData), _.parseInt)
    return Observable.from(moveToTrash(selectedKey))
      .map(res => {
        if (!res.success) {
          throw res
        }
        const val = _.omit(data, selectedIndex)
        let payload = []
        _.each(val, v => {
          payload = [...payload, v]
        })
        // this approach is only for ipad
        // if user delete the opened chat detail, we must close it and reset state
        if (currentMsgId !== null) {
          const findOpenedMsgId = _.findIndex(
            selectedKey,
            v => v === currentMsgId,
          )
          if (findOpenedMsgId >= 0) {
            // unset msg id && unset ipad attributes
            store.dispatch({ type: 'UNSET_MSG_ID' })
          }
        }
        ReactInteractionHelper.showStickyAlert('Chat berhasil dihapus')
        return {
          type: DELETE_SELECTED_DATA_SUCCESS,
          payload,
        }
      })
      .catch(err => Observable.of({ type: 'DELETE_SELECTED_DATA_ERROR', err }))
  })
