import _ from 'lodash'
import { searchChat } from '@helpers/Requests'
import { Observable } from 'rxjs'

export const SEARCH_ALL_CHAT = 'SEARCH_ALL_CHAT'
export const SEARCH_ALL_CHAT_SUCCESS = 'SEARCH_ALL_CHAT_SUCCESS'
export const SEARCH_ALL_CHAT_ERROR = 'SEARCH_ALL_CHAT_ERROR'
export const RESET_SEARCH_ALL_CHAT = 'RESET_SEARCH_ALL_CHAT'
export const LOAD_MORE_SEARCH_ALL_CHAT = 'LOAD_MORE_SEARCH_ALL_CHAT'
export const LOAD_MORE_SEARCH_ALL_CHAT_SUCCESS =
  'LOAD_MORE_SEARCH_ALL_CHAT_SUCCESS'
export const LOAD_MORE_SEARCH_ALL_CHAT_ERROR = 'LOAD_MORE_SEARCH_ALL_CHAT_ERROR'

// renderBehaviour
const BOTH = 'BOTH'
const CONTACTS_ONLY = 'CONTACTS_ONLY'
const REPLIES_ONLY = 'REPLIES_ONLY'
const EMPTY_SEARCH = 'EMPTY_SEARCH'
const CONTACTS = 'CONTACTS'
const REPLIES = 'REPLIES'

export const renderBehaviours = {
  BOTH,
  CONTACTS_ONLY,
  REPLIES_ONLY,
}

export const resultsFor = {
  CONTACTS,
  REPLIES,
}

export const searchAllChat = (payload, page) => ({
  type: SEARCH_ALL_CHAT,
  payload,
  page,
})

export const loadMoreSearchAllChat = (payload, page, concatFor, size) => ({
  type: LOAD_MORE_SEARCH_ALL_CHAT,
  payload,
  page,
  concatFor,
  size,
})

export const resetSearchAllChat = () => ({
  type: RESET_SEARCH_ALL_CHAT,
})

export const searchAllChatEpic = action$ =>
  action$.ofType(SEARCH_ALL_CHAT).mergeMap(action => {
    const searchContacts = Observable.fromPromise(
      searchChat(action.payload, 1, action.page, 10, 'name'),
    )
    const searchReplies = Observable.fromPromise(
      searchChat(action.payload, 1, action.page, 10, 'reply'),
    )
    return Observable.zip(searchContacts, searchReplies)
      .map(res => {
        const contactsResult = res[0].data.contacts
        const repliesResult = res[1].data.replies
        const contactsData = contactsResult.data
        const contactsHasNext = contactsResult.has_next
        const repliesData = repliesResult.data
        const repliesHasNext = repliesResult.has_next

        let renderBehaviour = EMPTY_SEARCH
        let payload = []
        if (!_.isEmpty(contactsData) && !_.isEmpty(repliesData)) {
          payload = [
            {
              data: [...contactsData],
              title: `${contactsData.length} pengguna ditemukan`,
              renderKey: 'highlighted_name',
              nextPage: contactsHasNext,
              resultFor: CONTACTS,
            },
            {
              data: [...repliesData],
              title: `${repliesData.length} chat ditemukan`,
              renderKey: 'last_message',
              nextPage: repliesHasNext,
              resultFor: REPLIES,
            },
          ]
          renderBehaviour = BOTH
        } else if (!_.isEmpty(contactsData)) {
          payload = [
            {
              data: [...contactsData],
              title: `${contactsData.length} pengguna ditemukan`,
              renderKey: 'highlighted_name',
              nextPage: contactsHasNext,
              resultFor: CONTACTS,
            },
          ]
          renderBehaviour = CONTACTS_ONLY
        } else if (!_.isEmpty(repliesData)) {
          payload = [
            {
              data: [...repliesData],
              title: `${repliesData.length} chat ditemukan`,
              renderKey: 'last_message',
              nextPage: repliesHasNext,
              resultFor: REPLIES,
            },
          ]
          renderBehaviour = REPLIES_ONLY
        }

        return {
          type: SEARCH_ALL_CHAT_SUCCESS,
          payload,
          renderBehaviour,
        }
      })
      .catch(err => Observable.of({ type: SEARCH_ALL_CHAT_ERROR, err }))
  })

const byParameter = param => {
  if (param === CONTACTS) {
    return 'name'
  }

  return 'reply'
}

export const loadMoreSearchAllChatEpic = (action$, store) =>
  action$.ofType(LOAD_MORE_SEARCH_ALL_CHAT).mergeMap(action =>
    Observable.from(
      searchChat(
        action.payload,
        1,
        action.page,
        action.size,
        byParameter(action.concatFor),
      ),
    )
      .map(res => {
        const state = store.getState().chatSearch.fromChatList
        const result = res.data[action.concatFor.toLowerCase()]
        let index = 0
        if (state.renderBehaviour === BOTH) {
          if (action.concatFor === REPLIES) {
            index = 1
          }
        }
        const label = action.concatFor === REPLIES ? 'chat' : 'pengguna'
        const total =
          action.concatFor === REPLIES
            ? state.data[index].data.length + result.data.length
            : result.data.length
        const data =
          action.concatFor === REPLIES
            ? [...state.data[index].data, ...result.data]
            : [...result.data]
        const payload = {
          ...state,
          data: [
            ...state.data.slice(0, index),
            {
              ...state.data[index],
              data,
              nextPage:
                action.concatFor === REPLIES
                  ? result.data.length > 0
                  : result.has_next,
              title: `${total} ${label} ditemukan`,
            },
            ...state.data.slice(index + 1),
          ],
        }
        return {
          type: LOAD_MORE_SEARCH_ALL_CHAT_SUCCESS,
          payload,
        }
      })
      .catch(res =>
        Observable.of({ type: LOAD_MORE_SEARCH_ALL_CHAT_ERROR, res }),
      ),
  )
