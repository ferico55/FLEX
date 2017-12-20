import { applyMiddleware, createStore } from 'redux'
import { createEpicMiddleware } from 'redux-observable'
import thunk from 'redux-thunk'

import withStore from '../withStore'
import rideReducer from './Reducers/RideReducer'
import { epic } from './Actions/RideActions'

import RideHailingScreen from './Containers/RideHailingScreen'
import RidePlacesAutocompleteScreen from './Containers/RidePlacesAutocompleteScreen'
import RideWebViewScreen from './Containers/RideWebViewScreen'
import RideReceiptScreen from './Containers/RideReceiptScreen'
import RideHistoryScreen from './Containers/RideHistoryScreen'
import RideHistoryDetailScreen from './Containers/RideHistoryDetailScreen'
import RideCancellationScreen from './Containers/RideCancellationScreen'
import RidePromoCodeScreen from './Containers/RidePromoCodeScreen'
import RidePaymentMethodScreen from './Containers/RidePaymentMethodScreen'
import RideDetailPaymentMethodScreen from './Containers/RideDetailPaymentMethodScreen'
import RidePaymentWebViewScreen from './Containers/RidePaymentWebViewScreen'
import RidePendingFareScreen from './Containers/RidePendingFareScreen'
import RideTopupTokocashScreen from './Components/RideTopupTokocashScreen'

let composer
if (__DEV__) {
  const { composeWithDevTools } = require('remote-redux-devtools')
  composer = composeWithDevTools({
    name: 'Ridehailing',
    port: 8000,
    sendTo: 'http://localhost:8000',
  })
} else {
  composer = id => id
}

const rideStore = createStore(
  rideReducer,
  composer(applyMiddleware(thunk, createEpicMiddleware(epic))),
)

const provided = withStore(rideStore)

export default {
  RideHailing: provided(RideHailingScreen),
  RidePlacesAutocompleteScreen: provided(RidePlacesAutocompleteScreen),
  RideWebViewScreen: provided(RideWebViewScreen),
  RideReceiptScreen: provided(RideReceiptScreen),
  RideHistoryScreen: provided(RideHistoryScreen),
  RideHistoryDetailScreen: provided(RideHistoryDetailScreen),
  RideCancellationScreen: provided(RideCancellationScreen),
  RidePromoCodeScreen: provided(RidePromoCodeScreen),
  RidePaymentMethodScreen: provided(RidePaymentMethodScreen),
  RideDetailPaymentMethodScreen: provided(RideDetailPaymentMethodScreen),
  RidePaymentWebViewScreen: provided(RidePaymentWebViewScreen),
  RidePendingFareScreen: provided(RidePendingFareScreen),
  RideTopupTokocashScreen: provided(RideTopupTokocashScreen),
}
