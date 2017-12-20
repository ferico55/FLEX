// @flow

import { Alert, AsyncStorage } from 'react-native'
import { combineEpics } from 'redux-observable'
import { Observable } from 'rxjs'
import flatten from 'lodash/flatten'
import Navigator from 'native-navigation'
import DeviceInfo from 'react-native-device-info'
import { ReactInteractionHelper } from 'NativeModules'

import {
  getFareOverview,
  getPickupEstimation,
  placeDetailFromId,
  placeDetailFromLocation,
  getAutocomplete,
  bookRide,
  getRoute,
  getTripStatus,
  getCurrentTrip,
  getProducts,
  getProductDetail,
  getPriceEstimation,
  cancelBooking,
  isRegisteredInterruptCode,
  getShareUrl,
  getRecentAddresses,
  getPaymentMethods,
} from '../Services/api'
import { getCurrentLocation, trackEvent } from '../Lib/RideHelper'

export const openCancelDialog = () => Navigator.push('RideCancellationScreen')

export const openReceipt = requestId => () => {
  Navigator.push('RideReceiptScreen', { requestId })
}

const removeStoredRequestId = () => AsyncStorage.removeItem('ride-request-id')

const ignoreError = () => Observable.empty()

const zoom = [
  {
    type: 'RIDE_SET_SHOULD_ZOOM',
    shouldZoom: true,
  },
  {
    type: 'RIDE_SET_SHOULD_ZOOM',
    shouldZoom: false,
  },
]

const bookVehicleEpic = (action$, store) =>
  action$
    .ofType('RIDE_BOOK_VEHICLE')
    .switchMap(({ productId, tosConfirmation }) => {
      const {
        source: { location: { coordinate: startingPoint } },
        destination: { location: { coordinate: destinationPoint } },
      } = store.getState().routeSelection
      const { source, destination } = store.getState().routeSelection
      let promoCode = store.getState().promoCodeApplied
      promoCode = promoCode ? { promocode: promoCode } : {}

      return Observable.from(
        getFareOverview(productId, startingPoint, destinationPoint, promoCode),
      )
        .map(fareOverview => fareOverview.fare.fare_id)
        .switchMap(fareId => {
          const { products } = store.getState()
          const product = products.filter(
            product => product.product_id === productId,
          )[0]
          const startAddressName = { start_address_name: source.name }
          const endAddressName = { end_address_name: destination.name }
          const startAddress = { start_address: source.formatted_address }
          const endAddress = { end_address: destination.formatted_address }
          const deviceType = { device_type: DeviceInfo.getModel() }

          return bookRide({
            productId,
            productName: product.display_name,
            promoCode,
            fareId,
            pickupPoint: startingPoint,
            dropOffPoint: destinationPoint,
            tosConfirmation,
            startAddress,
            endAddress,
            startAddressName,
            endAddressName,
            deviceType,
          })
        })
        .do(result => {
          switch (result.data.code) {
            case 'interrupt':
              Navigator.push('RideTopupTokocashScreen', {
                uri: result.data.meta.interrupt.href,
              })
              break
            case 'pending_fare':
              Navigator.present('RidePendingFareScreen')
              break
            case 'surge_confirmation':
              Navigator.push('RideWebViewScreen', {
                url: result.data.meta.surge_confirmation.href,
                expectedCode: 'surge_confirmation_id',
              })
              break

            case 'tos_accept_confirmation':
              Navigator.push('RideWebViewScreen', {
                url: result.data.meta.tos_accept_confirmation.href,
                expectedCode: 'tos_confirmation_id',
              })
              break

            case 'tos_tokopedia':
              // Alert.alert('Terms of Service', 'Accept?', [
              //   { text: 'No', style: 'cancel' },
              //   {
              //     text: 'view TOS',
              //     onPress: () => {
              //       Navigator.push('RideWebViewScreen', {
              //         url: result.data.meta.tos_tokopedia.href,
              //         expectedCode: 'tos_tokopedia_id',
              //       })
              //     },
              //   },
              //   {
              //     text: 'Yes',
              //     onPress: () =>
              //       store.dispatch({
              //         type: 'RIDE_BOOK_VEHICLE',
              //         tosConfirmation: {
              //           tos_tokopedia_id:
              //             result.data.meta.tos_tokopedia.tos_tokopedia_id,
              //         },
              //         productId,
              //       }),
              //   },
              // ])

              break

            case 'wallet_activation':
              Navigator.push('RideWebViewScreen', {
                url: result.data.meta.wallet_activation.href,
                productId,
              })
              break

            default:
              console.log(
                'ride requested with request id',
                result.data.request_id,
              )

              AsyncStorage.setItem('ride-request-id', result.data.request_id)

              // TODO remove?
              store.dispatch({
                type: 'RIDE_TRIP_BOOKED',
                requestId: result.data.request_id,
              })

              store.dispatch({
                type: 'RIDE_POLL_STATUS',
                requestId: result.data.request_id,
              })
          }
        })
        .map(result => ({
          type: 'RIDE_BOOKING_RESULT',
          result,
        }))
        .catch(error => {
          // when get connection timeout in prev request
          // we will get this error for next request
          // this happens when timeout but uber data laready updated
          if (error.description === 'Ride is in progress') {
            return Observable.of({ type: 'RIDE_LOAD_CURRENT_TRIP' })
          }

          if (error.code === 'no_internet') {
            ReactInteractionHelper.showErrorStickyAlert(error.description)
          }

          return Observable.of({
            type: 'RIDE_BOOK_ERROR',
            error,
          })
        })
    })

