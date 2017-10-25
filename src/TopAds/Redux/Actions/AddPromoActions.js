import { ReactInteractionHelper } from 'NativeModules'
import {
  requestProductList,
  requestPostCreateGroupAds,
  requestPostCreateAds,
  requestGetGroupDetail,
  requestGetProductAdDetail,
  requestPatchGroupAds,
  requestPatchProductAds,
  requestPatchMoveProductAd,
  requestGetSuggestionPrice,
} from '../../Helper/Requests'

export const changeGroupTypeAddPromo = index => {
  let stepCount = 0
  if (index === 0) {
    stepCount = 3
  } else if (index === 1) {
    stepCount = 1
  } else if (index === 2) {
    stepCount = 2
  }

  return {
    type: 'CHANGE_GROUPTYPE_ADDPROMO',
    groupType: index,
    stepCount,
  }
}

export const resetProgressAddPromo = () => ({
  type: 'RESET_PROGRESS_ADDPROMO',
})

export const setNewGroupNameAddPromo = name => ({
  type: 'SET_NEWGROUPNAME_ADDPROMO',
  name,
})

export const setExistingGroupAddPromo = group => ({
  type: 'SET_EXISTINGGROUP_ADDPROMO',
  group,
})

export const getProductListAddPromo = ({
  shopId,
  keyword,
  page,
  promotedStatus,
  etalase,
}) => dispatch => {
  dispatch({
    type: 'GET_PRODUCTDATASOURCE_ADDPROMO_LOADING',
  })
  requestProductList({ shopId, keyword, start: page, promotedStatus, etalase })
    .then(result => {
      if (!result.eof && result.data.length < 1) {
        dispatch({
          type: 'GET_PRODUCTDATASOURCE_ADDPROMO_SUCCESS',
          payload: result.data,
          eof: result.eof,
          page,
          keyword,
        })
      } else {
        dispatch({
          type: 'GET_PRODUCTDATASOURCE_ADDPROMO_SUCCESS',
          payload: result.data,
          eof: result.eof,
          page,
          keyword,
        })
      }
    })
    .catch(error => {
      ReactInteractionHelper.showErrorStickyAlert(error.message)
      dispatch({
        type: 'GET_PRODUCTDATASOURCE_ADDPROMO_FAILED',
        payload: error,
      })
    })
}

export const setSelectedProductsAddPromo = products => ({
  type: 'SET_SELECTEDPRODUCTS_ADDPROMO',
  products,
})

export const saveSelectedProductsAddPromo = () => ({
  type: 'SAVE_SELECTEDPRODUCTS_ADDPROMO',
})

export const getSuggestionPrice = (shopId, isGroup, idArray) => dispatch => {
  dispatch({
    type: 'GET_SUGGESTION_PRICE_LOADING',
  })
  requestGetSuggestionPrice(shopId, isGroup, idArray)
    .then(result => {
      if (result.data && result.data.length > 0) {
        dispatch({
          type: 'GET_SUGGESTION_PRICE_SUCCESS',
          payload: result.data[0],
        })
      } else {
        if (result.errors && result.errors.length > 0) {
          ReactInteractionHelper.showErrorStickyAlert(result.errors[0].detail)
        }
        dispatch({
          type: 'GET_SUGGESTION_PRICE_FAILED',
        })
      }
    })
    .catch(error => {
      ReactInteractionHelper.showErrorStickyAlert(error.message)
      dispatch({
        type: 'GET_SUGGESTION_PRICE_FAILED',
      })
    })
}

export const setMaxPriceAddPromo = price => ({
  type: 'SET_MAXPRICE_ADDPROMO',
  price,
})

export const setBudgetTypeAddPromo = index => ({
  type: 'CHANGE_BUDGETTYPE_ADDPROMO',
  budgetType: index,
})

export const setBudgetPerDayAddPromo = budget => ({
  type: 'SET_BUDGETPERDAY_ADDPROMO',
  budget,
})

export const changeScheduleTypeAddPromo = index => ({
  type: 'CHANGE_SCHEDULETYPE_ADDPROMO',
  scheduleType: index,
})

