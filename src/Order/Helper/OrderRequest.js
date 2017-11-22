import { TKPReactURLManager, ReactNetworkManager } from 'NativeModules'

const extractErrorMessageFrom200 = data => {
  if (data.message_error) {
    throw {
      description: data.message_error[0],
    }
  }

  return data
}

const extractErrorMessage = error => {
  const errorMessageByCode = {
    no_internet: 'No internet connection',
    timeout: 'Connection timeout',
    unknown_error: 'Unknown error, please try again later',
  }
  throw {
    description: errorMessageByCode[error.code],
  }
}

export const getOrderHistory = ({ userID, orderID, type }) =>
  ReactNetworkManager.request({
    method: 'GET',
    baseUrl: TKPReactURLManager.v4Url,
    path: '/v4/order/history',
    params: {
      user_id: userID,
      order_id: orderID,
      request_by: type,
      lang: 'id',
      os_type: 2,
    },
  })
    .catch(extractErrorMessage)
    .then(extractErrorMessageFrom200)

export const getOrderDetail = ({ userID, orderID, type }) =>
  ReactNetworkManager.request({
    method: 'GET',
    baseUrl: TKPReactURLManager.v4Url,
    path: '/v4/order/detail',
    params: {
      user_id: userID,
      order_id: orderID,
      request_by: type,
      lang: 'id',
      os_type: 2,
    },
  })
    .catch(extractErrorMessage)
    .then(extractErrorMessageFrom200)
