import { TKPReactURLManager } from 'NativeModules'

// Ws means WebSocket
const CONNECTING = 'CONNECTING'
const CONNECTED = 'CONNECTED'
const DISCONNECTING = 'DISCONNECTING'
const DISCONNECTED = 'DISCONNECTED'
const FORCE_DISCONNECT = 'FORCE_DISCONNECT'
const RECONNECTING = 'RECONNECTING'
const TOGGLE_NETWORK = 'TOGGLE_NETWORK'
const IS_TYPING_CODE = 203
const END_TYPING_CODE = 204
const SEND_MESSAGE_CODE = 103
const IS_RECEIVE_MESSAGE_CODE = 103
const SEND_READ_CODE = 301
const IS_READ_CODE = 301

const baseUrl = (device_token, user_id) => {
  // os_type 2 for iOS
  const baseUrlWs = TKPReactURLManager.webSocketUrl
  const urlWs = `${baseUrlWs}/connect?os_type=2&device_id=${device_token}&user_id=${user_id}`
  return urlWs
}

const types = {
  CONNECTING,
  CONNECTED,
  DISCONNECTING,
  DISCONNECTED,
  FORCE_DISCONNECT,
  IS_TYPING_CODE,
  END_TYPING_CODE,
  SEND_MESSAGE_CODE,
  IS_RECEIVE_MESSAGE_CODE,
  SEND_READ_CODE,
  IS_READ_CODE,
  TOGGLE_NETWORK,
}

export const connectingToWebSocket = (device_token, user_id) => ({
  type: CONNECTING,
  url: baseUrl(device_token, user_id),
  payload: {
    device_token,
    user_id,
  },
})

export const disconnectingWebSocket = (force = false) => ({
  type: DISCONNECTED,
  payload: force,
})

export const toggleConnectedNetwork = payload => ({
  type: TOGGLE_NETWORK,
  payload,
})

export const webSocketEpic = (action$, store) =>
  action$
    .ofType(DISCONNECTED)
    .delay(2000)
    .filter(
      () =>
        !store.getState().webSocket.force_close &&
        !store.getState().webSocket.connected,
    )
    .mapTo({ type: RECONNECTING })

export const reconnectWebSocketEpic = (action$, store) =>
  action$
    .ofType(RECONNECTING)
    .delay(2000)
    .map(() => {
      const { device_token, user_id } = store.getState().webSocket
      return connectingToWebSocket(device_token, user_id)
    })

export const connectedWebSocketEpic = (action$, store) =>
  action$
    .ofType(CONNECTED)
    .filter(() => !store.getState().webSocket.connectedToInternet)
    .map(() => toggleConnectedNetwork(true))

export default types
