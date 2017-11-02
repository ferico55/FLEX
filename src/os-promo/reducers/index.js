import { combineReducers } from 'redux'
import { PENDING, FULFILLED, REJECTED } from 'redux-promise-middleware'
import {
  FETCH_TOPBANNER,
  FETCH_CATEGORIES,
} from '../actions/index'

const banners = (
  state = {
    isFetching: false,
    status: '',
    items: undefined,
  },
  action,
) => {
  switch (action.type) {
    case `${FETCH_TOPBANNER}_${PENDING}`:
      return {
        ...state,
        isFetching: true,
        status: 'PROCESSING',
      }

    case `${FETCH_TOPBANNER}_${FULFILLED}`:
      if (!action.payload.data) {
        return state
      }

      return {
        ...state,
        isFetching: false,
        status: 'SUCCESS',
        items: action.payload.data.data,
      }

    case `${FETCH_TOPBANNER}_${REJECTED}`:
      return {
        ...state,
        isFetching: false,
        status: 'FAIL',
      }

    default:
      return state
  }
}

const categories = (
  state = {
    items: [],
    isFetching: false,
    pagination: {
      offset: 0,
      limit: 5,
    },
    totalCategories: 0,
    canLoadMore: false,
  },
  action,
) => {
  switch (action.type) {
    case `${FETCH_CATEGORIES}_${PENDING}`:
      return {
        ...state,
        isFetching: true,
      }
    case `${FETCH_CATEGORIES}_${FULFILLED}`: {
      let items = []
      let totalCategories = 0

      if (
        action.payload.data &&
        action.payload.data.data &&
        action.payload.data.data.categories
      ) {
        items = action.payload.data.data.categories
      }

      if (
        action.payload.data &&
        action.payload.data.data &&
        action.payload.data.data.total_categories
      ) {
        totalCategories = action.payload.data.data.total_categories
      }

      const totalItems = [...state.items, ...items]
      return {
        items: totalItems,
        isFetching: false,
        pagination: {
          ...state.pagination,
          offset: totalItems.length,
        },
        totalCategories,
        canLoadMore: totalItems.length < totalCategories,
      }
    }
    case `${FETCH_CATEGORIES}_${REJECTED}`:
      return {
        ...state,
        isFetching: false,
      }
    default:
      return state
  }
}

const appReducer = combineReducers({
  banners,
  categories,
})

const rootReducer = (state, action) => {
  if (action.type === 'RELOADSTATE') {
    state = undefined
  }
  return appReducer(state, action)
}

export default rootReducer
