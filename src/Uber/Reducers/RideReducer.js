import { combineReducers } from 'redux'

export const predictionReducer = (
  state = { data: [], status: 'idle' },
  action,
) => {
  switch (action.type) {
    case 'RECEIVE_PREDICTIONS':
      return { data: action.predictions, status: 'loaded' }
    case 'RIDE_TYPE_AUTOCOMPLETE':
      return { data: [], status: 'loading' }
    case 'RIDE_EXIT_AUTOCOMPLETE_SCREEN':
      return { data: [], status: 'idle' }
    case 'RIDE_AUTOCOMPLETE_TYPE_MODE':
      return { data: [], status: 'loading' }
    case 'RECEIVE_PREDICTIONS_ERROR':
      return { data: [], status: 'error', error: action.error }
    default:
      return state
  }
}

export const recentAddressesReducer = (
  state = { data: [], status: 'idle' },
  action,
) => {
  switch (action.type) {
    case 'RIDE_GET_RECENT_ADDRESSES':
      return { data: [], status: 'loading' }
    case 'RIDE_RECEIVE_RECENT_ADDRESSES':
      return { data: action.recentAddresses, status: 'loaded' }
    case 'RIDE_GET_RECENT_ADDRESSES_ERROR':
      return { data: [], status: 'idle' }
    case 'RIDE_EXIT_AUTOCOMPLETE_SCREEN':
      return { data: [], status: 'idle' }
    case 'RIDE_AUTOCOMPLETE_TYPE_MODE':
      return { data: [], status: 'idle' }
    default:
      return state
  }
}

export const endpointReducer = (
  state = { source: null, destination: null, status: 'idle' },
  action,
) => {
  switch (action.type) {
    case 'RIDE_SET_LOCATION':
      return {
        ...state,
        source:
          action.searchType === 'source' ? action.prediction : state.source,
        destination:
          action.searchType === 'destination'
            ? action.prediction
            : state.destination,
        status: 'loaded',
      }

    case 'RIDE_REMOVE_DESTINATION':
      return {
        ...state,
        destination: null,
      }

    case 'RIDE_REGION_CHANGE':
      if (state.destination || action.locationSource.source !== 'map') {
        return { ...state, status: 'loading' }
      }

      return {
        ...state,
        source: {
          location: {
            coordinate: action.region,
          },
        },
        status: 'loading',
      }

    case 'RIDE_CURRENT_TRIP_LOCATION':
      return {
        source: action.source,
        destination: action.destination,
        status: 'loaded',
      }
    case 'RIDE_REGION_CHANGE_ERROR':
      return { ...state, status: 'loaded' }
    case 'RIDE_REGION_CHANGE_SOURCE':
      return { ...state, status: 'loaded' }
    default:
      return state
  }
}

export const rideRouteReducer = (state = null, action) => {
  switch (action.type) {
    case 'RIDE_DIRECTIONS':
      return action.route
    case 'RIDE_REMOVE_DESTINATION':
      return null
    default:
      return state
  }
}

export const searchTypeReducer = (state = null, action) => {
  switch (action.type) {
    case 'RIDE_SEARCH':
      return action.searchType
    default:
      return state
  }
}

export const currentTripReducer = (state = null, action) => {
  switch (action.type) {
    case 'RIDE_CURRENT_TRIP_STATUS':
      if (
        action.currentTrip &&
        (action.currentTrip.status === 'rider_canceled' ||
          action.currentTrip.status === 'driver_canceled' ||
          action.currentTrip.status === 'no_drivers_available')
      ) {
        return null
      }
      return action.currentTrip
    default:
      return state
  }
}

export const rideRequestReducer = (state = { status: 'idle' }, action) => {
  switch (action.type) {
    case 'RIDE_TRIP_BOOKED':
      return {
        status: 'loaded',
        requestId: action.requestId,
      }

    case 'RIDE_BOOK_VEHICLE':
      return {
        status: 'loading',
      }

    case 'RIDE_BOOK_ERROR':
      return {
        status: 'error',
        error: action.error,
      }
    case 'RIDE_SET_LOCATION':
    case 'RIDE_REMOVE_DESTINATION':
      return {
        status: 'idle',
      }
    default:
      return state
  }
}

