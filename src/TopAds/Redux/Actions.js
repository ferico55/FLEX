import {
  requestCreditInfo,
  requestDashboardInfo,
  requestShopTopAdsInfo,
  requestTotalAds,
  requestPromoCreditList,
  requestGroupAds,
  requestProductAds,
  requestPatchToggleStatusShop,
  requestPatchToggleStatusGroup,
  requestPatchToggleStatusProduct
} from "../Helper/Requests";

import { TKPReactURLManager, ReactNetworkManager } from "NativeModules";

export const changeDateRange = ({
  actionId,
  theSelectedIndex,
  theStartDate,
  theEndDate,
  key
}) => ({
    type: actionId,
    payload: {
      selectedIndex: theSelectedIndex,
      startDate: theStartDate,
      endDate: theEndDate
    },
    key: key
  });

// DASHBOARD

export const changeDashboardTab = () => ({
  type: "CHANGE_DASHBOARD_TAB"
});

export const changeIsNeedRefreshDashboard = theBool => ({
  type: "CHANGE_IS_NEED_REFRESH_DASHBOARD",
  bool: theBool
});

export const getDashboardCredit = shopId => {
  return dispatch => {
    dispatch({
      type: "GET_DASHBOARD_CREDIT_LOADING"
    });
    requestCreditInfo(shopId)
      .then(result => {
        dispatch({
          type: "GET_DASHBOARD_CREDIT_SUCCESS",
          payload: result.data.amount_fmt
        });
      })
      .catch(error => {
        dispatch({
          type: "GET_DASHBOARD_CREDIT_FAILED",
          payload: error
        });
      });
  };
};

export const getDashboardStatistic = ({ shopId, type, startDate, endDate }) => {
  return dispatch => {
    dispatch({
      type: "GET_DASHBOARD_STATISTIC_LOADING"
    });

    requestDashboardInfo({ shopId, type, startDate, endDate })
      .then(result => {
        dispatch({
          type: "GET_DASHBOARD_STATISTIC_SUCCESS",
          payload: result.data
        });
      })
      .catch(error => {
        dispatch({
          type: "GET_DASHBOARD_STATISTIC_FAILED",
          payload: error
        });
      });
  };
};

export const getDashboardShopPromo = ({ shopId, startDate, endDate }) => {
  return dispatch => {
    dispatch({
      type: "GET_DASHBOARD_SHOPPROMO_LOADING"
    });
    requestShopTopAdsInfo({ shopId, startDate, endDate })
      .then(result => {
        dispatch({
          type: "GET_DASHBOARD_SHOPPROMO_SUCCESS",
          payload: result.data
        });
      })
      .catch(error => {
        dispatch({
          type: "GET_DASHBOARD_SHOPPROMO_FAILED",
          payload: error
        });
      });
  };
};

export const getDashboardTotalAds = shopId => {
  return dispatch => {
    dispatch({
      type: "GET_DASHBOARD_TOTALADS_LOADING"
    });
    requestTotalAds(shopId)
      .then(result => {
        dispatch({
          type: "GET_DASHBOARD_TOTALADS_SUCCESS",
          payload: result.data
        });
      })
      .catch(error => {
        dispatch({
          type: "GET_DASHBOARD_TOTALADS_FAILED",
          payload: error
        });
      });
  };
};

// ADD PROMO CREDIT PAGE

export const changePromoListSelectedIndex = index => ({
  type: "CHANGE_SELECTED_INDEX_PROMOCREDIT_LIST",
  index: index
});

export const getPromoCreditList = () => {
  return dispatch => {
    dispatch({
      type: "GET_PROMOCREDIT_LIST_LOADING"
    });
    requestPromoCreditList()
      .then(result => {
        dispatch({
          type: "GET_PROMOCREDIT_LIST_SUCCESS",
          payload: result.data
        });
      })
      .catch(error => {
        dispatch({
          type: "GET_PROMOCREDIT_LIST_FAILED",
          payload: error
        });
      });
  };
};

// STAT DETAIL PAGE

export const changeStatDetailTab = index => ({
  type: "CHANGE_STATDETAIL_TAB",
  index: index
});