const getInterrupt = bookingResult => {
  if (bookingResult.code === 'tos_tokopedia') {
    return {
      type: 'tos_tokopedia',
      code: {
        name: 'tos_tokopedia_id',
        value: bookingResult.meta.tos_tokopedia.tos_tokopedia_id,
      },
      link: bookingResult.meta.tos_tokopedia.href,
    }
  }

  return {
    type: 'others',
  }
}

const rideInterruptEpic = (action$, store) =>
  action$
    .ofType('RIDE_BOOKING_RESULT')
    .filter(
      ({ result }) => result.data.code && isRegisteredInterruptCode(result.data.code),
    )
    .map(({ result }) => ({
      type: 'RIDE_BOOKING_INTERRUPT',
      interrupt: getInterrupt(result.data),
    }))

const findRouteEpic = (action$, store) =>
  action$
    .ofType('RIDE_SET_LOCATION')
    .filter(() => store.getState().routeSelection.destination)
    .switchMap(() => {
      const { source, destination } = store.getState().routeSelection

      return Observable.from(getRoute(source, destination))
        .filter(route => route != null)
        .map(route => ({
          type: 'RIDE_DIRECTIONS',
          directions: route.coordinates,
          route,
        }))
        .do(() => {
          const { selectedProductId, mode } = store.getState()
          if (selectedProductId && mode === 'booking-confirmation') {
            store.dispatch({
              type: 'RIDE_GET_FARE_OVERVIEW',
              productId: selectedProductId,
            })
          }
        })
        .catch(error => {
          ReactInteractionHelper.showErrorStickyAlert(error.description)
          return ignoreError
        })
        .concat(zoom)
    })