export const selectedTripOptionReducer = (state = null, action) => {
  switch (action.type) {
    case 'SELECT_TRIP_OPTION':
      return action.selectedTripOption
    default:
      return state
  }
}

export const timeEstimationReducer = (state = null, action) => {
  switch (action.type) {
    case 'RIDE_DIRECTIONS':
      return null
    case 'RIDE_FIND_TRIP_OPTIONS_COMPLETE':
      return action.timeEstimations
    case 'RIDE_ESTIMATES':
      return action.estimates
    case 'RIDE_ESTIMATES_ERROR':
      return null
    default:
      return state
  }
}

export const priceEstimationReducer = (state = [], action) => {
  switch (action.type) {
    case 'RIDE_FIND_TRIP_OPTIONS_COMPLETE':
      return action.priceEstimations
    case 'RIDE_FIND_TRIP_OPTIONS':
      return []
    case 'RIDE_ESTIMATES':
      return action.priceEstimations
    default:
      return state
  }
}

export const directionReducer = (state = null, action) => {
  switch (action.type) {
    case 'RIDE_DIRECTIONS':
      return action.directions
    case 'RIDE_REMOVE_DESTINATION':
      return null
    default:
      return state
  }
}

export const mapDragReducer = (state = false, action) => {
  switch (action.type) {
    case 'RIDE_MAP_START_DRAGGING':
      return true
    case 'RIDE_MAP_STOP_DRAGGING':
      return false
    default:
      return state
  }
}

export const locationSearchReducer = (state = null, action) => {
  switch (action.type) {
    case 'RIDE_AUTOCOMPLETE_REGION_CHANGE':
      return (
        action.region && {
          location: {
            coordinate: action.region,
          },
        }
      )

    case 'RIDE_AUTOCOMPLETE_SET_LOCATION':
      return action.location
    case 'RIDE_EXIT_AUTOCOMPLETE_SCREEN':
      return null
    default:
      return state
  }
}

export const currentFareReducer = (state = null, action) => {
  switch (action.type) {
    case 'SET_CURRENT_FARE':
      return action.fare
    default:
      return state
  }
}

export const fareOverviewReducer = (state = { status: 'idle' }, action) => {
  switch (action.type) {
    case 'RIDE_SELECT_VEHICLE':
      return { status: 'loading' }
    case 'RIDE_GET_FARE_OVERVIEW':
      return { status: 'loading' }
    case 'RIDE_SET_FARE_OVERVIEW':
      return {
        status: 'loaded',
        fareOverview: action.fareOverview,
      }
    case 'RIDE_SELECT_VEHICLE_ERROR':
      return {
        status: 'error',
        error: action.error,
      }
    case 'RIDE_CHECK_PROMO_CODE':
      return { ...state, status: 'loading', error: null }
    case 'RIDE_APPLY_PROMO_CODE_ERROR':
      return {
        status: 'loaded',
        fareOverview: action.fareOverview,
        error: action.error,
      }
    case 'RIDE_SET_LOCATION':
    case 'RIDE_REMOVE_DESTINATION':
      return {
        status: 'idle',
      }
    default:
      return state
  }
}

export const selectedProductIdReducer = (state = null, action) => {
  switch (action.type) {
    case 'RIDE_SET_SELECTED_PRODUCT_ID':
    case 'RIDE_SELECT_VEHICLE':
      return action.productId
    default:
      return state
  }
}

export const resetReducer = reducer => (state, action) => {
  switch (action.type) {
    case 'RIDE_RESET_STATE':
      return reducer(undefined, action)
    default:
      return reducer(state, action)
  }
}