export const setInitialDataStatDetail = ({
  dataSource,
  selectedPresetDateRangeIndex,
  promoType,
  startDate,
  endDate
}) => ({
    type: "SET_INITIAL_DATA_STATDETAIL",
    payload: dataSource,
    selectedPresetDateRangeIndex: selectedPresetDateRangeIndex,
    promoType: promoType,
    startDate: startDate,
    endDate: endDate
  });

export const getStatDetailStatistic = ({
  shopId,
  type,
  startDate,
  endDate
}) => {
  return dispatch => {
    dispatch({
      type: "GET_STATDETAIL_STATISTIC_LOADING"
    });
    requestDashboardInfo({ shopId, type, startDate, endDate })
      .then(result => {
        dispatch({
          type: "GET_STATDETAIL_STATISTIC_SUCCESS",
          payload: result.data
        });
      })
      .catch(error => {
        dispatch({
          type: "GET_STATDETAIL_STATISTIC_FAILED",
          payload: error
        });
      });
  };
};

// FILTER GROUP PAGE

export const changeTempGroupFilter = ({ tempGroup, key }) => ({
  type: "CHANGE_FILTER_PROMOLIST_TEMPGROUP",
  filter: {
    tempGroup: tempGroup
  },
  key: key
});

// PROMO LIST PAGE

export const changePromoListFilter = ({ status, key }) => ({
  type: "CHANGE_FILTER_PROMOLIST",
  filter: {
    status: status
  },
  key: key
});

export const needRefreshPromoList = key => ({
  type: "NEED_REFRESH_PROMOLIST",
  key: key
});

export const clearPromoList = key => ({
  type: "CLEAR_PROMOLIST",
  key: key
});

export const resetFilter = key => ({
  type: "RESET_FILTER",
  key: key
});

export const getGroupAds = ({
  shopId,
  startDate,
  endDate,
  keyword,
  status,
  page,
  groupId,
  key
}) => {
  return dispatch => {
    dispatch({
      type: "GET_PROMOLIST_LOADING",
      key: key
    });

    requestGroupAds({
      shopId,
      startDate,
      endDate,
      keyword,
      status,
      page,
      groupId
    })
      .then(result => {
        if (result.page) {
          dispatch({
            type: "GET_PROMOLIST_SUCCESS",
            payload: result.data,
            pageObject: result.page,
            keyword: keyword,
            key: key
          });
        } else {
          dispatch({
            type: "GET_PROMOLIST_FAILED",
            key: key
          });
        }
      })
      .catch(error => {
        dispatch({
          type: "GET_PROMOLIST_FAILED",
          payload: error,
          key: key
        });
      });
  };
};

export const getProductAds = ({
  shopId,
  startDate,
  endDate,
  keyword,
  status,
  groupId,
  page,
  key
}) => {
  return dispatch => {
    dispatch({
      type: "GET_PROMOLIST_LOADING",
      key: key
    });
    requestProductAds({
      shopId,
      startDate,
      endDate,
      keyword,
      status,
      groupId,
      page
    })
      .then(result => {
        if (result.page) {
          dispatch({
            type: "GET_PROMOLIST_SUCCESS",
            payload: result.data,
            pageObject: result.page,
            keyword: keyword,
            key: key
          });
        } else {
          dispatch({
            type: "GET_PROMOLIST_FAILED",
            key: key
          });
        }
      })
      .catch(error => {
        dispatch({
          type: "GET_PROMOLIST_FAILED",
          payload: error,
          key: key
        });
      });
  };
};

// PROMO DETAIL PAGE

export const setInitialDataPromoDetail = ({
  promoType,
  promo,
  selectedPresetDateRangeIndex,
  startDate,
  endDate,
  key
}) => ({
    type: "SET_INITIAL_DATA_PROMODETAIL",
    promoType: promoType,
    promo: promo,
    selectedPresetDateRangeIndex: selectedPresetDateRangeIndex,
    startDate: startDate,
    endDate: endDate,
    key: key
  });

export const getShopAdDetail = ({ shopId, startDate, endDate, key }) => {
  return dispatch => {
    dispatch({
      type: "GET_PROMODETAIL_LOADING",
      key: key
    });
    requestShopTopAdsInfo({ shopId, startDate, endDate })
      .then(result => {
        dispatch({
          type: "GET_PROMODETAIL_SUCCESS",
          payload: result.data,
          key: key
        });
      })
      .catch(error => {
        dispatch({
          type: "GET_PROMODETAIL_FAILED",
          payload: error,
          key: key
        });
      });
  };
};

