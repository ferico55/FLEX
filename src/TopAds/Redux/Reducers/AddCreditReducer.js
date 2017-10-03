const addPromoCreditState = {
  isLoading: false,
  dataSource: [],
  selectedIndex: -1,
}

export default function addCreditReducer(state = addPromoCreditState, action) {
  switch (action.type) {
    case 'CHANGE_SELECTED_INDEX_PROMOCREDIT_LIST':
      return {
        ...state,
        selectedIndex: action.index,
      }
    case 'GET_PROMOCREDIT_LIST_LOADING':
      return {
        ...state,
        isLoading: true,
      }
    case 'GET_PROMOCREDIT_LIST_SUCCESS':
      return {
        ...state,
        isLoading: false,
        dataSource: action.payload,
      }
    case 'GET_PROMOCREDIT_LIST_FAILED':
      return {
        ...state,
        isLoading: false,
      }
    default:
      return state
  }
}