export const isLoadingCurrentTripReducer = (state = false, action) => {
  switch (action.type) {
    case 'RIDE_LOAD_CURRENT_TRIP':
      return true
    case 'RIDE_FINISH_LOAD_CURRENT_TRIP':
      return false
    default:
      return state
  }
}

export const currentTripNetworkReducer = (
  state = { status: 'loading' },
  action,
) => {
  switch (action.type) {
    case 'RIDE_LOAD_CURRENT_TRIP':
      return { status: 'loading' }
    case 'RIDE_RESET_STATE':
    case 'RIDE_FINISH_LOAD_CURRENT_TRIP':
      return {
        status: 'loaded',
      }
    case 'RIDE_LOAD_CURRENT_TRIP_ERROR':
      return {
        status: 'error',
        error: action.error,
      }
    default:
      return state
  }
}

export const productReducer = (state = [], action) => {
  switch (action.type) {
    case 'RIDE_ESTIMATES':
    case 'RIDE_FIND_TRIP_OPTIONS_COMPLETE':
    case 'RIDE_SET_PRODUCTS':
      return action.products
    case 'RIDE_ESTIMATES_ERROR':
      return []
    default:
      return state
  }
}

export const loadPickupEstimationReducer = (
  state = { status: 'idle' },
  action,
) => {
  switch (action.type) {
    case 'RIDE_ESTIMATES':
      return { status: 'loaded' }
    case 'RIDE_REMOVE_DESTINATION':
    case 'RIDE_SET_LOCATION':
      return { status: 'loading' }
    case 'RIDE_ESTIMATES_ERROR':
      return { status: 'error', error: action.error }
    default:
      return state
  }
}

export const rideModeReducer = (state = 'select-route', action) => {
  switch (action.type) {
    case 'RIDE_BOOK_ERROR':
    case 'RIDE_BOOKING_INTERRUPT':
    case 'RIDE_SELECT_VEHICLE':
      return 'booking-confirmation'
    case 'RIDE_BOOK_VEHICLE':
      return 'riding'
    case 'RIDE_REMOVE_DESTINATION':
      return 'select-route'
    case 'RIDE_SET_LOCATION':
      return state === 'booking-confirmation'
        ? 'booking-confirmation'
        : 'select-route'
    case 'RIDE_SELECT_SUGGESTION':
      return state === 'booking-confirmation'
        ? 'booking-confirmation'
        : 'select-route'
    case 'RIDE_SELECT_ADDRESS':
      return state === 'booking-confirmation'
        ? 'booking-confirmation'
        : 'select-route'
    case 'RIDE_CANCEL_SELECTED_PRODUCT':
      return 'select-route'
    case 'RIDE_CURRENT_TRIP_STATUS':
      if (
        (action.currentTrip.status === 'completed' &&
          action.currentTrip.data.payment.receipt_ready) ||
        action.currentTrip.status === 'rider_canceled' ||
        action.currentTrip.status === 'driver_canceled' ||
        action.currentTrip.status === 'no_drivers_available'
      ) {
        return 'select-route'
      }
      return 'riding'
    case 'RIDE_ESTIMATES_ERROR':
      return 'select-route'
    default:
      return state
  }
}

export const rideCancellationProgressReducer = (
  state = { status: 'idle' },
  action,
) => {
  switch (action.type) {
    case 'RIDE_CANCEL_BOOKING':
      return { status: 'loading' }
    case 'RIDE_CANCEL_BOOKING_ERROR':
      return { status: 'error', error: action.error }
    case 'RIDE_CANCEL_BOOKING_FINISH':
      return { status: 'loaded' }
    default:
      return state
  }
}

export const zoomReducer = (state = false, action) => {
  switch (action.type) {
    case 'RIDE_SET_SHOULD_ZOOM':
      return action.shouldZoom
    default:
      return state
  }
}

export const termsOfServiceInterruptReducer = (state = false, action) => {
  switch (action.type) {
    case 'RIDE_BOOKING_INTERRUPT':
      return action.interrupt.type === 'tos_tokopedia'
    case 'RIDE_BOOK_VEHICLE':
    case 'RIDE_REJECT_TOS':
      return false

    default:
      return state
  }
}

