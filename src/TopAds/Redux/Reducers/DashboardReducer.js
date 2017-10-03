import moment from 'moment'

const topAdsDashboardState = {
  selectedTabIndex: 0,
  isNeedRefresh: false,
  selectedPresetDateRangeIndex: 2,
  startDate: moment().subtract(6, 'days'),
  endDate: moment(),
  creditState: {
    isLoading: false,
    creditString: '-',
    credit: 0,
  },
  dashboardStatisticState: {
    isLoading: false,
    dataSource: {},
    cellData: [],
  },
  shopPromoState: {
    isLoading: false,
    dataSource: {},
  },
  totalAdsState: {
    isLoading: false,
    dataSource: {},
  },
}

export function topAdsDashboardReducer(state = topAdsDashboardState, action) {
  switch (action.type) {
    case 'CHANGE_DASHBOARD_TAB':
      return {
        ...state,
        selectedTabIndex: state.selectedTabIndex == 0 ? 1 : 0,
      }
    case 'CHANGE_DATE_RANGE_DASHBOARD':
      return {
        ...state,
        isNeedRefresh: true,
        selectedPresetDateRangeIndex: action.payload.selectedIndex,
        startDate: action.payload.startDate,
        endDate: action.payload.endDate,
      }
    case 'CHANGE_IS_NEED_REFRESH_DASHBOARD':
      return {
        ...state,
        isNeedRefresh: action.bool,
      }
    default:
      return state
  }
}

export function topAdsDashboardCreditReducer(
  state = topAdsDashboardState.creditState,
  action,
) {
  switch (action.type) {
    case 'GET_DASHBOARD_CREDIT_LOADING':
      return {
        ...state,
        isLoading: true,
      }
    case 'GET_DASHBOARD_CREDIT_SUCCESS':
      return {
        ...state,
        isLoading: false,
        creditString: action.payload.amount_fmt,
        credit: action.payload.amount,
      }
    case 'GET_DASHBOARD_CREDIT_FAILED':
      return {
        ...state,
        isLoading: false,
      }
    default:
      return state
  }
}

export function topAdsDashboardStatisticReducer(
  state = topAdsDashboardState.dashboardStatisticState,
  action,
) {
  switch (action.type) {
    case 'GET_DASHBOARD_STATISTIC_LOADING':
      return {
        ...state,
        isLoading: true,
      }
    case 'GET_DASHBOARD_STATISTIC_SUCCESS':
      const tempPayload = action.payload ? action.payload : {}
      return {
        ...state,
        isLoading: false,
        dataSource: tempPayload.summary,
        cellData: tempPayload.cells,
      }
    case 'GET_DASHBOARD_STATISTIC_FAILED':
      return {
        ...state,
        isLoading: false,
      }
    default:
      return state
  }
}

export function topAdsDashboardShopPromoReducer(
  state = topAdsDashboardState.shopPromoState,
  action,
) {
  switch (action.type) {
    case 'GET_DASHBOARD_SHOPPROMO_LOADING':
      return {
        ...state,
        isLoading: true,
      }
    case 'GET_DASHBOARD_SHOPPROMO_SUCCESS':
      return {
        ...state,
        isLoading: false,
        dataSource: action.payload,
      }
    case 'GET_DASHBOARD_SHOPPROMO_FAILED':
      return {
        ...state,
        isLoading: false,
      }
    default:
      return state
  }
}

export function topAdsDashboardTotalAdsReducer(
  state = topAdsDashboardState.totalAdsState,
  action,
) {
  switch (action.type) {
    case 'GET_DASHBOARD_TOTALADS_LOADING':
      return {
        ...state,
        isLoading: true,
      }
    case 'GET_DASHBOARD_TOTALADS_SUCCESS':
      return {
        ...state,
        isLoading: false,
        dataSource: action.payload,
      }
    case 'GET_DASHBOARD_TOTALADS_FAILED':
      return {
        ...state,
        isLoading: false,
      }
    default:
      return state
  }
}
