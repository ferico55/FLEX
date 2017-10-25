import { TKPReactURLManager, ReactNetworkManager } from 'NativeModules'

// Dashboard
export const requestCreditInfo = shopId =>
  ReactNetworkManager.request({
    method: 'GET',
    baseUrl: TKPReactURLManager.topAdsUrl,
    path: '/v1.1/dashboard/deposit',
    params: { shop_id: shopId },
  })

export const requestDashboardInfo = ({ shopId, type, startDate, endDate }) =>
  ReactNetworkManager.request({
    method: 'GET',
    baseUrl: TKPReactURLManager.topAdsUrl,
    path: '/v1.1/dashboard/statistics',
    params: {
      shop_id: shopId,
      type,
      start_date: startDate,
      end_date: endDate,
    },
  })

export const requestShopTopAdsInfo = ({ shopId, startDate, endDate }) =>
  ReactNetworkManager.request({
    method: 'GET',
    baseUrl: TKPReactURLManager.topAdsUrl,
    path: '/v1.1/dashboard/shop',
    params: {
      shop_id: shopId,
      start_date: startDate,
      end_date: endDate,
    },
  })

export const requestTotalAds = shopId =>
  ReactNetworkManager.request({
    method: 'GET',
    baseUrl: TKPReactURLManager.topAdsUrl,
    path: '/v1.1/dashboard/total_ad',
    params: { shop_id: shopId },
  })

// Add credit page
export const requestPromoCreditList = () =>
  ReactNetworkManager.request({
    method: 'GET',
    baseUrl: TKPReactURLManager.topAdsUrl,
    path: '/v1/tkpd_products',
    params: {},
  })

// Promo list page
export const requestGroupAds = ({
  shopId,
  startDate,
  endDate,
  keyword,
  status,
  page,
  groupId,
}) =>
  ReactNetworkManager.request({
    method: 'GET',
    baseUrl: TKPReactURLManager.topAdsUrl,
    path: '/v1.1/dashboard/groups',
    params: {
      shop_id: shopId,
      start_date: startDate,
      end_date: endDate,
      keyword,
      status,
      page,
      group_id: groupId,
    },
  })

export const requestProductAds = ({
  shopId,
  startDate,
  endDate,
  keyword,
  status,
  groupId,
  page,
  adId,
}) =>
  ReactNetworkManager.request({
    method: 'GET',
    baseUrl: TKPReactURLManager.topAdsUrl,
    path: '/v1.1/dashboard/group_products',
    params: {
      shop_id: shopId,
      start_date: startDate,
      end_date: endDate,
      keyword,
      status,
      group: groupId,
      page,
      ad_id: adId,
    },
  })

// Filter group page
export const requestGroupList = (shopId, keyword) =>
  ReactNetworkManager.request({
    method: 'GET',
    baseUrl: TKPReactURLManager.topAdsUrl,
    path: '/v1.1/dashboard/search_groups',
    params: {
      keyword,
      shop_id: shopId,
    },
  })

// Product detail page
export const requestPatchToggleStatus = (toggleOn, shopId, adId) => {
  const toggleString = toggleOn ? 'toggle_on' : 'toggle_off'
  return ReactNetworkManager.request({
    method: 'PATCH',
    baseUrl: TKPReactURLManager.topAdsUrl,
    path: '/v2.1/promo/bulk',
    encoding: 'json',
    params: {
      data: {
        action: toggleString,
        shop_id: `${shopId}`,
        ads: [
          {
            ad_id: `${adId}`,
          },
        ],
      },
    },
  })
}

export const requestPatchToggleStatusGroup = (toggleOn, shopId, groupId) => {
  const actionString = toggleOn ? 'toggle_on' : 'toggle_off'
  return ReactNetworkManager.request({
    method: 'PATCH',
    baseUrl: TKPReactURLManager.topAdsUrl,
    path: '/v2.1/promo/group/bulk',
    encoding: 'json',
    params: {
      data: {
        action: actionString,
        shop_id: `${shopId}`,
        groups: [
          {
            group_id: `${groupId}`,
          },
        ],
      },
    },
  })
}

// Add Promo Page
export const requestProductList = ({
  shopId,
  keyword,
  etalase,
  sortBy,
  rows,
  start,
  promotedStatus,
}) =>
  ReactNetworkManager.request({
    method: 'GET',
    baseUrl: TKPReactURLManager.topAdsUrl,
    path: '/v1.1/dashboard/search_products',
    params: {
      shop_id: shopId,
      keyword,
      start,
      rows: 30,
      etalase: etalase.menu_id,
      is_promoted: promotedStatus,
    },
  })

export const requestPostCreateGroupAds = params =>
  ReactNetworkManager.request({
    method: 'POST',
    baseUrl: TKPReactURLManager.topAdsUrl,
    path: '/v2.1/promo/group',
    encoding: 'json',
    params: {
      data: {
        group_name: params.group_name,
        shop_id: params.shop_id,
        status: '1',
        price_bid: params.price_bid,
        price_daily: params.price_daily,
        group_budget: params.group_budget,
        group_schedule: params.group_schedule,
        group_start_date: params.group_start_date,
        group_start_time: params.group_start_time,
        group_end_date: params.group_end_date,
        group_end_time: params.group_end_time,
        sticker_id: '3',
        group_total: params.group_total,
        source: 'ios',
        ads: params.ads,
      },
    },
  })