export const interruptReducer = (state = null, action) => {
  switch (action.type) {
    case 'RIDE_BOOKING_INTERRUPT':
      return action.interrupt

    default:
      return state
  }
}

export const promoCodeAppliedReducer = (state = null, action) => {
  switch (action.type) {
    case 'RIDE_CHECK_PROMO_CODE':
      return action.promoCode.toUpperCase()
    case 'RIDE_APPLY_PROMO_CODE':
      return action.promoCode.toUpperCase()
    case 'RIDE_REMOVE_PROMO_CODE':
      return null
    case 'RIDE_APPLY_PROMO_CODE_ERROR':
      return null
    default:
      return state
  }
}

export const selectedAddressReducer = (state = { status: 'idle' }, action) => {
  switch (action.type) {
    case 'RIDE_SELECT_SUGGESTION':
      return { status: 'loading' }
    case 'RIDE_AUTO_DETECT_LOCATION':
      return { status: 'loading' }
    case 'RIDE_SELECT_ADDRESS':
      return { status: 'loaded' }
    case 'RIDE_SELECT_SUGGESTION_ERROR':
      return { status: 'idle' }
    case 'RIDE_AUTO_DETECT_LOCATION_ERROR':
      return { status: 'idle' }
    default:
      return state
  }
}

export const loadShareUrlTripReducer = (
  state = { status: 'idle', url: null },
  action,
) => {
  switch (action.type) {
    case 'RIDE_GET_SHARE_URL_TRIP':
      return { status: 'loading', url: null }
    case 'RIDE_SET_SHARE_URL_TRIP':
      return { status: 'loaded', url: action.url }
    default:
      return state
  }
}

// detect is location from suggestion place / recent address or map
// affect on map region change
// when map region chaneg and locationsource != map, then location should not update again
export const locationSourceReducer = (
  state = { source: 'map', status: 'idle' },
  action,
) => {
  switch (action.type) {
    case 'RIDE_SELECT_SUGGESTION':
    case 'RIDE_SELECT_ADDRESS':
      return { source: 'suggestion', status: 'loading' }
    case 'RIDE_REMOVE_DESTINATION':
      return { source: 'suggestion', status: 'loading' }
    case 'RIDE_SET_LOCATION':
      return { ...state, status: 'loaded' }
    case 'RIDE_REGION_CHANGE_SOURCE':
      return { source: action.source, status: 'loaded' }
    default:
      return state
  }
}

export default resetReducer(
  combineReducers({
    predictions: predictionReducer,
    routeSelection: endpointReducer,
    searchType: searchTypeReducer,
    locationSource: locationSourceReducer,
    directions: directionReducer,
    timeEstimations: timeEstimationReducer,
    selectedTripOption: selectedTripOptionReducer,
    requestStatus: rideRequestReducer,
    currentTrip: currentTripReducer,
    route: rideRouteReducer,
    isDraggingMap: mapDragReducer,
    locationSearch: locationSearchReducer,
    currentFare: currentFareReducer,
    fareOverviewLoadStatus: fareOverviewReducer,
    selectedProductId: selectedProductIdReducer,
    loadCurrentTripStatus: currentTripNetworkReducer,
    products: productReducer,
    loadPickupEstimationStatus: loadPickupEstimationReducer,
    priceEstimations: priceEstimationReducer,
    mode: rideModeReducer,
    cancellationProgress: rideCancellationProgressReducer,
    shouldZoom: zoomReducer,
    showTermsOfServiceInterrupt: termsOfServiceInterruptReducer,
    interrupt: interruptReducer,
    promoCodeApplied: promoCodeAppliedReducer,
    loadSelectedAddress: selectedAddressReducer,
    loadShareUrlTrip: loadShareUrlTripReducer,
    recentAddresses: recentAddressesReducer,
  }),
)
