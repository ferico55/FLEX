import { combineReducers } from 'redux'
import moment from 'moment'
import 'moment/locale/id'

import * as DashboardReducer from './DashboardReducer'
import addCreditReducer from './AddCreditReducer'
import statDetailReducer from './StatDetailReducer'

moment.locale('id')

// Special case for promoList and promoDetail are still in here beacuse of the multi reducer problem
// Will try to separate these two in the future

const promoListPageState = {
  promoListType: 0, // 0 for group, 1 for product
  isNeedRefresh: true,
  selectedPresetDateRangeIndex: 2,
  startDate: moment().subtract(6, 'days'),
  endDate: moment(),
  page: 1,
  keyword: '',
  filter: {
    status: 0,
    group: {
      group_id: '',
      group_name: '',
    },
  },
  tempFilter: {
    status: 0,
    group: {
      group_id: '',
      group_name: '',
    },
  },
  isEndPageReached: false,
  isLoading: false,
  isNoPromo: false,
  isFilterApplied: false,
  isNoSearchResult: false,
  isFailedRequest: false,
  promoListDataSource: [],
}

export function promoListPageReducer(state = promoListPageState, action) {
  console.log('shooottt')
  switch (action.type) {
    case 'NEED_REFRESH_PROMOLIST':
      return {
        ...state,
        isNeedRefresh: true,
      }
    case 'CHANGE_FILTER_PROMOLIST_TEMP_STATUS':
      return {
        ...state,
        tempFilter: {
          status: action.tempFilter.status,
          group: state.tempFilter.group,
        },
      }
    case 'CHANGE_FILTER_PROMOLIST_TEMP_GROUP':
      return {
        ...state,
        tempFilter: {
          status: state.tempFilter.status,
          group: action.tempFilter.group,
        },
      }
    case 'CHANGE_FILTER_PROMOLIST':
      return {
        ...state,
        isFilterApplied: true,
        isNeedRefresh: true,
        filter: state.tempFilter,
      }
    case 'RESET_FILTER': // UNUSED FOR NOW
      return {
        ...state,
        isNoPromo: false,
        isFilterApplied: false,
        isNeedRefresh: true,
        filter: {
          status: 0,
          group: {
            group_id: '',
            group_name: '',
          },
        },
        tempFilter: {
          status: 0,
          group: {
            group_id: '',
            group_name: '',
          },
        },
      }
    case 'CHANGE_DATE_RANGE_PROMOLIST':
      console.log('this day')
      console.log(action)
      return {
        ...state,
        isNeedRefresh: true,
        selectedPresetDateRangeIndex: action.payload.selectedIndex,
        startDate: action.payload.startDate,
        endDate: action.payload.endDate,
      }
    case 'CLEAR_PROMOLIST':
      return {
        ...state,
        isNeedRefresh: true,
        isLoading: false,
        promoListDataSource: [],
        page: 0,
        keyword: '',
        isEndPageReached: false,
        isNoPromo: false,
        isNoSearchResult: false,
        isFailedRequest: false,
      }
    case 'GET_PROMOLIST_LOADING':
      return {
        ...state,
        isNeedRefresh: false,
        isLoading: true,
        isNoSearchResult: false,
        isNoPromo: false,
        isFailedRequest: false,
      }
    case 'GET_PROMOLIST_SUCCESS':
      let tempData = state.promoListDataSource.concat(action.payload)
      if (action.pageObject.current <= 1) {
        tempData = action.payload
      }

      let isEndPage = false
      if (action.payload.length < action.pageObject.per_page) {
        isEndPage = true
      }

      let isNoPromo = false
      if (tempData.length < 1) {
        isNoPromo = true
      }

      let isNoSearchResult = false
      if (action.keyword != '' && tempData.length < 1) {
        isNoSearchResult = true
      }

      return {
        ...state,
        isLoading: false,
        promoListDataSource: tempData,
        page: action.pageObject.current + 1,
        keyword: action.keyword,
        isEndPageReached: isEndPage,
        isNoSearchResult,
        isNoPromo,
        isFailedRequest: false,
      }
    case 'GET_PROMOLIST_FAILED':
      return {
        ...state,
        isLoading: false,
        isNoPromo: true,
        isFailedRequest: true,
      }
    case 'ENDOFPAGE_PROMOLIST_REACHED':
      return {
        ...state,
        isEndPageReached: true,
      }
    default:
      return state
  }
}