export const setScheduleAddPromo = (startDate, endDate) => ({
  type: 'SET_SCHEDULE_ADDPROMO',
  startDate,
  endDate,
})

export const postAddPromoGroup = ({
  newGroupName,
  shopId,
  maxPrice,
  budgetPerDay,
  budgetType,
  scheduleType,
  startDate,
  endDate,
  selectedProducts,
}) => dispatch => {
  dispatch({
    type: 'POST_ADDGROUP_ADDPROMO_LOADING',
  })

  const theAds = selectedProducts.map(product => ({
    item_id: `${product.product_id}`,
    ad_type: '1',
    ad_id: `${product.ad_id}`,
    group_id: '0',
  }))

  const englishStartDate = startDate
  const englishEndDate = endDate
  englishStartDate.locale('en')
  englishEndDate.locale('en')

  const params = {
    group_name: newGroupName,
    shop_id: `${shopId}`,
    price_bid: maxPrice,
    price_daily: budgetPerDay,
    group_budget: `${budgetType}`,
    group_schedule: `${scheduleType}`,
    group_start_date: englishStartDate.format('DD/MM/YYYY'),
    group_start_time: englishStartDate.format('hh:mm A'),
    group_end_date: englishEndDate.format('DD/MM/YYYY'),
    group_end_time: englishEndDate.format('hh:mm A'),
    group_total: `${theAds.length}`,
    ads: theAds,
  }

  requestPostCreateGroupAds(params)
    .then(result => {
      if (!result.data && result.errors && result.errors.length > 0) {
        ReactInteractionHelper.showErrorStickyAlert(result.errors[0].detail)
      }
      dispatch({
        type: 'POST_ADDGROUP_ADDPROMO_SUCCESS',
        isDonePost: !!result.data,
        payload: result.data,
      })
    })
    .catch(error => {
      ReactInteractionHelper.showErrorStickyAlert(error.message)
      dispatch({
        type: 'POST_ADDGROUP_ADDPROMO_FAILED',
        payload: error,
      })
    })
}

export const postAddPromo = ({
  shopId,
  groupId,
  selectedProducts,
  maxPrice,
  scheduleType,
  startDate,
  endDate,
  budgetType,
  budgetPerDay,
}) => dispatch => {
  dispatch({
    type: 'POST_ADDGROUP_ADDPROMO_LOADING',
  })

  const englishStartDate = startDate
  const englishEndDate = endDate
  englishStartDate.locale('en')
  englishEndDate.locale('en')

  const theAds = selectedProducts.map(product => ({
    ad_id: `${product.ad_id}`,
    group_id: `${groupId}`,
    shop_id: `${shopId}`,
    item_id: `${product.product_id}`,
    price_bid: maxPrice,
    ad_type: '1',
    ad_schedule: `${scheduleType}`,
    ad_start_date: englishStartDate.format('DD/MM/YYYY'),
    ad_start_time: englishStartDate.format('hh:mm A'),
    ad_end_date: englishEndDate.format('DD/MM/YYYY'),
    ad_end_time: englishEndDate.format('hh:mm A'),
    ad_budget: `${budgetType}`,
    price_daily: budgetPerDay,
    sticker_id: '3',
    source: 'ios',
  }))

  const theAd = [
    {
      ad_id: ``,
      group_id: `${groupId}`,
      shop_id: `${shopId}`,
      item_id: `${shopId}`,
      price_bid: maxPrice,
      ad_type: '2',
      ad_schedule: `${scheduleType}`,
      ad_start_date: englishStartDate.format('DD/MM/YYYY'),
      ad_start_time: englishStartDate.format('hh:mm A'),
      ad_end_date: englishEndDate.format('DD/MM/YYYY'),
      ad_end_time: englishEndDate.format('hh:mm A'),
      ad_budget: `${budgetType}`,
      price_daily: budgetPerDay,
      sticker_id: '3',
      source: 'ios',
    },
  ]

  requestPostCreateAds(selectedProducts.length < 1 ? theAd : theAds)
    .then(result => {
      if (!result.data && result.errors && result.errors.length > 0) {
        ReactInteractionHelper.showErrorStickyAlert(result.errors[0].detail)
      }
      dispatch({
        type: 'POST_ADDGROUP_ADDPROMO_SUCCESS',
        isDonePost: !!result.data,
        payload: result.data,
      })
    })
    .catch(error => {
      ReactInteractionHelper.showErrorStickyAlert(error.message)
      dispatch({
        type: 'POST_ADDGROUP_ADDPROMO_FAILED',
        payload: error,
      })
    })
}

