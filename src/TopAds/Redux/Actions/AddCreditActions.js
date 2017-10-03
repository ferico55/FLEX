import { requestPromoCreditList } from '../../Helper/Requests'

export const changeAddCreditSelectedIndex = index => ({
  type: 'CHANGE_SELECTED_INDEX_PROMOCREDIT_LIST',
  index,
})

export const getPromoCreditList = () => dispatch => {
  dispatch({
    type: 'GET_PROMOCREDIT_LIST_LOADING',
  })
  requestPromoCreditList()
    .then(result => {
      dispatch({
        type: 'GET_PROMOCREDIT_LIST_SUCCESS',
        payload: result.data,
      })
    })
    .catch(error => {
      dispatch({
        type: 'GET_PROMOCREDIT_LIST_FAILED',
        payload: error,
      })
    })
}