const pickupEstimationEpic = (action$, store) =>
  action$
    .ofType('RIDE_REMOVE_DESTINATION', 'RIDE_SET_LOCATION')
    .do(() => {
      const mode = store.getState().mode
      const requestStatus = store.getState().requestStatus
      if (mode === 'booking-confirmation' && requestStatus.status === 'error') {
        store.dispatch({
          type: 'RIDE_CANCEL_SELECTED_PRODUCT',
        })
      }
    })
    .map(() => store.getState().routeSelection.source)
    .switchMap(() => {
      const { source, destination } = store.getState().routeSelection
      const products$ = getProducts(source.location.coordinate)

      const timeEstimations$ = getPickupEstimation(source)

      const priceEstimations$ = Observable.of(destination)
        .filter(destination => !!destination)
        .flatMap(() =>
          getPriceEstimation(
            source.location.coordinate,
            destination.location.coordinate,
          ),
        )
        .defaultIfEmpty([])

      return Observable.zip(products$, timeEstimations$, priceEstimations$)
        .map(([products, estimates, priceEstimations]) => ({
          type: 'RIDE_ESTIMATES',
          estimates,
          products,
          priceEstimations,
        }))
        .catch(error => {
          if (error.code === 'no_internet') {
            ReactInteractionHelper.showErrorStickyAlert(error.description)
          }
          return Observable.of({
            type: 'RIDE_ESTIMATES_ERROR',
            error: error.code === 'no_internet' ? { description: '' } : error,
          })
        })
    })

const mapZoomEpic = action$ =>
  action$
    .ofType('RIDE_REMOVE_DESTINATION')
    .delay(50) // TODO: this delay should not be here. currently used because the zoom action doesn't seem to be processed properly
    .switchMapTo(zoom)

const currentTripStatusEpic = action$ =>
  action$.ofType('RIDE_LOAD_CURRENT_TRIP').switchMap(() => {
    const currentTrip$ = Observable.fromPromise(getCurrentTrip()).shareReplay(1)
    const products$ = currentTrip$
      .filter(currentTrip => currentTrip.data && currentTrip.data.product_id)
      .map(currentTrip => currentTrip.data.product_id)
      .switchMap(productId => getProductDetail(productId))
      .map(product => [
        {
          type: 'RIDE_SET_SELECTED_PRODUCT_ID',
          productId: product.product_id,
        },
        {
          type: 'RIDE_SET_PRODUCTS',
          products: [product],
        },
      ])

    const location$ = currentTrip$
      .filter(
        currentTrip =>
          currentTrip.data &&
          currentTrip.data.pickup &&
          currentTrip.data.destination,
      )
      .map(currentTrip => [
        currentTrip.data.pickup,
        currentTrip.data.destination,
      ])
      .switchMap(([pickup, destination]) =>
        Observable.zip(
          Observable.from(placeDetailFromLocation(pickup)),
          Observable.from(placeDetailFromLocation(destination)),
        ),
      )
      .map(([source, destination]) => [
        {
          type: 'RIDE_CURRENT_TRIP_LOCATION',
          source,
          destination,
        },
        {
          type: 'RIDE_GET_CURRENT_LOCATION',
        },
      ])

    const currentTripAction$ = currentTrip$
      .filter(currentTrip => currentTrip.data && currentTrip.data.request_id)
      .mergeMap(currentTrip =>
        Observable.fromPromise(getCurrentLocation()).map(location => {
          const userLocation = {
            latitude: location.latitude,
            longitude: location.longitude,
          }
          return { ...currentTrip, userLocation }
        }),
      )
      .flatMap(currentTrip => {
        const trip = {
          status: currentTrip.data.status,
          driverLocation: currentTrip.data.location,
          userLocation: currentTrip.userLocation,
          data: currentTrip.data,
        }

        return [
          {
            type: 'RIDE_POLL_STATUS',
            requestId: currentTrip.data.request_id,
          },
          {
            type: 'RIDE_CURRENT_TRIP_STATUS',
            currentTrip: trip,
            shouldZoom: true,
          },
          {
            type: 'RIDE_FINISH_LOAD_CURRENT_TRIP',
            currentTrip: trip,
          },
          {
            type: 'RIDE_CHECK_SHARE_URL_TRIP',
          },
        ]
      })
      .toArray()

    return currentTrip$
      .filter(currentTrip => currentTrip.data && currentTrip.data.request_id)
      .do(currentTrip => {
        AsyncStorage.getItem('ride-request-id')
          .then(requestId => {
            if (requestId !== currentTrip.data.request_id) {
              return
            }

            if (currentTrip.data.status === 'driver_canceled') {
              Alert.alert(
                'Alert',
                'Sorry, driver cancelled your request. Please try again',
              )
            } else if (currentTrip.data.status === 'no_drivers_available') {
              Alert.alert('No drivers availables')
            } else if (currentTrip.data.status === 'completed') {
              Navigator.push('RideReceiptScreen', { requestId })
            }
          })
          .then(() => {
            const currentStatusToRemoveRequestId = [
              'completed',
              'driver_canceled',
              'rider_canceled',
              'no_drivers_available',
            ]
            if (
              currentStatusToRemoveRequestId.includes(currentTrip.data.status)
            ) {
              AsyncStorage.removeItem('ride-request-id')
            } else {
              // always to add to AsyncStorage
              // it's to handle when prev request is connection timeout but
              // on the server ride is in progress
              AsyncStorage.setItem(
                'ride-request-id',
                currentTrip.data.request_id ? currentTrip.data.request_id : '',
              )
            }
          })
      })
      .filter(
        currentTrip =>
          currentTrip.data.status !== 'completed' &&
          currentTrip.data.status !== 'driver_canceled' &&
          currentTrip.data.status !== 'rider_canceled' &&
          currentTrip.data.status !== 'no_drivers_available',
      )
      .switchMap(() =>
        Observable.zip(
          products$,
          currentTripAction$,
          location$,
        ).flatMap(result => flatten(result)),
      )
      .defaultIfEmpty({
        type: 'RIDE_FINISH_LOAD_CURRENT_TRIP',
        currentTrip: null,
      })
      .catch(error =>
        Observable.of({
          type: 'RIDE_LOAD_CURRENT_TRIP_ERROR',
          error,
        }),
      )
  })

