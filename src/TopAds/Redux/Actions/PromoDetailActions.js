import {
  requestShopTopAdsInfo,
  requestGroupAds,
  requestProductAds,
  requestPatchToggleStatus,
  requestPatchToggleStatusGroup,
} from '../../Helper/Requests'

export const setInitialDataPromoDetail = ({
  promoType,
  promo,
  selectedPresetDateRangeIndex,
  startDate,
  endDate,
  key,
}) => ({
  type: 'SET_INITIAL_DATA_PROMODETAIL',
  promoType,
  promo,
  selectedPresetDateRangeIndex,
  startDate,
  endDate,
  key,
})

export const getShopAdDetail = ({
  shopId,
  startDate,
  endDate,
  key,
}) => dispatch => {
  dispatch({
    type: 'GET_PROMODETAIL_LOADING',
    key,
  })
  requestShopTopAdsInfo({ shopId, startDate, endDate })
    .then(result => {
      dispatch({
        type: 'GET_PROMODETAIL_SUCCESS',
        payload: result.data,
        key,
      })
    })
    .catch(error => {
      dispatch({
        type: 'GET_PROMODETAIL_FAILED',
        payload: error,
        key,
      })
    })
}

export const getGroupAdDetail = ({
  shopId,
  startDate,
  endDate,
  keyword,
  status,
  groupId,
  key,
}) => dispatch => {
  dispatch({
    type: 'GET_PROMODETAIL_LOADING',
    key,
  })
  requestGroupAds({
    shopId,
    startDate,
    endDate,
    keyword,
    status,
    page: 0,
    groupId,
  })
    .then(result => {
      if (result.page) {
        dispatch({
          type: 'GET_PROMODETAIL_SUCCESS',
          payload: result.data,
          key,
        })
      } else {
        dispatch({
          type: 'GET_PROMODETAIL_FAILED',
          key,
        })
      }
    })
    .catch(error => {
      dispatch({
        type: 'GET_PROMODETAIL_FAILED',
        payload: error,
        key,
      })
    })
}

export const getProductAdDetail = ({
  shopId,
  startDate,
  endDate,
  keyword,
  status,
  groupId,
  adId,
  key,
}) => dispatch => {
  dispatch({
    type: 'GET_PROMODETAIL_LOADING',
    key,
  })
  requestProductAds({
    shopId,
    startDate,
    endDate,
    keyword,
    status,
    groupId,
    page: 0,
    adId,
  })
    .then(result => {
      if (result.page) {
        dispatch({
          type: 'GET_PROMODETAIL_SUCCESS',
          payload: result.data,
          key,
        })
      } else {
        dispatch({
          type: 'GET_PROMODETAIL_FAILED',
          key,
        })
      }
    })
    .catch(error => {
      dispatch({
        type: 'GET_PROMODETAIL_FAILED',
        payload: error,
        key,
      })
    })
}

export const toggleStatusAd = ({ toggleOn, shopId, adId, key }) => dispatch => {
  dispatch({
    type: 'PATCH_TOGGLE_STATUS_PROMODETAIL_LOADING',
    key,
  })
  requestPatchToggleStatus(toggleOn, shopId, adId)
    .then(result => {
      if (result) {
        dispatch({
          type: 'PATCH_TOGGLE_STATUS_PROMODETAIL_SUCCESS',
          payload: result.data,
          key,
        })
      } else {
        dispatch({
          type: 'PATCH_TOGGLE_STATUS_PROMODETAIL_FAILED',
          key,
        })
      }
    })
    .catch(error => {
      dispatch({
        type: 'PATCH_TOGGLE_STATUS_PROMODETAIL_FAILED',
        payload: error,
        key,
      })
    })
}

export const toggleStatusGroupAd = ({
  toggleOn,
  shopId,
  groupId,
  key,
}) => dispatch => {
  dispatch({
    type: 'PATCH_TOGGLE_STATUS_PROMODETAIL_LOADING',
    key,
  })
  requestPatchToggleStatusGroup(toggleOn, shopId, groupId)
    .then(result => {
      if (result) {
        dispatch({
          type: 'PATCH_TOGGLE_STATUS_PROMODETAIL_SUCCESS',
          payload: result.data,
          key,
        })
      } else {
        dispatch({
          type: 'PATCH_TOGGLE_STATUS_PROMODETAIL_FAILED',
          key,
        })
      }
    })
    .catch(error => {
      dispatch({
        type: 'PATCH_TOGGLE_STATUS_PROMODETAIL_FAILED',
        payload: error,
        key,
      })
    })
}