export const getGroupAdDetail = ({
  shopId,
  startDate,
  endDate,
  keyword,
  status,
  groupId,
  key
}) => {
  return dispatch => {
    dispatch({
      type: "GET_PROMODETAIL_LOADING",
      key: key
    });
    requestGroupAds({
      shopId,
      startDate,
      endDate,
      keyword,
      status,
      page: 0,
      groupId
    })
      .then(result => {
        if (result.page) {
          dispatch({
            type: "GET_PROMODETAIL_SUCCESS",
            payload: result.data,
            key: key
          });
        } else {
          dispatch({
            type: "GET_PROMODETAIL_FAILED",
            key: key
          });
        }
      })
      .catch(error => {
        dispatch({
          type: "GET_PROMODETAIL_FAILED",
          payload: error,
          key: key
        });
      });
  };
};

export const getProductAdDetail = ({
  shopId,
  startDate,
  endDate,
  keyword,
  status,
  groupId,
  key
}) => {
  return dispatch => {
    dispatch({
      type: "GET_PROMODETAIL_LOADING",
      key: key
    });
    requestProductAds({
      shopId,
      startDate,
      endDate,
      keyword,
      status,
      groupId,
      page: 0
    })
      .then(result => {
        if (result.page) {
          dispatch({
            type: "GET_PROMODETAIL_SUCCESS",
            payload: result.data,
            key: key
          });
        } else {
          dispatch({
            type: "GET_PROMODETAIL_FAILED",
            key: key
          });
        }
      })
      .catch(error => {
        dispatch({
          type: "GET_PROMODETAIL_FAILED",
          payload: error,
          key: key
        });
      });
  };
};

export const toggleStatusShopAd = ({ toggleOn, shopId, adId, key }) => {
  return dispatch => {
    dispatch({
      type: "PATCH_TOGGLE_STATUS_PROMODETAIL_LOADING",
      key: key
    });
    requestPatchToggleStatusShop(toggleOn, shopId, adId)
      .then(result => {
        if (result) {
          dispatch({
            type: "PATCH_TOGGLE_STATUS_PROMODETAIL_SUCCESS",
            payload: result.data,
            key: key
          });
        } else {
          dispatch({
            type: "PATCH_TOGGLE_STATUS_PROMODETAIL_FAILED",
            key: key
          });
        }
      })
      .catch(error => {
        dispatch({
          type: "PATCH_TOGGLE_STATUS_PROMODETAIL_FAILED",
          payload: error,
          key: key
        });
      });
  };
};

export const toggleStatusGroupAd = ({ toggleOn, shopId, groupId, key }) => {
  return dispatch => {
    dispatch({
      type: "PATCH_TOGGLE_STATUS_PROMODETAIL_LOADING",
      key: key
    });
    requestPatchToggleStatusGroup(toggleOn, shopId, groupId)
      .then(result => {
        if (result) {
          dispatch({
            type: "PATCH_TOGGLE_STATUS_PROMODETAIL_SUCCESS",
            payload: result.data,
            key: key
          });
        } else {
          dispatch({
            type: "PATCH_TOGGLE_STATUS_PROMODETAIL_FAILED",
            key: key
          });
        }
      })
      .catch(error => {
        dispatch({
          type: "PATCH_TOGGLE_STATUS_PROMODETAIL_FAILED",
          payload: error,
          key: key
        });
      });
  };
};

export const toggleStatusProductAd = ({ toggleOn, shopId, adId, key }) => {
  return dispatch => {
    dispatch({
      type: "PATCH_TOGGLE_STATUS_PROMODETAIL_LOADING",
      key: key
    });
    requestPatchToggleStatusProduct(toggleOn, shopId, adId)
      .then(result => {
        if (result) {
          dispatch({
            type: "PATCH_TOGGLE_STATUS_PROMODETAIL_SUCCESS",
            payload: result.data,
            key: key
          });
        } else {
          dispatch({
            type: "PATCH_TOGGLE_STATUS_PROMODETAIL_FAILED",
            key: key
          });
        }
      })
      .catch(error => {
        dispatch({
          type: "PATCH_TOGGLE_STATUS_PROMODETAIL_FAILED",
          payload: error,
          key: key
        });
      });
  };
};