export const resetAddPromoGroupRequestState = () => ({
  type: 'RESET_ADDGROUP_ADDPROMO_REQUESTSTATE',
})

// Edit Promo Actions

export const setInitialEditPromo = ({
  adId,
  productId,
  status,
  isGroup,
  groupType,
  existingGroup,
  maxPrice,
  budgetType,
  budgetPerDay,
  scheduleType,
  startDate,
  endDate,
}) => ({
  type: 'EDIT_SETINITIAL_ADDPROMO',
  adId,
  productId,
  status,
  isGroup,
  groupType,
  existingGroup,
  maxPrice,
  budgetType,
  budgetPerDay,
  scheduleType,
  startDate,
  endDate,
})

function processDate(dateString, timeString) {
  return `${dateString} - ${timeString.split(' ')[0]} ${timeString.split(
    ' ',
  )[1]}`
}

export const getGroupAdDetailEdit = groupId => dispatch => {
  dispatch({
    type: 'GET_PROMODETAIL_EDIT_LOADING',
  })
  requestGetGroupDetail(groupId)
    .then(result => {
      if (result.data) {
        const startDateString = processDate(
          result.data.group_start_date,
          result.data.group_start_time,
        )
        const endDateString = result.data.group_end_time
          ? processDate(result.data.group_end_date, result.data.group_end_time)
          : ''
        dispatch({
          type: 'GET_PROMODETAIL_EDIT_SUCCESS',
          payload: result.data,
          isGroup: true,
          startDateString,
          endDateString,
        })
      } else {
        if (result.errors && result.errors.length > 0) {
          ReactInteractionHelper.showErrorStickyAlert(result.errors[0].detail)
        }
        dispatch({
          type: 'GET_PROMODETAIL_EDIT_FAILED',
        })
      }
    })
    .catch(error => {
      ReactInteractionHelper.showErrorStickyAlert(error.message)
      dispatch({
        type: 'GET_PROMODETAIL_EDIT_FAILED',
      })
    })
}

export const getProductAdDetailEdit = adId => dispatch => {
  dispatch({
    type: 'GET_PROMODETAIL_EDIT_LOADING',
  })
  requestGetProductAdDetail(adId)
    .then(result => {
      if (result.data && result.data.length > 0) {
        const data = result.data[0]
        const startDateString = processDate(
          data.ad_start_date,
          data.ad_start_time,
        )
        const endDateString = data.ad_end_time
          ? processDate(data.ad_end_date, data.ad_end_time)
          : ''
        dispatch({
          type: 'GET_PROMODETAIL_EDIT_SUCCESS',
          payload: data,
          isGroup: false,
          startDateString,
          endDateString,
        })
      } else {
        if (result.errors && result.errors.length > 0) {
          ReactInteractionHelper.showErrorStickyAlert(result.errors[0].detail)
        }
        dispatch({
          type: 'GET_PROMODETAIL_EDIT_FAILED',
        })
      }
    })
    .catch(error => {
      ReactInteractionHelper.showErrorStickyAlert(error.message)
      dispatch({
        type: 'GET_PROMODETAIL_EDIT_FAILED',
      })
    })
}

