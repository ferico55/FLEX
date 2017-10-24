import { combineReducers } from 'redux'
import { PENDING, FULFILLED, REJECTED } from 'redux-promise-middleware'

import {
  FETCH_CAMPAIGNS,
  FETCH_BANNERS,
  FETCH_BRANDS,
  RESET_BRANDS,
  ADD_TO_WISHLIST,
  SLIDE_BRANDS,
  ADD_TO_FAVOURITE,
  REMOVE_FROM_FAVOURITE,
  REMOVE_FROM_WISHLIST,
  ADD_WISHLIST_FROM_PDP,
  REMOVE_WISHLIST_FROM_PDP,
} from '../actions/actions'

const campaigns = (
  state = {
    items: [],
    isFetching: false,
  },
  action,
) => {
  switch (action.type) {
    case `${FETCH_CAMPAIGNS}_${PENDING}`:
      return Object.assign({}, state, {
        isFetching: true,
      })

    case `${FETCH_CAMPAIGNS}_${FULFILLED}`: {
      const campaignData = action.payload.data

      return {
        items: campaignData,
        isFetching: false,
      }
    }

    case `${FETCH_CAMPAIGNS}_${REJECTED}`:
      return state

    case `${ADD_TO_WISHLIST}_${PENDING}`:
      return state
    case `${ADD_TO_WISHLIST}_${FULFILLED}`:
      return {
        ...state,
        items: state.items.map(b => ({
          ...b,
          Products: b.Products.map(p => {
            if (action.payload === p.data.id) {
              return {
                ...p,
                data: {
                  ...p.data,
                  is_wishlist: true,
                },
              }
            } else {
              return p
            }
          }),
        })),
      }
    case `${ADD_TO_WISHLIST}_${REJECTED}`:
      return state
    case ADD_TO_WISHLIST:
      return {
        ...state,
        items: state.items.map(b => ({
          ...b,
          Products: b.Products.map(p => {
            if (action.payload === p.data.id) {
              return {
                ...p,
                data: {
                  ...p.data,
                  is_wishlist: true,
                },
              }
            } else {
              return p
            }
          }),
        })),
      }

    case ADD_WISHLIST_FROM_PDP:
      return {
        ...state,
        items: state.items.map(b => ({
          ...b,
          Products: b.Products.map(p => {
            if (action.payload == p.data.id) {
              return {
                ...p,
                data: {
                  ...p.data,
                  is_wishlist: true,
                },
              }
            } else {
              return p
            }
          }),
        })),
      }

    case REMOVE_WISHLIST_FROM_PDP:
      return {
        ...state,
        items: state.items.map(b => ({
          ...b,
          Products: b.Products.map(p => {
            if (action.payload == p.data.id) {
              return {
                ...p,
                data: {
                  ...p.data,
                  is_wishlist: false,
                },
              }
            } else {
              return p
            }
          }),
        })),
      }
    case `${REMOVE_FROM_WISHLIST}_${FULFILLED}`:
      return {
        ...state,
        items: state.items.map(b => {
          return {
            ...b,
            Products: b.Products.map(p => {
              if (action.payload === p.data.id) {
                return {
                  ...p,
                  data: {
                    ...p.data,
                    is_wishlist: false
                  }
                }
              } else {
                return p
              }
            })
          }

        })
      }
    case REMOVE_FROM_WISHLIST:
      return {
        ...state,
        items: state.items.map(b => {
          return {
            ...b,
            Products: b.Products.map(p => {
              if (action.payload === p.data.id) {
                return {
                  ...p,
                  data: {
                    ...p.data,
                    is_wishlist: false
                  }
                }
              } else {
                return p
              }
            })
          }

        })
      }

    default:
      return state
  }
}

const banners = (
  state = {
    items: [],
    isFetching: false,
  }, action) => {
  switch (action.type) {
    case `${FETCH_BANNERS}_${PENDING}`:
      return { ...state, isFetching: true }
    case `${FETCH_BANNERS}_${FULFILLED}`:
      const banners = action.payload.data
      if (banners) {
        return {
          items: state.items.length === 0 ? [...state.items, ...banners] : [...state.items],
          isFetching: !state.isFetching
        }
      }
      return state
    case `${FETCH_BANNERS}_${REJECTED}`:
      return state
    default:
      return state
  }
}

