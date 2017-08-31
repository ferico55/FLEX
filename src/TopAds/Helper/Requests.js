import {
  TKPReactURLManager,
  ReactNetworkManager,
  TKPReactAnalytics,
  NativeTab
} from "NativeModules";

// Dashboard
export const requestCreditInfo = (shopId, onSuccess, onFailed) => {
  return ReactNetworkManager.request({
    method: "GET",
    baseUrl: TKPReactURLManager.topAdsUrl,
    path: "/v1.1/dashboard/deposit",
    params: { shop_id: shopId }
  });
};

export const requestDashboardInfo = ({ shopId, type, startDate, endDate }) => {
  return ReactNetworkManager.request({
    method: "GET",
    baseUrl: TKPReactURLManager.topAdsUrl,
    path: "/v1.1/dashboard/statistics",
    params: {
      shop_id: shopId,
      type: type,
      start_date: startDate,
      end_date: endDate
    }
  });
};

export const requestShopTopAdsInfo = ({ shopId, startDate, endDate }) => {
  return ReactNetworkManager.request({
    method: "GET",
    baseUrl: TKPReactURLManager.topAdsUrl,
    path: "/v1.1/dashboard/shop",
    params: {
      shop_id: shopId,
      start_date: startDate,
      end_date: endDate
    }
  });
};

export const requestTotalAds = shopId => {
  return ReactNetworkManager.request({
    method: "GET",
    baseUrl: TKPReactURLManager.topAdsUrl,
    path: "/v1.1/dashboard/total_ad",
    params: { shop_id: shopId }
  });
};

// Add promo credit page
export const requestPromoCreditList = () => {
  return ReactNetworkManager.request({
    method: "GET",
    baseUrl: TKPReactURLManager.topAdsUrl,
    path: "/v1/tkpd_products",
    params: {}
  });
};

//Promo list page
export const requestGroupAds = ({
  shopId,
  startDate,
  endDate,
  keyword,
  status,
  page,
  groupId
}) => {
  return ReactNetworkManager.request({
    method: "GET",
    baseUrl: TKPReactURLManager.topAdsUrl,
    path: "/v1.1/dashboard/groups",
    params: {
      shop_id: shopId,
      start_date: startDate,
      end_date: endDate,
      keyword: keyword,
      status: status,
      page: page,
      group_id: groupId
    }
  });
};

export const requestProductAds = ({
  shopId,
  startDate,
  endDate,
  keyword,
  status,
  groupId,
  page
}) => {
  return ReactNetworkManager.request({
    method: "GET",
    baseUrl: TKPReactURLManager.topAdsUrl,
    path: "/v1.1/dashboard/group_products",
    params: {
      shop_id: shopId,
      start_date: startDate,
      end_date: endDate,
      keyword: keyword,
      status: status,
      group: groupId,
      page: page,
      ad_id: ""
    }
  });
};

// Filter group page
export const requestGroupList = (shopId, keyword) => {
  return ReactNetworkManager.request({
    method: "GET",
    baseUrl: TKPReactURLManager.topAdsUrl,
    path: "/v1.1/dashboard/search_groups",
    params: {
      keyword: keyword,
      shop_id: shopId
    }
  });
};

// Product detail page
export const requestPatchToggleStatusShop = (toggleOn, shopId, adId) => {
  const toggleString = toggleOn ? "toggle_on" : "toggle_off";
  return ReactNetworkManager.request({
    method: "PATCH",
    baseUrl: TKPReactURLManager.topAdsUrl,
    path: "/v2.1/promo/bulk",
    encoding: "json",
    params: {
      data: {
        action: toggleString,
        shop_id: `${shopId}`,
        ads: [
          {
            ad_id: `${adId}`
          }
        ]
      }
    }
  });
};

export const requestPatchToggleStatusGroup = (toggleOn, shopId, groupId) => {
  const actionString = toggleOn ? "toggle_on" : "toggle_off";
  return ReactNetworkManager.request({
    method: "PATCH",
    baseUrl: TKPReactURLManager.topAdsUrl,
    path: "/v2.1/promo/group/bulk",
    encoding: "json",
    params: {
      data: {
        action: actionString,
        shop_id: `${shopId}`,
        groups: [
          {
            group_id: `${groupId}`
          }
        ]
      }
    }
  });
};

export const requestPatchToggleStatusProduct = (toggleOn, shopId, adId) => {
  const actionString = toggleOn ? "toggle_on" : "toggle_off";
  return ReactNetworkManager.request({
    method: "PATCH",
    baseUrl: TKPReactURLManager.topAdsUrl,
    path: "/v2.1/promo/bulk",
    encoding: "json",
    params: {
      data: {
        action: actionString,
        shop_id: `${shopId}`,
        ads: [
          {
            ad_id: `${adId}`
          }
        ]
      }
    }
  });
};
