import { getChatTemplate, updateChatTemplate } from '@TopChat/helpers/Requests'

export const FETCH_CHAT_TEMPLATE_SUCCESS = 'FETCH_CHAT_TEMPLATE_SUCCESS'
export const FETCH_CHAT_TEMPLATE_ERROR = 'FETCH_CHAT_TEMPLATE_ERROR'
export const UPDATE_CHAT_TEMPLATE_SUCCESS = 'UPDATE_CHAT_TEMPLATE_SUCCESS'
export const UPDATE_CHAT_TEMPLATE_ERROR = 'UPDATE_CHAT_TEMPLATE_ERROR'

// this is actions is used for fetch chatTemplate state from SendChatComponent
// we make this because on sendchat module dont have any redux setup
// we only make actions for map the state to TopChat reducer
// we use thunk instead of epic (rxjs)
export const fetchChatTemplate = () => dispatch =>
  getChatTemplate()
    .then(({ data: { templates, is_enable }, success }) =>
      dispatch({
        type: FETCH_CHAT_TEMPLATE_SUCCESS,
        payload: {
          templates: templates.filter(v => v !== '_'),
          is_enable,
          success,
        },
      }),
    )
    .catch(() => ({
      type: FETCH_CHAT_TEMPLATE_ERROR,
      payload: {
        templates: [],
      },
    }))

export const updatingChatTemplate = ({
  data,
  enable_template,
  from_sort, // indicate that this update is dispatch from sort action
}) => dispatch =>
  updateChatTemplate(data, enable_template)
    .then(
      ({ data: { templates, is_enable }, success, message_error_original }) => {
        if (!success) {
          throw {
            message_error_original,
            success,
          }
        }
        return dispatch({
          type: UPDATE_CHAT_TEMPLATE_SUCCESS,
          payload: {
            templates: templates.filter(v => v !== '_'),
            is_enable,
            success,
            from_sort: !!from_sort,
          },
        })
      },
    )
    .catch(e =>
      dispatch({
        type: UPDATE_CHAT_TEMPLATE_ERROR,
        payload: e,
      }),
    )