const selectVehicleEpic = (action$, store) =>
  action$.ofType('RIDE_SELECT_VEHICLE').switchMap(({ productId }) => {
    const { source, destination } = store.getState().routeSelection
    return Observable.from(
      getFareOverview(
        productId,
        source.location.coordinate,
        destination.location.coordinate,
      ),
    )
      .flatMap(fareOverview => [
        {
          type: 'RIDE_SET_FARE_OVERVIEW',
          fareOverview,
        },
        {
          type: 'RIDE_APPLY_PROMO_CODE',
          promoCode: fareOverview.code,
        },
      ])
      .catch(error => {
        if (error.code === 'no_internet') {
          ReactInteractionHelper.showErrorStickyAlert(error.description)
        }
        return Observable.of({
          type: 'RIDE_SELECT_VEHICLE_ERROR',
          error: error.code === 'no_internet' ? { description: '' } : error,
        })
      })
  })

const fareOverviewEpic = (action$, store) =>
  action$.ofType('RIDE_GET_FARE_OVERVIEW').mergeMap(() => {
    const {
      source,
      destination,
      selectedProductId,
    } = store.getState().routeSelection
    return Observable.from(
      getFareOverview(
        selectedProductId,
        source.location.coordinate,
        destination.location.coordinate,
      ),
    )
      .flatMap(fareOverview => [
        {
          type: 'RIDE_SET_FARE_OVERVIEW',
          fareOverview,
        },
        {
          type: 'RIDE_APPLY_PROMO_CODE',
          promoCode: fareOverview.code,
        },
      ])
      .catch(error => {
        if (error.code === 'no_internet') {
          ReactInteractionHelper.showErrorStickyAlert(error.description)
        }
        return Observable.of({
          type: 'RIDE_SELECT_VEHICLE_ERROR',
          error: error.code === 'no_internet' ? { description: '' } : error,
        })
      })
  })