const brands = (state = {
  items: [],
  isFetching: false,
  pagination: {
    offset: 0,
    limit: 10
  },
  totalBrands: 0,
  grid: {
    data: [],
    index: 0,
    itemsToShow: 8,
  }
}, action) => {
  switch (action.type) {
    case `${RESET_BRANDS}_${FULFILLED}`:
      const brands = action.payload.data

      return {
        ...state,
        items: brands
      }

    case `${FETCH_BRANDS}_${PENDING}`:
      return {
        ...state,
        isFetching: true,
      }

    case `${FETCH_BRANDS}_${FULFILLED}`:
      const brandsData = action.payload.data || []
      const totalBrands = action.payload.total_brands
      const items = [...state.items, ...brandsData]
      const pagination = {
        ...state.pagination,
        offset: items.length
      }

      const getVisibleGridData = (brands, count) => {
        const data = []
        let howMany = state.grid.itemsToShow
        let index = state.grid.index

        while (howMany--) {
          data.push(brands[index])
          index = (index + 1) % count
        }
        return {
          data,
          index,
          itemsToShow: 8
        }
      }

      return {
        items,
        isFetching: false,
        pagination,
        totalBrands,
        grid: getVisibleGridData(items, totalBrands)
      }
      return state
    case `${FETCH_BRANDS}_${REJECTED}`:
      return {
        ...state,
        isFetching: false,
      }
    case SLIDE_BRANDS:
      const getVisibleGridData1 = (brands, count) => {
        const data = []
        let howMany = state.grid.itemsToShow
        let index = state.grid.index

        while (howMany--) {
          data.push(brands[index])
          index = (index + 1) % count
        }
        return {
          data,
          index,
          itemsToShow: 8
        }
      }
      return {
        ...state,
        grid: getVisibleGridData1(state.items, state.totalBrands)
      }

    case `${ADD_TO_WISHLIST}_${PENDING}`:
      return state
    case `${ADD_TO_WISHLIST}_${FULFILLED}`:
      return {
        ...state,
        items: state.items.map(b => {
          return {
            ...b,
            products: b.products.map(p => {
              if (action.payload === p.id) {
                return {
                  ...p,
                  is_wishlist: true
                }
              } else {
                return p
              }
            })
          }

        })
      }
    case `${ADD_TO_WISHLIST}_${REJECTED}`:
      return state
    case ADD_TO_WISHLIST:
      return {
        ...state,
        items: state.items.map(b => {
          return {
            ...b,
            products: b.products.map(p => {
              if (action.payload === p.id) {
                return {
                  ...p,
                  is_wishlist: true
                }
              } else {
                return p
              }
            })
          }

        })
      }
    case REMOVE_FROM_WISHLIST:
      return {
        ...state,
        items: state.items.map(b => {
          return {
            ...b,
            products: b.products.map(p => {
              if (action.payload === p.id) {
                return {
                  ...p,
                  is_wishlist: false
                }
              } else {
                return p
              }
            })
          }

        })
      }
    case `${REMOVE_FROM_WISHLIST}_${FULFILLED}`:
      return {
        ...state,
        items: state.items.map(b => {
          return {
            ...b,
            products: b.products.map(p => {
              if (action.payload === p.id) {
                return {
                  ...p,
                  is_wishlist: false
                }
              } else {
                return p
              }
            })
          }

        })
      }

    case ADD_WISHLIST_FROM_PDP:
      console.log(state)
      return {
        ...state,
        items: state.items.map(b => {
          return {
            ...b,
            products: b.products.map(p => {
              if (action.payload == p.id) {
                return {
                  ...p,
                  is_wishlist: true
                }
              } else {
                return p
              }
            })
          }

        })
      }

    case REMOVE_WISHLIST_FROM_PDP:
      return {
        ...state,
        items: state.items.map(b => {
          return {
            ...b,
            products: b.products.map(p => {
              if (action.payload == p.id) {
                return {
                  ...p,
                  is_wishlist: false
                }
              } else {
                return p
              }
            })
          }

        })
      }
    case ADD_TO_FAVOURITE:
      return {
        ...state,
        items: state.items.map(b => {
          if (action.payload === b.id) {
            return Object.assign({}, b, {
              isFav: true
            })
          } else {
            return b
          }
        })
      }

    case `${ADD_TO_FAVOURITE}_${FULFILLED}`:
      return {
        ...state,
        items: state.items.map(b => {
          if (action.payload === b.id) {
            return Object.assign({}, b, {
              isFav: true
            })
          } else {
            return b
          }
        })
      }
    case `${REMOVE_FROM_FAVOURITE}_${FULFILLED}`:
      return {
        ...state,
        items: state.items.map(b => {
          if (action.payload === b.id) {
            return Object.assign({}, b, {
              isFav: false
            })
          } else {
            return b
          }
        })
      }

    case REMOVE_FROM_FAVOURITE:
      return {
        ...state,
        items: state.items.map(b => {
          if (action.payload === b.id) {
            return Object.assign({}, b, {
              isFav: false
            })
          } else {
            return b
          }
        })
      }
    default:
      return state
  }
}

const appReducer = combineReducers({
  campaigns,
  banners,
  brands,
})

const rootReducer = (state, action) => {
  if (action.type === 'REFRESH_STATE') {
    state = undefined
  }
  return appReducer(state, action)
}

export default rootReducer