export const requestPostCreateAds = dataArray =>
  ReactNetworkManager.request({
    method: 'POST',
    baseUrl: TKPReactURLManager.topAdsUrl,
    path: '/v2.1/promo',
    encoding: 'json',
    params: {
      data: dataArray,
    },
  })

// Edit Promo

export const requestGetGroupDetail = groupId =>
  ReactNetworkManager.request({
    method: 'GET',
    baseUrl: TKPReactURLManager.topAdsUrl,
    path: '/v2.1/promo/group',
    params: {
      group_id: groupId,
    },
  })

export const requestEtalaseList = shopId =>
  ReactNetworkManager.request({
    method: 'GET',
    baseUrl: TKPReactURLManager.tomeUrl,
    path: '/v1/web-service/shop/get_etalase',
    params: {
      shop_id: shopId,
    },
  })

export const requestGetProductAdDetail = adId =>
  ReactNetworkManager.request({
    method: 'GET',
    baseUrl: TKPReactURLManager.topAdsUrl,
    path: '/v2.1/promo',
    params: {
      ad_id: `${adId}`,
    },
  })

export const requestPatchMoveProductAd = (shopId, groupId, adId) =>
  ReactNetworkManager.request({
    method: 'PATCH',
    baseUrl: TKPReactURLManager.topAdsUrl,
    path: '/v2.1/promo/bulk',
    encoding: 'json',
    params: {
      data: {
        action: 'move_group',
        shop_id: `${shopId}`,
        ads: [
          {
            ad_id: `${adId}`,
            group_id: `${groupId}`,
          },
        ],
      },
    },
  })

export const requestPatchGroupAds = params =>
  ReactNetworkManager.request({
    method: 'PATCH',
    baseUrl: TKPReactURLManager.topAdsUrl,
    path: '/v2.1/promo/group',
    encoding: 'json',
    params: {
      data: {
        group_id: params.group_id,
        group_name: params.group_name,
        shop_id: params.shop_id,
        price_bid: params.price_bid,
        group_budget: params.group_budget,
        price_daily: params.price_daily,
        group_schedule: params.group_schedule,
        group_start_date: params.group_start_date,
        group_start_time: params.group_start_time,
        group_end_date: params.group_end_date,
        group_end_time: params.group_end_time,
        sticker_id: '3',
        source: 'ios',
        toggle: params.toggleString,
      },
    },
  })

export const requestPatchProductAds = params =>
  ReactNetworkManager.request({
    method: 'PATCH',
    baseUrl: TKPReactURLManager.topAdsUrl,
    path: '/v2.1/promo',
    encoding: 'json',
    params: {
      data: [
        {
          ad_id: params.ad_id,
          shop_id: params.shop_id,
          group_id: params.group_id,
          price_bid: params.price_bid,
          ad_budget: params.ad_budget,
          price_daily: params.price_daily,
          ad_schedule: params.ad_schedule,
          ad_start_date: params.ad_start_date,
          ad_start_time: params.ad_start_time,
          ad_end_date: params.ad_end_date,
          ad_end_time: params.ad_end_time,
          sticker_id: '3',
          source: 'ios',
          toggle: params.toggleString,
        },
      ],
    },
  })

export const requestPatchDeleteGroup = (shopId, groupId) =>
  ReactNetworkManager.request({
    method: 'PATCH',
    baseUrl: TKPReactURLManager.topAdsUrl,
    path: '/v2.1/promo/group/bulk',
    encoding: 'json',
    params: {
      data: {
        action: 'delete',
        shop_id: `${shopId}`,
        groups: [
          {
            group_id: `${groupId}`,
          },
        ],
      },
    },
  })

export const requestPatchDeleteProductAd = (shopId, adId) =>
  ReactNetworkManager.request({
    method: 'PATCH',
    baseUrl: TKPReactURLManager.topAdsUrl,
    path: '/v2.1/promo/bulk',
    encoding: 'json',
    params: {
      data: {
        action: 'delete',
        shop_id: `${shopId}`,
        ads: [
          {
            ad_id: `${adId}`,
          },
        ],
      },
    },
  })

export const requestGetSuggestionPrice = (shopId, isGroup, idArray) =>
  ReactNetworkManager.request({
    method: 'POST',
    baseUrl: TKPReactURLManager.topAdsUrl,
    path: '/v1/suggest',
    encoding: 'json',
    headers: {
      'Content-Type': 'application/json',
    },
    params: {
      data: {
        suggestion_type: isGroup ? 'group_bid' : 'dep_bid',
        data_type: 'summary',
        shop_id: shopId,
        ids: idArray,
        source: 'ios',
        rounding: true,
      },
    },
  })