const pollStatusEpic = (action$, store) =>
  action$
    .ofType('RIDE_POLL_STATUS')
    .do(({ lastTrip }) => {
      if (lastTrip && lastTrip.data.status === 'no_drivers_available') {
        Alert.alert('No drivers availables')
      }
    })
    .flatMap(({ delay = 4, lastTrip, requestId }) =>
      Observable.of(null)
        .filter(
          () =>
            !lastTrip ||
            (!lastTrip.data.payment.receipt_ready &&
              lastTrip.data.status !== 'no_drivers_available'),
        )
        .delay(delay * 1000)
        .flatMap(() => getTripStatus(requestId))
        .mergeMap(data =>
          Observable.fromPromise(getCurrentLocation()).map(location => {
            const userLocation = {
              latitude: location.latitude,
              longitude: location.longitude,
            }
            return { ...data, userLocation }
          }),
        )
        .flatMap(data => [
          {
            type: 'RIDE_POLL_STATUS',
            delay: data.pollWait,
            lastTrip: data,
            requestId,
          },
          {
            type: 'RIDE_CURRENT_TRIP_STATUS',
            currentTrip: data,
          },
          {
            type: 'RIDE_CHECK_SHARE_URL_TRIP',
          },
        ])
        .catch((error, observable) => observable)
        .takeUntil(action$.ofType('RIDE_RESET_STATE')),
    )

const driverRouteEpic = (action, store) =>
  action
    .ofType('RIDE_CURRENT_TRIP_STATUS')
    .switchMap(({ currentTrip, shouldZoom }) =>
      Observable.of(currentTrip)
        .filter(() => {
          const statusTripNoNeedToRideDirection = [
            // 'processing',
            'driver_canceled',
            'rider_canceled',
            'no_drivers_available',
          ]
          return !statusTripNoNeedToRideDirection.includes(
            currentTrip.data.status,
          )
        })
        .switchMap(() => {
          const dropoffLocation = {
            location: {
              coordinate: currentTrip.data.destination,
            },
          }

          const pickupLocation = {
            location: {
              coordinate: currentTrip.data.pickup,
            },
          }

          const currentLocation = {
            location: {
              coordinate: currentTrip.data.location,
            },
          }

          const userLocation = {
            location: {
              coordinate: currentTrip.userLocation,
            },
          }

          if (currentTrip.data.status === 'accepted') {
            // return getRoute(pickupLocation, dropoffLocation)
            return getRoute(currentLocation, pickupLocation)
          }

          if (currentTrip.data.status === 'arriving') {
            return getRoute(currentLocation, pickupLocation)
          }

          if (currentTrip.data.status === 'in_progress') {
            return getRoute(userLocation, dropoffLocation)
          }

          return getRoute(currentLocation, dropoffLocation)
        })
        .takeUntil(action.ofType('RIDE_RESET_STATE'))
        .filter(route => route != null)
        .map(route => ({
          type: 'RIDE_DIRECTIONS',
          directions: route.coordinates,
          route,
        }))
        .concat(shouldZoom ? zoom : Observable.empty()),
    )

const regionChangedEpic = (action, store) =>
  action
    .ofType('RIDE_REGION_CHANGE')
    .filter(
      () =>
        !store.getState().routeSelection.destination &&
        store.getState().locationSource.source === 'map',
    )
    .switchMap(({ region }) =>
      Observable.fromPromise(placeDetailFromLocation(region))
        .mergeMap(place =>
          Observable.fromPromise(
            placeDetailFromId(place.location.placeId),
          ).map(prediction => ({
            type: 'RIDE_SET_LOCATION',
            searchType: 'source',
            prediction,
          })),
        )
        .catch(error => {
          ReactInteractionHelper.showErrorStickyAlert(error.description)
          return Observable.of({
            type: 'RIDE_REGION_CHANGE_ERROR',
          })
        }),
    )

