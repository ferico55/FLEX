import {
  FETCH_CHAT_TEMPLATE_SUCCESS,
  UPDATE_CHAT_TEMPLATE_SUCCESS,
} from './Actions'

const initialState = {
  templates: [],
  is_enable: false,
  loading: false,
  success: 0,
  from_sort: false,
}

export default function chatTemplateReducer(state = initialState, actions) {
  switch (actions.type) {
    case FETCH_CHAT_TEMPLATE_SUCCESS:
      return {
        ...actions.payload,
      }
    case UPDATE_CHAT_TEMPLATE_SUCCESS:
      return {
        ...actions.payload,
      }
    default:
      return state
  }
}
