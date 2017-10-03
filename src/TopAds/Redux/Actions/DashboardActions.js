import {
  requestCreditInfo,
  requestDashboardInfo,
  requestShopTopAdsInfo,
  requestTotalAds,
} from '../../Helper/Requests'

export const changeDashboardTab = () => ({
  type: 'CHANGE_DASHBOARD_TAB',
})

export const changeIsNeedRefreshDashboard = theBool => ({
  type: 'CHANGE_IS_NEED_REFRESH_DASHBOARD',
  bool: theBool,
})

export const getDashboardCredit = shopId => dispatch => {
  dispatch({
    type: 'GET_DASHBOARD_CREDIT_LOADING',
  })
  requestCreditInfo(shopId)
    .then(result => {
      dispatch({
        type: 'GET_DASHBOARD_CREDIT_SUCCESS',
        payload: result.data,
      })
    })
    .catch(error => {
      dispatch({
        type: 'GET_DASHBOARD_CREDIT_FAILED',
        payload: error,
      })
    })
}

export const getDashboardStatistic = ({
  shopId,
  type,
  startDate,
  endDate,
}) => dispatch => {
  dispatch({
    type: 'GET_DASHBOARD_STATISTIC_LOADING',
  })

  requestDashboardInfo({ shopId, type, startDate, endDate })
    .then(result => {
      dispatch({
        type: 'GET_DASHBOARD_STATISTIC_SUCCESS',
        payload: result.data,
      })
    })
    .catch(error => {
      dispatch({
        type: 'GET_DASHBOARD_STATISTIC_FAILED',
        payload: error,
      })
    })
}

export const getDashboardShopPromo = ({
  shopId,
  startDate,
  endDate,
}) => dispatch => {
  dispatch({
    type: 'GET_DASHBOARD_SHOPPROMO_LOADING',
  })
  requestShopTopAdsInfo({ shopId, startDate, endDate })
    .then(result => {
      dispatch({
        type: 'GET_DASHBOARD_SHOPPROMO_SUCCESS',
        payload: result.data,
      })
    })
    .catch(error => {
      dispatch({
        type: 'GET_DASHBOARD_SHOPPROMO_FAILED',
        payload: error,
      })
    })
}

export const getDashboardTotalAds = shopId => dispatch => {
  dispatch({
    type: 'GET_DASHBOARD_TOTALADS_LOADING',
  })
  requestTotalAds(shopId)
    .then(result => {
      dispatch({
        type: 'GET_DASHBOARD_TOTALADS_SUCCESS',
        payload: result.data,
      })
    })
    .catch(error => {
      dispatch({
        type: 'GET_DASHBOARD_TOTALADS_FAILED',
        payload: error,
      })
    })
}
