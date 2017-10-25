import { ReactInteractionHelper } from 'NativeModules'
import { requestGroupAds, requestProductAds } from '../../Helper/Requests'

export const needRefreshPromoList = key => ({
  type: 'NEED_REFRESH_PROMOLIST',
  key,
})

export const clearPromoList = key => ({
  type: 'CLEAR_PROMOLIST',
  key,
})

export const getGroupAds = ({
  shopId,
  startDate,
  endDate,
  keyword,
  status,
  page,
  groupId,
  key,
}) => dispatch => {
  dispatch({
    type: 'GET_PROMOLIST_LOADING',
    key,
  })

  requestGroupAds({
    shopId,
    startDate,
    endDate,
    keyword,
    status,
    page,
    groupId,
  })
    .then(result => {
      if (result.page) {
        dispatch({
          type: 'GET_PROMOLIST_SUCCESS',
          payload: result.data,
          pageObject: result.page,
          keyword,
          key,
        })
      } else {
        if (result.errors && result.errors.length > 0) {
          ReactInteractionHelper.showErrorStickyAlert(result.errors[0].detail)
        }
        dispatch({
          type: 'GET_PROMOLIST_FAILED',
          key,
        })
      }
    })
    .catch(error => {
      ReactInteractionHelper.showErrorStickyAlert(error.message)
      dispatch({
        type: 'GET_PROMOLIST_FAILED',
        payload: error,
        key,
      })
    })
}

export const getProductAds = ({
  shopId,
  startDate,
  endDate,
  keyword,
  status,
  groupId,
  page,
  key,
}) => dispatch => {
  dispatch({
    type: 'GET_PROMOLIST_LOADING',
    key,
  })
  requestProductAds({
    shopId,
    startDate,
    endDate,
    keyword,
    status,
    groupId,
    page,
    adId: '',
  })
    .then(result => {
      if (result.page) {
        dispatch({
          type: 'GET_PROMOLIST_SUCCESS',
          payload: result.data,
          pageObject: result.page,
          keyword,
          key,
        })
      } else {
        if (result.errors && result.errors.length > 0) {
          ReactInteractionHelper.showErrorStickyAlert(result.errors[0].detail)
        }
        dispatch({
          type: 'GET_PROMOLIST_FAILED',
          key,
        })
      }
    })
    .catch(error => {
      ReactInteractionHelper.showErrorStickyAlert(error.message)
      dispatch({
        type: 'GET_PROMOLIST_FAILED',
        payload: error,
        key,
      })
    })
}
