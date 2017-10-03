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
