import moment from 'moment'

const statDetailState = {
  isNeedRefresh: false,
  isLoading: false,
  selectedPresetDateRangeIndex: 2,
  promoType: 1,
  startDate: moment().subtract(6, 'days'),
  endDate: moment(),
  selectedTabIndex: 0,
  dataSource: [],
}

export default function statDetailReducer(state = statDetailState, action) {
  switch (action.type) {
    case 'CHANGE_STATDETAIL_TAB':
      return {
        ...state,
        selectedTabIndex: action.index,
      }
    case 'CHANGE_DATE_RANGE_STATDETAIL':
      return {
        ...state,
        selectedPresetDateRangeIndex: action.payload.selectedIndex,
        startDate: action.payload.startDate,
        endDate: action.payload.endDate,
        isNeedRefresh: true,
      }
    case 'SET_INITIAL_DATA_STATDETAIL':
      console.log(action)
      return {
        ...state,
        dataSource: action.payload,
        selectedPresetDateRangeIndex: action.selectedPresetDateRangeIndex,
        promoType: action.promoType,
        startDate: action.startDate,
        endDate: action.endDate,
      }
    case 'GET_STATDETAIL_STATISTIC_LOADING':
      return {
        ...state,
        isLoading: true,
      }
    case 'GET_STATDETAIL_STATISTIC_SUCCESS':
      return {
        ...state,
        isLoading: false,
        isNeedRefresh: false,
        dataSource: action.payload
          ? action.payload.cells ? action.payload.cells : []
          : [],
      }
    case 'GET_STATDETAIL_STATISTIC_FAILED':
      return {
        ...state,
        isLoading: false,
      }
    default:
      return state
  }
}
