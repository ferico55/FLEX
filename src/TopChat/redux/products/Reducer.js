import { FETCH_SHOP_PRODUCTS, FETCH_SHOP_PRODUCTS_SUCCESS } from './Actions'

const initialState = {
  list: [],
  paging: {},
  total_data: 0,
  loading: false,
  status: null,
}

export default function productsReducer(state = initialState, actions) {
  switch (actions.type) {
    case FETCH_SHOP_PRODUCTS:
      return {
        ...state,
        loading: true,
      }
    case FETCH_SHOP_PRODUCTS_SUCCESS:
      return {
        list: actions.payload.list,
        total_data: actions.payload.total_data,
        paging: actions.payload.paging,
        loading: false,
        status: 'OK',
      }
    default:
      return state
  }
}
