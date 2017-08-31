import { combineReducers } from "redux";
import moment from "moment";
import "moment/locale/id";
moment.locale("id");

// DASHBOARD

const topAdsDashboardState = {
  selectedTabIndex: 0,
  isNeedRefresh: false,
  selectedPresetDateRangeIndex: 2,
  startDate: moment().subtract(6, "days"),
  endDate: moment(),
  creditState: {
    isLoading: false,
    creditString: "-"
  },
  dashboardStatisticState: {
    isLoading: false,
    dataSource: {},
    cellData: []
  },
  shopPromoState: {
    isLoading: false,
    dataSource: {}
  },
  totalAdsState: {
    isLoading: false,
    dataSource: {}
  }
};

export function topAdsDashboardReducer(state = topAdsDashboardState, action) {
  switch (action.type) {
    case "CHANGE_DASHBOARD_TAB":
      return {
        ...state,
        selectedTabIndex: state.selectedTabIndex == 0 ? 1 : 0
      };
    case "CHANGE_DATE_RANGE_DASHBOARD":
      return {
        ...state,
        isNeedRefresh: true,
        selectedPresetDateRangeIndex: action.payload.selectedIndex,
        startDate: action.payload.startDate,
        endDate: action.payload.endDate
      };
    case "CHANGE_IS_NEED_REFRESH_DASHBOARD":
      return {
        ...state,
        isNeedRefresh: action.bool
      };
    default:
      return state;
  }
}

export function topAdsDashboardCreditReducer(
  state = topAdsDashboardState.creditState,
  action
) {
  switch (action.type) {
    case "GET_DASHBOARD_CREDIT_LOADING":
      return {
        ...state,
        isLoading: true
      };
    case "GET_DASHBOARD_CREDIT_SUCCESS":
      return {
        ...state,
        isLoading: false,
        creditString: action.payload
      };
    case "GET_DASHBOARD_CREDIT_FAILED":
      return {
        ...state,
        isLoading: false
      };
    default:
      return state;
  }
}

export function topAdsDashboardStatisticReducer(
  state = topAdsDashboardState.dashboardStatisticState,
  action
) {
  switch (action.type) {
    case "GET_DASHBOARD_STATISTIC_LOADING":
      return {
        ...state,
        isLoading: true
      };
    case "GET_DASHBOARD_STATISTIC_SUCCESS":
      const tempPayload = action.payload ? action.payload : {};
      return {
        ...state,
        isLoading: false,
        dataSource: tempPayload.summary,
        cellData: tempPayload.cells
      };
    case "GET_DASHBOARD_STATISTIC_FAILED":
      return {
        ...state,
        isLoading: false
      };
    default:
      return state;
  }
}

export function topAdsDashboardShopPromoReducer(
  state = topAdsDashboardState.shopPromoState,
  action
) {
  switch (action.type) {
    case "GET_DASHBOARD_SHOPPROMO_LOADING":
      return {
        ...state,
        isLoading: true
      };
    case "GET_DASHBOARD_SHOPPROMO_SUCCESS":
      return {
        ...state,
        isLoading: false,
        dataSource: action.payload
      };
    case "GET_DASHBOARD_SHOPPROMO_FAILED":
      return {
        ...state,
        isLoading: false
      };
    default:
      return state;
  }
}

export function topAdsDashboardTotalAdsReducer(
  state = topAdsDashboardState.totalAdsState,
  action
) {
  switch (action.type) {
    case "GET_DASHBOARD_TOTALADS_LOADING":
      return {
        ...state,
        isLoading: true
      };
    case "GET_DASHBOARD_TOTALADS_SUCCESS":
      return {
        ...state,
        isLoading: false,
        dataSource: action.payload
      };
    case "GET_DASHBOARD_TOTALADS_FAILED":
      return {
        ...state,
        isLoading: false
      };
    default:
      return state;
  }
}

// ADD PROMO CREDIT PAGE

const addPromoCreditState = {
  isLoading: false,
  dataSource: [],
  selectedIndex: -1
};

export function addPromoCreditReducer(state = addPromoCreditState, action) {
  switch (action.type) {
    case "CHANGE_SELECTED_INDEX_PROMOCREDIT_LIST":
      return {
        ...state,
        selectedIndex: action.index
      };
    case "GET_PROMOCREDIT_LIST_LOADING":
      return {
        ...state,
        isLoading: true
      };
    case "GET_PROMOCREDIT_LIST_SUCCESS":
      return {
        ...state,
        isLoading: false,
        dataSource: action.payload
      };
    case "GET_PROMOCREDIT_LIST_FAILED":
      return {
        ...state,
        isLoading: false
      };
    default:
      return state;
  }
}

// STAT DETAIL PAGE

