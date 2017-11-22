import { Observable } from 'rxjs'
import { getShopProduct } from '@helpers/Requests'

export const FETCH_SHOP_PRODUCTS = 'FETCH_SHOP_PRODUCTS'
export const FETCH_SHOP_PRODUCTS_SUCCESS = 'FETCH_SHOP_PRODUCTS_SUCCESS'
export const FETCH_SHOP_PRODUCTS_ERROR = 'FETCH_SHOP_PRODUCTS_ERROR'

export const fetchShopProducts = payload => ({
  type: FETCH_SHOP_PRODUCTS,
  payload,
})

const fetchShopProductsSuccess = payload => ({
  type: FETCH_SHOP_PRODUCTS_SUCCESS,
  payload,
})

export const fetchShopProductsEpic = (action$, store) =>
  action$.ofType(FETCH_SHOP_PRODUCTS).mergeMap(action =>
    Observable.from(getShopProduct(action.payload))
      .map(res => {
        if (res.status !== 'OK') {
          throw res
        }
        let payload = res.data
        const page = action.payload.page
        const state = store.getState().products

        if (page > 1) {
          payload = {
            ...state,
            list: [...state.list, ...payload.list],
            paging: {
              ...state.paging,
            },
          }
        }

        return fetchShopProductsSuccess(payload)
      })
      .catch(err => Observable.of({ type: FETCH_SHOP_PRODUCTS_ERROR, err })),
  )
