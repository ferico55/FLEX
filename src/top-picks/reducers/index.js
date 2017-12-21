import { combineReducers } from 'redux'
import { PENDING, FULFILLED, REJECTED } from 'redux-promise-middleware'
import { FETCH_TOP_PICKS, RELOADSTATE } from '../actions/index'

const topPicks = (
  state = {
    components: [],
    isFetching: false,
    error: false,
    title: " ",
  },
  action,
) => {
  switch (action.type) {
    case `${FETCH_TOP_PICKS}_${PENDING}`:
      return {
        ...state,
        isFetching: true,
      }
    case `${FETCH_TOP_PICKS}_${FULFILLED}`: {
      const data = action.payload.data.data.components
      const title = action.payload.data.data.title
      return {
        ...state,
        components: data,
        isFetching: false,
        title : title,
      }
    }
    case `${FETCH_TOP_PICKS}_${REJECTED}`:
      return {
        ...state,
        isFetching: false,
        error: true,
      }
    default:
      return state
  }
}

const appReducer = combineReducers({
  topPicks,
})

const rootReducer = (state, action) => {
  if (action.type === RELOADSTATE) {
    state = undefined
  }
  return appReducer(state, action)
}

export default rootReducer