const regionChangeSourceEpic = (action$, store) =>
  action$
    .ofType('RIDE_REGION_CHANGE')
    .filter(() => store.getState().locationSource.source !== 'map')
    .map(() => ({
      type: 'RIDE_REGION_CHANGE_SOURCE',
      source: 'map',
    }))

const autocompleteRegionChangedEpic = action$ =>
  action$
    .ofType('RIDE_AUTOCOMPLETE_REGION_CHANGE')
    .filter(action => action.region)
    .switchMap(({ region }) =>
      Observable.fromPromise(placeDetailFromLocation(region))
        .mergeMap(place =>
          Observable.fromPromise(
            placeDetailFromId(place.location.placeId),
          ).map(location => ({
            type: 'RIDE_AUTOCOMPLETE_SET_LOCATION',
            location,
          })),
        )
        .catch(error => {
          ReactInteractionHelper.showErrorStickyAlert(error.description)
          return ignoreError
        }),
    )

const autocompleteEpic = (action$, store) =>
  action$
    .ofType('RIDE_TYPE_AUTOCOMPLETE')
    .debounceTime(250)
    .do(({ query }) => {
      if (!query) {
        store.dispatch({
          type: 'RECEIVE_PREDICTIONS_ERROR',
          error: { description: 'Address is required' },
        })
      }
    })
    .filter(({ query }) => query)
    .switchMap(({ query }) =>
      Observable.from(getAutocomplete(query))
        .map(predictions => ({
          type: 'RECEIVE_PREDICTIONS',
          predictions,
        }))
        .catch(error => {
          if (error.code === 'no_internet') {
            ReactInteractionHelper.showErrorStickyAlert(error.description)
          }
          return Observable.of({
            type: 'RECEIVE_PREDICTIONS_ERROR',
            error: error.code === 'no_internet' ? { description: '' } : error,
          })
        }),
    )

const selectSuggestionEpic = (action$, store) =>
  action$
    .ofType('RIDE_SELECT_SUGGESTION')
    .debounceTime(250)
    .switchMap(({ placeId, trackAction, isAutoDetectLocation }) =>
      Observable.from(placeDetailFromId(placeId))
        .do(address => {
          const searchType = store.getState().searchType
          const screenName =
            searchType === 'source'
              ? 'Ride Source Change Screen'
              : 'Ride Destination Change Screen'
          if (isAutoDetectLocation && trackAction) {
            trackEvent(
              'GenericUberEvent',
              `${trackAction}`,
              `${screenName} - ${address.name}`,
            )
          } else if (!isAutoDetectLocation && trackAction) {
            trackEvent(
              'GenericUberEvent',
              `${trackAction}`,
              `${screenName} - ${address.name}`,
            )
          }
        })
        .map(address => ({
          type: 'RIDE_SELECT_ADDRESS',
          address,
        }))
        .catch(error => {
          ReactInteractionHelper.showErrorStickyAlert(error.description)
          return Observable.of({
            type: 'RIDE_SELECT_SUGGESTION_ERROR',
          })
        }),
    )

const selectAddressEpic = (action$, store) =>
  action$
    .ofType('RIDE_SELECT_ADDRESS')
    .do(() => {
      Navigator.pop()
    })
    .delay(100)
    .do(({ address }) => {
      const searchType = store.getState().searchType
      const source =
        searchType === 'source'
          ? address
          : store.getState().routeSelection.source

      const destination =
        searchType === 'destination'
          ? address
          : store.getState().routeSelection.destination

      if (
        source &&
        destination &&
        source.location.coordinate.latitude ===
          destination.location.coordinate.latitude &&
        source.location.coordinate.longitude ===
          destination.location.coordinate.longitude
      ) {
        Alert.alert('Destination not allowed to be same with pickup')
        store.dispatch({ type: 'RIDE_REMOVE_DESTINATION' })
      }
    })
    .filter(({ address }) => {
      const searchType = store.getState().searchType
      const source =
        searchType === 'source'
          ? address
          : store.getState().routeSelection.source

      const destination =
        searchType === 'destination'
          ? address
          : store.getState().routeSelection.destination

      if (
        source &&
        destination &&
        source.location.coordinate.latitude ===
          destination.location.coordinate.latitude &&
        source.location.coordinate.longitude ===
          destination.location.coordinate.longitude
      ) {
        return false
      }
      return true
    })
    .switchMap(({ address }) =>
      Observable.of({
        type: 'RIDE_SET_LOCATION',
        prediction: address,
        searchType: store.getState().searchType,
      })
        .delay(100)
        .concat(zoom),
    )

