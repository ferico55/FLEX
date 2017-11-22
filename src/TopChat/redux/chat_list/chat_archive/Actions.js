import { getChatList } from '@helpers/Requests'
import { Observable } from 'rxjs'
import { unixConverter } from '@helpers/TimeConverters'

// List of types
export const FETCH_ARCHIVE_CHAT_LIST = 'FETCH_ARCHIVE_CHAT_LIST'
export const FETCH_ARCHIVE_CHAT_LIST_SUCCESS = 'FETCH_ARCHIVE_CHAT_LIST_SUCCESS'
export const FETCH_ARCHIVE_CHAT_LIST_LOADED = 'FETCH_ARCHIVE_CHAT_LIST_LOADED'
export const FETCH_ARCHIVE_CHAT_LIST_ERROR = 'FETCH_ARCHIVE_CHAT_LIST_ERROR'

// List of actions
export const fetchArchiveChatList = (filter, page) => ({
  type: FETCH_ARCHIVE_CHAT_LIST,
  payload: {
    tab: 'archive',
    filter,
    page,
  },
})

const fetchArchiveChatListSuccess = payload => ({
  type: FETCH_ARCHIVE_CHAT_LIST_SUCCESS,
  payload,
})

// Epic list
export const getArchiveChatListEpic = action$ =>
  action$.ofType(FETCH_ARCHIVE_CHAT_LIST).mergeMap(action =>
    Observable.from(getChatList(action.payload))
      .map(result => fetchArchiveChatListSuccess(result))
      .catch(result =>
        Observable.of({
          type: FETCH_ARCHIVE_CHAT_LIST_ERROR,
          payload: result,
        }),
      ),
  )