export const patchGroupPromo = ({
  status,
  groupId,
  shopId,
  newGroupName,
  maxPrice,
  budgetPerDay,
  budgetType,
  scheduleType,
  startDate,
  endDate,
}) => dispatch => {
  dispatch({
    type: 'POST_ADDGROUP_ADDPROMO_LOADING',
  })

  const englishStartDate = startDate
  const englishEndDate = endDate
  englishStartDate.locale('en')
  englishEndDate.locale('en')

  const toggleString = parseInt(status) != 3 ? 'on' : 'off'

  const params = {
    toggleString,
    group_id: `${groupId}`,
    group_name: newGroupName,
    shop_id: `${shopId}`,
    price_bid: maxPrice,
    price_daily: budgetPerDay,
    group_budget: `${budgetType}`,
    group_schedule: `${scheduleType}`,
    group_start_date: englishStartDate.format('DD/MM/YYYY'),
    group_start_time: englishStartDate.format('hh:mm A'),
    group_end_date: englishEndDate.format('DD/MM/YYYY'),
    group_end_time: englishEndDate.format('hh:mm A'),
  }

  requestPatchGroupAds(params)
    .then(result => {
      if (!result.data && result.errors && result.errors.length > 0) {
        ReactInteractionHelper.showErrorStickyAlert(result.errors[0].detail)
      }
      dispatch({
        type: 'POST_ADDGROUP_ADDPROMO_SUCCESS',
        isDonePost: !!result.data,
        payload: result.data,
      })
    })
    .catch(error => {
      ReactInteractionHelper.showErrorStickyAlert(error.message)
      dispatch({
        type: 'POST_ADDGROUP_ADDPROMO_FAILED',
      })
    })
}

export const patchProductPromo = ({
  status,
  adId,
  groupId,
  shopId,
  maxPrice,
  budgetPerDay,
  budgetType,
  scheduleType,
  startDate,
  endDate,
}) => dispatch => {
  dispatch({
    type: 'POST_ADDGROUP_ADDPROMO_LOADING',
  })

  const englishStartDate = startDate
  const englishEndDate = endDate
  englishStartDate.locale('en')
  englishEndDate.locale('en')

  const toggleString = parseInt(status) != 3 ? 'on' : 'off'

  const params = {
    toggleString,
    ad_id: `${adId}`,
    shop_id: `${shopId}`,
    group_id: `${groupId}`,
    price_bid: maxPrice,
    price_daily: budgetPerDay,
    ad_budget: `${budgetType}`,
    ad_schedule: `${scheduleType}`,
    ad_start_date: englishStartDate.format('DD/MM/YYYY'),
    ad_start_time: englishStartDate.format('hh:mm A'),
    ad_end_date: englishEndDate.format('DD/MM/YYYY'),
    ad_end_time: englishEndDate.format('hh:mm A'),
  }

  requestPatchProductAds(params)
    .then(result => {
      if (!result.data && result.errors && result.errors.length > 0) {
        ReactInteractionHelper.showErrorStickyAlert(result.errors[0].detail)
      }
      dispatch({
        type: 'POST_ADDGROUP_ADDPROMO_SUCCESS',
        isDonePost: !!result.data,
        payload: result.data,
      })
    })
    .catch(error => {
      ReactInteractionHelper.showErrorStickyAlert(error.message)
      dispatch({
        type: 'POST_ADDGROUP_ADDPROMO_FAILED',
      })
    })
}

export const moveProductAd = (shopId, groupId, adId) => dispatch => {
  dispatch({
    type: 'POST_ADDGROUP_ADDPROMO_LOADING',
  })
  requestPatchMoveProductAd(shopId, groupId, adId)
    .then(result => {
      if (result) {
        dispatch({
          type: 'POST_ADDGROUP_ADDPROMO_SUCCESS',
          payload: result.data,
        })
      } else {
        if (result.errors && result.errors.length > 0) {
          ReactInteractionHelper.showErrorStickyAlert(result.errors[0].detail)
        }
        dispatch({
          type: 'POST_ADDGROUP_ADDPROMO_FAILED',
        })
      }
    })
    .catch(error => {
      ReactInteractionHelper.showErrorStickyAlert(error.message)
      dispatch({
        type: 'POST_ADDGROUP_ADDPROMO_FAILED',
      })
    })
}

// DELETE ACTION MOVED TO PROMO DETAIL ACTION