const openReceiptEpic = (action$, store) =>
  action$
    .ofType('RIDE_CURRENT_TRIP_STATUS')
    .filter(
      ({ currentTrip }) =>
        currentTrip.data.payment.receipt_ready ||
        currentTrip.data.status === 'rider_canceled',
    )
    .do(({ currentTrip }) => {
      removeStoredRequestId()

      store.dispatch(openReceipt(currentTrip.data.request_id))
    })
    .mergeMap(() => [
      { type: 'RIDE_RESET_STATE' },
      { type: 'RIDE_GET_PAYMENT_METHOD' },
    ])

const showDriverCancelEpic = action$ =>
  action$
    .ofType('RIDE_CURRENT_TRIP_STATUS')
    .filter(({ currentTrip }) => currentTrip.data.status === 'driver_canceled')
    .do(() => {
      removeStoredRequestId()

      Alert.alert(
        'Alert',
        'Sorry, driver cancelled your request. Please try again',
      )
    })
    .mergeMap(() => [
      { type: 'RIDE_RESET_STATE' },
      { type: 'RIDE_GET_PAYMENT_METHOD' },
    ])

const cancelBookingEpic = action$ =>
  action$.ofType('RIDE_CANCEL_BOOKING').switchMap(({ reason }) =>
    Observable.from(cancelBooking(reason))
      .do(() => Navigator.pop())
      .mergeMap(() => [
        { type: 'RIDE_RESET_STATE' },
        { type: 'RIDE_GET_PAYMENT_METHOD' },
      ])
      .catch(error =>
        Observable.of({
          type: 'RIDE_CANCEL_BOOKING_ERROR',
          error,
        }),
      ),
  )

const searchEpic = (action$, store) =>
  action$
    .ofType('RIDE_SEARCH')
    .filter(() => store.getState().mode !== 'riding')
    .do(() => Navigator.push('RidePlacesAutocompleteScreen'))
    .ignoreElements()

const autoDetectLocationEpic = (action$, store) =>
  action$
    .ofType('RIDE_AUTO_DETECT_LOCATION')
    .filter(action => action.region)
    .switchMap(({ region }) =>
      Observable.from(placeDetailFromLocation(region))
        .map(response => ({
          type: 'RIDE_SELECT_SUGGESTION',
          placeId: response.location.placeId,
          trackAction: 'click autodetect current location',
          isAutoDetectLocation: true,
        }))
        .catch(error => {
          ReactInteractionHelper.showErrorStickyAlert(error.description)
          return Observable.of({
            type: 'RIDE_AUTO_DETECT_LOCATION_ERROR',
          })
        }),
    )

