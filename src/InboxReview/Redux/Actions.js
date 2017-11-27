import { TKPReactURLManager, ReactNetworkManager } from 'NativeModules'
import { Image } from 'react-native'

export const requestReviewList = params => {
  if (params.page < 1) {
    return new Promise((resolve, reject) => {
      reject()
    })
  }
  return ReactNetworkManager.request({
    method: 'GET',
    baseUrl: TKPReactURLManager.v4Url,
    path: '/reputationapp/reputation/api/v1/inbox',
    params,
  })
}

export const setFilter = (params, updatedParams, pageIndex) => dispatch => {
  const newParams = {
    ...params,
    ...updatedParams,
    page: 1,
  }
  dispatch({
    type: 'SET_FILTER',
    newParams,
    pageIndex,
    page: 1,
  })
  dispatch({
    type: 'RESET_INVOICE',
  })

  requestReviewList(newParams)
    .then(result => {
      const inboxReputations = result.data.inbox_reputation.map(reputation => {
        Image.prefetch(reputation.reviewee_data.reviewee_picture)
        if (reputation.reviewee_data.reviewee_shop_badge) {
          Image.prefetch(
            reputation.reviewee_data.reviewee_shop_badge.reputation_badge_url,
          )
        }
        return {
          ...reputation,
          shop_id: `${reputation.shop_id}`,
          user_id: `${reputation.user_id}`,
        }
      })
      const response = {
        ...result,
        data: {
          ...result.data,
          inbox_reputation: inboxReputations,
        },
      }
      dispatch({
        type: 'GET_REVIEW_LIST_SUCCESS',
        payload: response.data.inbox_reputation,
        pageIndex,
        hasNext: response.data.paging.has_next,
      })
    })
    .catch(_ => {
      dispatch({
        type: 'GET_REVIEW_LIST_FAILED',
        pageIndex,
      })
    })
}

export const updateParams = (params, updatedParams, pageIndex) => dispatch => {
  const newParams = {
    ...params,
    ...updatedParams,
  }
  dispatch({
    type: 'UPDATE_PARAMS',
    newParams,
    pageIndex,
  })

  requestReviewList(newParams)
    .then(result => {
      const inboxReputations = result.data.inbox_reputation.map(reputation => {
        Image.prefetch(reputation.reviewee_data.reviewee_picture)
        if (reputation.reviewee_data.reviewee_shop_badge) {
          Image.prefetch(
            reputation.reviewee_data.reviewee_shop_badge.reputation_badge_url,
          )
        }
        return {
          ...reputation,
          shop_id: `${reputation.shop_id}`,
          user_id: `${reputation.user_id}`,
        }
      })
      const response = {
        ...result,
        data: {
          ...result.data,
          inbox_reputation: inboxReputations,
        },
      }
      dispatch({
        type: 'GET_REVIEW_LIST_SUCCESS',
        payload: response.data.inbox_reputation,
        pageIndex,
        hasNext: response.data.paging.has_next,
      })
    })
    .catch(_ => {
      dispatch({
        type: 'GET_REVIEW_LIST_FAILED',
        pageIndex,
      })
    })
}

export const setParams = (params, pageIndex) => dispatch => {
  const p = {
    ...params,
    page: 1,
  }
  dispatch({
    type: 'SET_PARAMS',
    params: p,
    pageIndex,
  })

  requestReviewList(p)
    .then(result => {
      const inboxReputations = result.data.inbox_reputation.map(reputation => {
        Image.prefetch(reputation.reviewee_data.reviewee_picture)
        if (reputation.reviewee_data.reviewee_shop_badge) {
          Image.prefetch(
            reputation.reviewee_data.reviewee_shop_badge.reputation_badge_url,
          )
        }
        return {
          ...reputation,
          shop_id: `${reputation.shop_id}`,
          user_id: `${reputation.user_id}`,
        }
      })
      const response = {
        ...result,
        data: {
          ...result.data,
          inbox_reputation: inboxReputations,
        },
      }
      dispatch({
        type: 'GET_REVIEW_LIST_SUCCESS',
        payload: response.data.inbox_reputation,
        pageIndex,
        hasNext: response.data.paging.has_next,
      })
    })
    .catch(err => {
      console.log(err)
      dispatch({
        type: 'GET_REVIEW_LIST_FAILED',
        pageIndex,
      })
    })
}

export const setInvoice = (item, pageIndex) => ({
  type: 'SET_INVOICE',
  item,
  pageIndex,
})

export const resetInvoice = () => ({
  type: 'RESET_INVOICE',
})

export const changeInvoicePage = pageIndex => ({
  type: 'CHANGE_INVOICE_PAGE',
  pageIndex,
})

export const disableInteraction = () => ({
  type: 'DISABLE_INTERACTION',
})

export const enableInteraction = () => ({
  type: 'ENABLE_INTERACTION',
})

export const disableOnboardingScroll = () => ({
  type: 'DISABLE_ONBOARDING_SCROLL',
})

export const enableOnboardingScroll = () => ({
  type: 'ENABLE_ONBOARDING_SCROLL',
})

export const setLastPage = pageIndex => ({
  type: 'SET_LAST_PAGE',
  pageIndex,
})

export const addImage = image => ({
  type: 'ADD_IMAGE',
  image,
})

export const addUploadedImages = (images, descriptions) => ({
  type: 'ADD_UPLOADED_IMAGE',
  images,
  descriptions,
})

export const updatePreviewImage = (uri, index, description) => ({
  type: 'UPDATE_PREVIEW_IMAGE',
  uri,
  index,
  description,
})

export const removeCurrentImage = () => ({
  type: 'REMOVE_CURRENT_IMAGE',
})

export const changeDescription = description => ({
  type: 'CHANGE_DESCRIPTION_TEXT',
  description,
})

export const removeAllImages = () => ({
  type: 'REMOVE_ALL_IMAGES',
})
