import types from '@redux/web_socket/Actions'
import {
  isTyping,
  endTyping,
  receiveMessage,
  replaceMessage,
  sendReplyWithAPI,
  SEND_CHAT_MESSAGE,
  SEND_TYPING,
  SET_MSG_ID,
  MESSAGES_RECEIVED,
} from '@redux/messages/Actions'

const {
  CONNECTING,
  CONNECTED,
  DISCONNECTED,
  IS_TYPING_CODE,
  END_TYPING_CODE,
  IS_RECEIVE_MESSAGE_CODE,
  SEND_READ_CODE,
  IS_READ_CODE,
} = types

import _ from 'lodash'

const socketMiddleware = (() => {
  let socket = null
  let limiter = 1

  const onOpen = (ws, store, token) => evt => {
    // Send a handshake, or authenticate with remote end

    // Tell the store we're connected
    store.dispatch({
      type: CONNECTED,
    })
  }

  const onClose = (ws, store) => evt => {
    if (!store.getState().webSocket.force_close) {
      // Tell the store we've disconnected automaticly from server
      store.dispatch({
        type: DISCONNECTED,
        payload: store.getState().webSocket.force_close,
      })
    }
  }

  const onMessage = (ws, store) => evt => {
    // Parse the JSON message received on the websocket
    const msg = JSON.parse(evt.data)
    switch (msg.code) {
      case IS_TYPING_CODE:
        store.dispatch(isTyping(msg))
        break
      case END_TYPING_CODE:
        store.dispatch(endTyping(msg))
        break
      case IS_RECEIVE_MESSAGE_CODE:
        const sender_name = store.getState().messages.sender_name
        const is_current_msg_id_set =
          store.getState().messages.current_msg_id !== null
        const current_msg_id = store.getState().messages.current_msg_id
        if (sender_name !== msg.data.from) {
          store.dispatch(
            receiveMessage(msg.data, is_current_msg_id_set, current_msg_id),
          )
        } else if (
          sender_name === msg.data.from &&
          msg.data.msg_id === current_msg_id
        ) {
          store.dispatch(
            replaceMessage(msg.data.message.censored_reply, msg.data.from_uid),
          )
        }
        // store.dispatch(receiveMessage(msg.data))
        break
      case IS_READ_CODE:
        store.dispatch({
          type: 'CHANGE_READ_STATUS',
          payload: msg.data.msg_id,
        })
        break
      default:
        console.log(msg.code)
    }
  }

  return store => next => action => {
    switch (action.type) {
      // The user wants us to connect
      case CONNECTING:
        // Attempt to connect (we could send a 'failed' action on error)

        if (socket !== null) {
          socket.close()
          socket = null
        }

        socket = new WebSocket(action.url)
        socket.onmessage = onMessage(socket, store)
        socket.onclose = onClose(socket, store)
        socket.onopen = onOpen(socket, store, action.token)
        if (__DEV__) {
          socket.onerror = () => {
            console.log('ERROR HAPPENED')
          }
        }

        return next(action)
      case SET_MSG_ID:
        // set read to true when we open the chat detail
        if (store.getState().webSocket.connected) {
          const objectToSend = {
            code: SEND_READ_CODE,
            data: {
              msg_id: action.payload,
            },
          }
          socket.send(JSON.stringify(objectToSend))
        }
        return next(action)
      case MESSAGES_RECEIVED:
        if (store.getState().webSocket.connected) {
          const objectToSend = {
            code: SEND_READ_CODE,
            data: {
              msg_id: action.payload.msg_id,
            },
          }
          socket.send(JSON.stringify(objectToSend))
        }
        return next(action)
      // case DISCONNECTING:
      //   store.dispatch({
      //     type: DISCONNECTED,
      //     payload: store.getState().webSocket.force_close,
      //   })
      //   return next(action)
      case DISCONNECTED:
        if (socket != null && store.getState().webSocket.force_close) {
          socket.close()
          socket = null
        }
        return next(action)
      // Send the 'SEND_MESSAGE' action down the websocket to the server
      case SEND_CHAT_MESSAGE:
        if (store.getState().webSocket.connected) {
          socket.send(JSON.stringify(action.payload))
          return next(action)
        }

        store.dispatch(sendReplyWithAPI(action.payload, action.sender_id))
        return next(action)
      case SEND_TYPING:
        if (store.getState().webSocket.connected) {
          if (limiter === 1 && action.payload.code === 203) {
            socket.send(JSON.stringify(action.payload))
            limiter += 1
          } else if (action.payload.code === 204) {
            limiter = 1
            socket.send(JSON.stringify(action.payload))
          }
        }
        break
      // This action is irrelevant to us, pass it on to the next middleware
      default:
        return next(action)
    }
  }
})()

export default socketMiddleware