const statDetailState = {
  isNeedRefresh: false,
  isLoading: false,
  selectedPresetDateRangeIndex: 2,
  promoType: 1,
  startDate: moment().subtract(6, "days"),
  endDate: moment(),
  selectedTabIndex: 0,
  dataSource: []
};

export function statDetailReducer(state = statDetailState, action) {
  switch (action.type) {
    case "CHANGE_STATDETAIL_TAB":
      return {
        ...state,
        selectedTabIndex: action.index
      };
    case "CHANGE_DATE_RANGE_STATDETAIL":
      return {
        ...state,
        selectedPresetDateRangeIndex: action.payload.selectedIndex,
        startDate: action.payload.startDate,
        endDate: action.payload.endDate,
        isNeedRefresh: true
      };
    case "SET_INITIAL_DATA_STATDETAIL":
      return {
        ...state,
        dataSource: action.payload,
        selectedPresetDateRangeIndex: action.selectedPresetDateRangeIndex,
        promoType: action.promoType,
        startDate: action.startDate,
        endDate: action.endDate
      };
    case "GET_STATDETAIL_STATISTIC_LOADING":
      return {
        ...state,
        isLoading: true
      };
    case "GET_STATDETAIL_STATISTIC_SUCCESS":
      return {
        ...state,
        isLoading: false,
        isNeedRefresh: false,
        dataSource: action.payload ? action.payload.cells ? action.payload.cells : [] : []
      };
    case "GET_STATDETAIL_STATISTIC_FAILED":
      return {
        ...state,
        isLoading: false
      };
    default:
      return state;
  }
}

// PROMO LIST PAGE

const promoListPageState = {
  promoListType: 0, // 0 for group, 1 for product
  isNeedRefresh: true,
  selectedPresetDateRangeIndex: 2,
  startDate: moment().subtract(6, "days"),
  endDate: moment(),
  page: 1,
  keyword: "",
  filter: {
    status: 0,
    tempGroup: {
      group_id: "",
      group_name: ""
    },
    group: {
      group_id: "",
      group_name: ""
    }
  },
  isEndPageReached: false,
  isLoading: false,
  isNoPromo: false,
  isFilterApplied: false,
  isNoSearchResult: false,
  isFailedRequest: false,
  promoListDataSource: []
};

export function promoListPageReducer(state = promoListPageState, action) {
  switch (action.type) {
    case "NEED_REFRESH_PROMOLIST":
      return {
        ...state,
        isNeedRefresh: true
      };
    case "CHANGE_FILTER_PROMOLIST_TEMPGROUP":
      return {
        ...state,
        filter: {
          status: state.filter.status,
          tempGroup: action.filter.tempGroup,
          group: state.filter.group
        }
      };
    case "CHANGE_FILTER_PROMOLIST":
      const isGroupChanged =
        state.filter.tempGroup.group_id != state.filter.group.group_id;
      return {
        ...state,
        isFilterApplied: true,
        isNeedRefresh: true,
        filter: {
          status: action.filter.status,
          tempGroup: state.filter.tempGroup,
          group: isGroupChanged ? state.filter.tempGroup : state.filter.group
        }
      };
    case "RESET_FILTER": //UNUSED FOR NOW
      return {
        ...state,
        isNoPromo: false,
        isFilterApplied: false,
        isNeedRefresh: true,
        filter: {
          status: 0,
          tempGroup: {
            group_id: "",
            group_name: ""
          },
          group: {
            group_id: "",
            group_name: ""
          }
        }
      };
    case "CHANGE_DATE_RANGE_PROMOLIST":
      return {
        ...state,
        isNeedRefresh: true,
        selectedPresetDateRangeIndex: action.payload.selectedIndex,
        startDate: action.payload.startDate,
        endDate: action.payload.endDate
      };
    case "CLEAR_PROMOLIST":
      return {
        ...state,
        isNeedRefresh: true,
        isLoading: false,
        promoListDataSource: [],
        page: 0,
        keyword: "",
        isEndPageReached: false,
        isNoPromo: false,
        isNoSearchResult: false,
        isFailedRequest: false
      };
    case "GET_PROMOLIST_LOADING":
      return {
        ...state,
        isNeedRefresh: false,
        isLoading: true,
        isNoSearchResult: false,
        isNoPromo: false,
        isFailedRequest: false
      };
    case "GET_PROMOLIST_SUCCESS":
      var tempData = state.promoListDataSource.concat(action.payload);
      if (action.pageObject.current <= 1) {
        tempData = action.payload;
      }

      var isEndPage = false;
      if (action.payload.length < action.pageObject.per_page) {
        isEndPage = true;
      }

      var isNoPromo = false;
      if (tempData.length < 1) {
        isNoPromo = true;
      }

      var isNoSearchResult = false;
      if (action.keyword != "" && tempData.length < 1) {
        isNoSearchResult = true;
      }

      return {
        ...state,
        isLoading: false,
        promoListDataSource: tempData,
        page: action.pageObject.current + 1,
        keyword: action.keyword,
        isEndPageReached: isEndPage,
        isNoSearchResult: isNoSearchResult,
        isNoPromo: isNoPromo,
        isFailedRequest: false
      };
    case "GET_PROMOLIST_FAILED":
      return {
        ...state,
        isLoading: false,
        isNoPromo: true,
        isFailedRequest: true
      };
    case "ENDOFPAGE_PROMOLIST_REACHED":
      return {
        ...state,
        isEndPageReached: true
      };
    default:
      return state;
  }
}

