import { TKPReactURLManager, ReactNetworkManager } from 'NativeModules'

// Message List
export const getChatList = ({ tab, filter, page }) =>
  ReactNetworkManager.request({
    method: 'GET',
    baseUrl: TKPReactURLManager.topChatURL,
    path: '/tc/v1/list_message',
    params: {
      tab,
      filter,
      page,
      platform: 'ios',
    },
  })

export const searchChat = (keyword, status, page, size, by) =>
  ReactNetworkManager.request({
    method: 'GET',
    baseUrl: TKPReactURLManager.topChatURL,
    path: '/tc/v1/search',
    params: {
      keyword,
      status,
      page,
      by,
      size,
    },
  })

export const markRead = messageIDs =>
  ReactNetworkManager.request({
    method: 'POST',
    baseUrl: TKPReactURLManager.topChatURL,
    path: '/tc/v1/mark_read',
    encoding: 'json',
    params: {
      list_msg_id: [...messageIDs],
    },
  })

export const markAsUnread = messageIDs =>
  ReactNetworkManager.request({
    method: 'POST',
    baseUrl: TKPReactURLManager.topChatURL,
    path: '/tc/v1/mark_unread',
    encoding: 'json',
    params: {
      list_msg_id: [...messageIDs],
    },
  })

export const moveToArchive = messageIDs =>
  ReactNetworkManager.request({
    method: 'POST',
    baseUrl: TKPReactURLManager.topChatURL,
    path: '/tc/v1/archive',
    encoding: 'json',
    params: {
      list_msg_id: messageIDs,
    },
  })

export const moveToTrash = messageIDs =>
  ReactNetworkManager.request({
    method: 'POST',
    baseUrl: TKPReactURLManager.topChatURL,
    path: '/tc/v1/delete',
    encoding: 'json',
    params: {
      list_msg_id: messageIDs,
    },
  })

export const moveToInbox = messageIDs =>
  ReactNetworkManager.request({
    method: 'POST',
    baseUrl: TKPReactURLManager.topChatURL,
    path: '/tc/v1/move_inbox',
    params: {
      list_msg_id: messageIDs,
    },
  })

// Reply List
export const getReplyList = (
  messageID,
  page = 1,
  per_page = 25,
  keyword = '',
) =>
  ReactNetworkManager.request({
    method: 'GET',
    baseUrl: TKPReactURLManager.topChatURL,
    path: '/tc/v1/list_reply/'.concat(messageID),
    params: {
      platform: 'ios',
      page,
      per_page,
      keyword,
    },
  })

export const reply = ({ msg_id, message_reply }) =>
  ReactNetworkManager.request({
    method: 'POST',
    baseUrl: TKPReactURLManager.topChatURL,
    path: '/tc/v1/reply',
    params: {
      msg_id,
      message_reply,
    },
  })

export const getShopProduct = ({
  shop_id,
  shop_domain,
  keyword,
  page = 1,
  per_page = 10,
  etalase_id,
}) =>
  ReactNetworkManager.request({
    method: 'GET',
    baseUrl: TKPReactURLManager.aceUrl,
    path: '/v1/web-service/shop/get_shop_product',
    params: {
      shop_id,
      shop_domain,
      page,
      per_page,
      etalase_id,
      keyword,
    },
  })

export const getOnlineStatus = ({ type, id }) =>
  ReactNetworkManager.request({
    method: 'GET',
    baseUrl: TKPReactURLManager.ajaxAppUrl,
    path: `/js/${type}login`,
    params: {
      id,
      format: 'api',
    },
  })