const applyPromoCodeEpic = (action$, store) =>
  action$
    .ofType('RIDE_CHECK_PROMO_CODE')
    .switchMap(({ promoCode: promocode }) => {
      const productId = store.getState().selectedProductId
      const { source, destination } = store.getState().routeSelection
      const previousFareOverview = store.getState().fareOverviewLoadStatus
        .fareOverview

      // generate object to post on getFareOverview
      // if null then should generate empty object, so API will not sent null promoCode
      const promoCode = promocode ? { promocode } : {}

      return Observable.from(
        getFareOverview(
          productId,
          source.location.coordinate,
          destination.location.coordinate,
          promoCode,
        ),
      )
        .do(() => {
          Navigator.pop()
        })
        .flatMap(fareOverview => [
          {
            type: 'RIDE_SET_FARE_OVERVIEW',
            fareOverview,
          },
          {
            type: 'RIDE_APPLY_PROMO_CODE',
            promoCode: promocode,
          },
        ])
        .catch(error => {
          if (error.code === 'no_internet') {
            ReactInteractionHelper.showErrorStickyAlert(error.description)
          }
          return Observable.of({
            type: 'RIDE_APPLY_PROMO_CODE_ERROR',
            error: error.code === 'no_internet' ? { description: '' } : error,
            fareOverview: previousFareOverview,
          })
        })
    })

const checkShareUtlTropEpic = (action$, store) =>
  action$
    .ofType('RIDE_CHECK_SHARE_URL_TRIP')
    .filter(() => {
      const { loadShareUrlTrip, currentTrip } = store.getState()
      if (
        currentTrip &&
        currentTrip.data.status !== 'processing' &&
        loadShareUrlTrip.status === 'idle'
      ) {
        return true
      }
      return false
    })
    .map(() => ({
      type: 'RIDE_GET_SHARE_URL_TRIP',
    }))

const getShareUrlTripEpic = (action$, store) =>
  action$.ofType('RIDE_GET_SHARE_URL_TRIP').switchMap(() => {
    const requestId =
      store.getState().currentTrip.data.request_id ||
      store.getState().requestStatus.requestId

    return Observable.from(getShareUrl(requestId))
      .map(url => ({
        type: 'RIDE_SET_SHARE_URL_TRIP',
        url,
      }))
      .catch(ignoreError)
  })

const findPickupEstimationEpic = action$ =>
  action$.ofType('RIDE_FIND_PICKUP_ESTIMATION').mapTo({
    type: 'RIDE_SET_LOCATION',
  })

const getRecentAddressesEpic = action$ =>
  action$.ofType('RIDE_GET_RECENT_ADDRESSES').switchMap(() =>
    Observable.from(getRecentAddresses())
      .map(recentAddresses => ({
        type: 'RIDE_RECEIVE_RECENT_ADDRESSES',
        recentAddresses,
      }))
      .catch(error => {
        ReactInteractionHelper.showErrorStickyAlert(error.description)
        return Observable.of({
          type: 'RIDE_GET_RECENT_ADDRESSES_ERROR',
          error,
        })
      }),
  )

const getPaymentMethodsEpic = actions$ =>
  actions$.ofType('RIDE_GET_PAYMENT_METHOD').switchMap(() =>
    Observable.from(getPaymentMethods())
      .map(paymentMethods => ({
        type: 'RIDE_GET_PAYMENT_METHOD_SUCCESS',
        paymentMethods: paymentMethods.data,
      }))
      .catch(error => {
        return Observable.of({
          type: 'RIDE_GET_PAYMENT_METHOD_ERROR',
          error,
        })
      }),
  )

export const epic = combineEpics(
  bookVehicleEpic,
  rideInterruptEpic,
  findRouteEpic,
  pickupEstimationEpic,
  currentTripStatusEpic,
  selectVehicleEpic,
  fareOverviewEpic,
  pollStatusEpic,
  driverRouteEpic,
  regionChangedEpic,
  autocompleteRegionChangedEpic,
  autocompleteEpic,
  selectSuggestionEpic,
  openReceiptEpic,
  showDriverCancelEpic,
  cancelBookingEpic,
  searchEpic,
  selectAddressEpic,
  mapZoomEpic,
  autoDetectLocationEpic,
  applyPromoCodeEpic,
  getShareUrlTripEpic,
  checkShareUtlTropEpic,
  findPickupEstimationEpic,
  getRecentAddressesEpic,
  regionChangeSourceEpic,
  getPaymentMethodsEpic,
)