const promoDetailPageState = {
  promoType: 0,
  selectedPresetDateRangeIndex: 2,
  startDate: moment().subtract(6, 'days'),
  endDate: moment(),
  fixedParams: {},
  promo: {},
  isStatusLoading: false,
  isLoading: false,
  isNoPromo: false,
  isFailedRequest: false,
}

export function promoDetailPageReducer(state = promoDetailPageState, action) {
  switch (action.type) {
    case 'SET_INITIAL_DATA_PROMODETAIL':
      return {
        ...state,
        promoType: action.promoType,
        promo: action.promo,
        selectedPresetDateRangeIndex: action.selectedPresetDateRangeIndex,
        startDate: action.startDate,
        endDate: action.endDate,
      }
    case 'CHANGE_DATE_RANGE_PROMODETAIL':
      return {
        ...state,
        selectedPresetDateRangeIndex: action.payload.selectedIndex,
        startDate: action.payload.startDate,
        endDate: action.payload.endDate,
      }
    case 'CLEAR_PROMODETAIL':
      return {
        ...state,
        isLoading: false,
        isNoPromo: false,
        isFailedRequest: false,
        promo: {},
      }
    case 'PATCH_TOGGLE_STATUS_PROMODETAIL_LOADING':
      return {
        ...state,
        isStatusLoading: true,
      }
    case 'PATCH_TOGGLE_STATUS_PROMODETAIL_SUCCESS':
      let tempAd = null
      const tempPromo = state.promo

      if (state.promoType == 0) {
        tempAd =
          action.payload.groups && action.payload.groups.length > 0
            ? action.payload.groups[0]
            : null
        if (tempAd) {
          tempPromo.group_status = tempAd.status
          tempPromo.group_status_desc = tempAd.status_desc
        }
      } else {
        tempAd =
          action.payload.ads && action.payload.ads.length > 0
            ? action.payload.ads[0]
            : null
        if (tempAd) {
          tempPromo.ad_status = tempAd.status
          tempPromo.ad_status_desc = tempAd.status_desc
        }
      }

      return {
        ...state,
        isStatusLoading: false,
        promo: tempPromo,
      }
    case 'PATCH_TOGGLE_STATUS_PROMODETAIL_FAILED':
      return {
        ...state,
        isStatusLoading: false,
      }
    case 'GET_PROMODETAIL_LOADING':
      return {
        ...state,
        isLoading: true,
        isNoPromo: false,
        isFailedRequest: false,
      }
    case 'GET_PROMODETAIL_SUCCESS':
      let tempData = {}
      if (action.payload.length > 0) {
        tempData = action.payload[0]
      } else {
        tempData = action.payload
      }

      let isNoPromo = false
      if (!tempData) {
        isNoPromo = true
      }

      return {
        ...state,
        isLoading: false,
        promo: tempData,
        isNoPromo: false,
        isFailedRequest: false,
      }
    case 'GET_PROMODETAIL_FAILED':
      return {
        ...state,
        isLoading: false,
        isNoPromo: true,
        isFailedRequest: true,
      }
    default:
      return state
  }
}

const listMultiReducer = reducer => (state = {}, action) => {
  if (!action.key) {
    return state
  }
  if (action.key.charAt(0) != 'L') {
    return state
  }
  return {
    ...state,
    [action.key]: reducer(state[action.key], action),
  }
}

const detailMultiReducer = reducer => (state = {}, action) => {
  if (!action.key) {
    return state
  }
  if (action.key.charAt(0) != 'D') {
    return state
  }
  return {
    ...state,
    [action.key]: reducer(state[action.key], action),
  }
}

export default combineReducers({
  ...DashboardReducer,
  addCreditReducer,
  statDetailReducer,
  promoListPageReducer: listMultiReducer(promoListPageReducer),
  promoDetailPageReducer: detailMultiReducer(promoDetailPageReducer),
})