// PROMO DETAIL PAGE

const promoDetailPageState = {
  promoType: 0,
  selectedPresetDateRangeIndex: 2,
  startDate: moment().subtract(6, "days"),
  endDate: moment(),
  fixedParams: {},
  promo: {},
  isStatusLoading: false,
  isLoading: false,
  isNoPromo: false,
  isFailedRequest: false
};

export function promoDetailPageReducer(state = promoDetailPageState, action) {
  switch (action.type) {
    case "SET_INITIAL_DATA_PROMODETAIL":
      return {
        ...state,
        promoType: action.promoType,
        promo: action.promo,
        selectedPresetDateRangeIndex: action.selectedPresetDateRangeIndex,
        startDate: action.startDate,
        endDate: action.endDate
      };
    case "CHANGE_DATE_RANGE_PROMODETAIL":
      return {
        ...state,
        selectedPresetDateRangeIndex: action.payload.selectedIndex,
        startDate: action.payload.startDate,
        endDate: action.payload.endDate
      };
    case "CLEAR_PROMODETAIL":
      return {
        ...state,
        isLoading: false,
        isNoPromo: false,
        isFailedRequest: false,
        promo: {}
      };
    case "PATCH_TOGGLE_STATUS_PROMODETAIL_LOADING":
      return {
        ...state,
        isStatusLoading: true
      };
    case "PATCH_TOGGLE_STATUS_PROMODETAIL_SUCCESS":
      var tempAd = null;
      var tempPromo = state.promo;

      if (state.promoType == 0) {
        tempAd =
          action.payload.groups && action.payload.groups.length > 0
            ? action.payload.groups[0]
            : null;
        if (tempAd) {
          tempPromo.group_status = tempAd.status;
          tempPromo.group_status_desc = tempAd.status_desc;
        }
      } else {
        tempAd =
          action.payload.ads && action.payload.ads.length > 0
            ? action.payload.ads[0]
            : null;
        if (tempAd) {
          tempPromo.ad_status = tempAd.status;
          tempPromo.ad_status_desc = tempAd.status_desc;
        }
      }

      return {
        ...state,
        isStatusLoading: false,
        promo: tempPromo
      };
    case "PATCH_TOGGLE_STATUS_PROMODETAIL_FAILED":
      return {
        ...state,
        isStatusLoading: false
      };
    case "GET_PROMODETAIL_LOADING":
      return {
        ...state,
        isLoading: true,
        isNoPromo: false,
        isFailedRequest: false
      };
    case "GET_PROMODETAIL_SUCCESS":
      var tempData = {};
      if (action.payload.length > 0) {
        tempData = action.payload[0];
      } else {
        tempData = action.payload;
      }

      var isNoPromo = false;
      if (!tempData) {
        isNoPromo = true;
      }

      return {
        ...state,
        isLoading: false,
        promo: tempData,
        isNoPromo: false,
        isFailedRequest: false
      };
    case "GET_PROMODETAIL_FAILED":
      return {
        ...state,
        isLoading: false,
        isNoPromo: true,
        isFailedRequest: true
      };
    default:
      return state;
  }
}

const listMultiReducer = reducer => (state = {}, action) => {
  if (!action.key) return state;
  if (action.key.charAt(0) != "L") return state;
  return {
    ...state,
    [action.key]: reducer(state[action.key], action)
  };
};

const detailMultiReducer = reducer => (state = {}, action) => {
  if (!action.key) return state;
  if (action.key.charAt(0) != "D") return state;
  return {
    ...state,
    [action.key]: reducer(state[action.key], action)
  };
};

export default combineReducers({
  topAdsDashboardReducer,
  topAdsDashboardCreditReducer,
  topAdsDashboardStatisticReducer,
  topAdsDashboardShopPromoReducer,
  topAdsDashboardTotalAdsReducer,
  addPromoCreditReducer,
  statDetailReducer,
  promoListPageReducer: listMultiReducer(promoListPageReducer),
  promoDetailPageReducer: detailMultiReducer(promoDetailPageReducer)
})
