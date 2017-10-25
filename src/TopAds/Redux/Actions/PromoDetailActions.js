import { ReactInteractionHelper } from 'NativeModules'
import {
  requestShopTopAdsInfo,
  requestGroupAds,
  requestProductAds,
  requestPatchToggleStatus,
  requestPatchToggleStatusGroup,
  requestPatchDeleteGroup,
  requestPatchDeleteProductAd,
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
      ReactInteractionHelper.showErrorStickyAlert(error.message)
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
    keyword: '',
    status: 0,
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
        if (result.errors && result.errors.length > 0) {
          ReactInteractionHelper.showErrorStickyAlert(result.errors[0].detail)
        }
        dispatch({
          type: 'GET_PROMODETAIL_FAILED',
          key,
        })
      }
    })
    .catch(error => {
      ReactInteractionHelper.showErrorStickyAlert(error.message)
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
    keyword: '',
    status: 0,
    groupId: 0,
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
        if (result.errors && result.errors.length > 0) {
          ReactInteractionHelper.showErrorStickyAlert(result.errors[0].detail)
        }
        dispatch({
          type: 'GET_PROMODETAIL_FAILED',
          key,
        })
      }
    })
    .catch(error => {
      ReactInteractionHelper.showErrorStickyAlert(error.message)
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
      ReactInteractionHelper.showErrorStickyAlert(error.message)
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
      ReactInteractionHelper.showErrorStickyAlert(error.message)
      dispatch({
        type: 'PATCH_TOGGLE_STATUS_PROMODETAIL_FAILED',
        payload: error,
        key,
      })
    })
}

export const deleteGroupAd = ({ shopId, groupId, key }) => dispatch => {
  dispatch({
    type: 'DELETE_PROMO_LOADING',
    key,
  })
  requestPatchDeleteGroup(shopId, groupId)
    .then(result => {
      if (result.data) {
        dispatch({
          type: 'DELETE_PROMO_SUCCESS',
          payload: result.data,
          key,
        })
      } else {
        if (result.errors && result.errors.length > 0) {
          ReactInteractionHelper.showErrorStickyAlert(result.errors[0].detail)
        }
        dispatch({
          type: 'DELETE_PROMO_FAILED',
          key,
        })
      }
    })
    .catch(error => {
      ReactInteractionHelper.showErrorStickyAlert(error.message)
      dispatch({
        type: 'DELETE_PROMO_FAILED',
        payload: error,
        key,
      })
    })
}

export const deleteProductAd = ({ shopId, adId, key }) => dispatch => {
  dispatch({
    type: 'DELETE_PROMO_LOADING',
    key,
  })
  requestPatchDeleteProductAd(shopId, adId)
    .then(result => {
      if (result.data) {
        dispatch({
          type: 'DELETE_PROMO_SUCCESS',
          payload: result.data,
          key,
        })
      } else {
        if (result.errors && result.errors.length > 0) {
          ReactInteractionHelper.showErrorStickyAlert(result.errors[0].detail)
        }
        dispatch({
          type: 'DELETE_PROMO_FAILED',
          key,
        })
      }
    })
    .catch(error => {
      ReactInteractionHelper.showErrorStickyAlert(error.message)
      dispatch({
        type: 'DELETE_PROMO_FAILED',
        payload: error,
        key,
      })
    })
}

export const clearPromoDetail = key => ({
  type: 'CLEAR_PROMODETAIL',
  key,
})
