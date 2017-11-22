import types from './Actions'

const {
  CONNECTING,
  CONNECTED,
  DISCONNECTING,
  DISCONNECTED,
  TOGGLE_NETWORK,
} = types

const initialState = {
  connected: false,
  force_close: false,
  device_token: null,
  user_id: null,
  connectedToInternet: false,
}

export default function webSocketReducer(state = initialState, actions) {
  switch (actions.type) {
    case CONNECTING:
      return {
        ...state,
        device_token: actions.payload.device_token,
        user_id: actions.payload.user_id,
        force_close: false,
      }
    case CONNECTED:
      return {
        ...state,
        connected: true,
        force_close: false,
      }
    case DISCONNECTING:
      return {
        ...state,
        force_close: actions.payload,
      }
    case DISCONNECTED:
      return {
        ...state,
        connected: false,
        force_close: actions.payload,
      }
    case TOGGLE_NETWORK:
      return {
        ...state,
        connectedToInternet: actions.payload,
      }
    default:
      return state
  }
}
