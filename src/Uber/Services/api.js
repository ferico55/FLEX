import { NativeModules } from 'react-native'

import { Observable } from 'rxjs'

import polyline from 'polyline'

import identity from 'lodash/identity'

const serverUrl = NativeModules.TKPReactURLManager.rideHailingUrl
const request = NativeModules.ReactNetworkManager.request
const googleapisKey = 'AIzaSyDnak2oyQVqnyEvhwS94zzF9CpMRavB-18'

const extractErrorMessage = error => {
  const errorMessageByCode = {
    no_internet: 'No internet connection',
    timeout: 'Connection timeout',
    unknown_error: 'Unknown error, please try again later',
  }

  throw {
    code: error.code,
    description: errorMessageByCode[error.code],
  }
}

export const extractInteruptCode = code => {
  const interuptCode = [
    'tos_tokopedia',
    'tos_accept_confirmation',
    'surge_confirmation',
    'wallet_activation',
    'wallet_topup',
    'interrupt',
    'pending_fare',
  ]
  return interuptCode.includes(code)
}

const rideNetworkRequest = (params, intercept = identity) =>
  request(params)
    .then(intercept)
    .catch(extractErrorMessage)
    .then(result => {
      // detect code error on the resposnse
      if (result.message_error && result.data && result.data.code) {
        // if error code is not include on registered interupt code
        if (!extractInteruptCode(result.data.code)) {
          return Promise.reject({
            description: result.data.message,
          })
        } else if (extractInteruptCode(result.data.code)) {
          // if error code is include on registered interupt code
          return result
        }
      }

      // if any error message but have not interupt code
      if (result.message_error) {
        return Promise.reject({
          description:
            result.data && result.data.message
              ? result.data.message
              : result.message_error[0],
        })
      }

      // by pass response
      return result
    })

const googleNetworkRequest = params =>
  request(params).catch(extractErrorMessage)

export const getCancellationReasons = () =>
  rideNetworkRequest({
    baseUrl: serverUrl,
    method: 'GET',
    path: '/uber/cancel/reasons',
    authorizationMode: 'token',
  }).then(response => response.data.reasons)

export const getFareOverview = (
  productId,
  pickupPoint,
  dropOffPoint,
  promoCode,
) =>
  rideNetworkRequest({
    baseUrl: serverUrl,
    method: 'GET',
    path: '/uber/estimates/fare',
    authorizationMode: 'token',
    config: 'mojito',
    params: {
      start_latitude: pickupPoint.latitude,
      start_longitude: pickupPoint.longitude,
      end_latitude: dropOffPoint.latitude,
      end_longitude: dropOffPoint.longitude,
      product_id: productId,
      ...promoCode, // handle if promoCode is null, then should not sent promoCode
    },
  })
    .then(response => response.data)
    .then(data => {
      if (!data) {
        return Promise.reject({
          description: 'Unable to process fare estimation.',
        })
      }
      return data
    })

export const getAvailablePromos = () =>
  rideNetworkRequest({
    baseUrl: serverUrl,
    method: 'GET',
    path: '/uber/offers',
  })
    .then(response => response.data)
    .then(data => {
      if (!data) {
        return Promise.reject({
          description: 'No promo available.',
        })
      }

      if (data && data.length <= 0) {
        return Promise.reject({
          description: 'No promo available.',
        })
      }
      return data
    })

export const getHistoryFromUri = uri => {
  const params = {}

  const uriParts = uri.split('?')
  const queryParameters = uriParts[1].split('&')
  queryParameters.forEach(item => {
    const components = item.split('=')
    params[components[0]] = components[1]
  })

  return rideNetworkRequest({
    baseUrl: serverUrl,
    method: 'GET',
    path: '/v2/uber/request/history',
    authorizationMode: 'token',
    params,
  })
}

export const getHistory = (pageSize = 10) =>
  rideNetworkRequest({
    baseUrl: serverUrl,
    method: 'GET',
    path: '/v2/uber/request/history',
    authorizationMode: 'token',
    params: {
      page_size: pageSize,
    },
  })

export const getShareUrl = requestId =>
  rideNetworkRequest({
    baseUrl: serverUrl,
    path: '/uber/request/map',
    params: { request_id: requestId },
  }).then(response => response.data.href)

export const getReceipt = requestID => {
  const receiptRequest = Observable.fromPromise(
    rideNetworkRequest({
      baseUrl: serverUrl,
      method: 'GET',
      path: '/uber/request/receipt',
      authorizationMode: 'token',
      params: {
        request_id: requestID,
      },
    }),
  )
  const historyDetailRequest = Observable.fromPromise(
    rideNetworkRequest({
      baseUrl: serverUrl,
      method: 'GET',
      path: '/uber/request/details',
      authorizationMode: 'token',
      params: {
        request_id: requestID,
      },
    }),
  )

  return Observable.zip(receiptRequest, historyDetailRequest).map(response => ({
    receipt: response[0].data,
    detail: response[1].data,
  }))
}

export const getStaticMapUrl = (
  startingPoint,
  destinationPoint,
  size = { w: 600, h: 300 },
) =>
  `https://maps.googleapis.com/maps/api/staticmap?size=${size.w}x${size.h}&maptype=roadmap&markers=color:green%7Clabel:S%7C${startingPoint.latitude},${startingPoint.longitude}&markers=color:red%7Clabel:D%7C${destinationPoint.latitude},${destinationPoint.longitude}&key=${googleapisKey}`

export const postReview = review =>
  rideNetworkRequest({
    baseUrl: serverUrl,
    method: 'POST',
    path: '/uber/rating',
    authorizationMode: 'token',
    params: review,
  })

export const getProducts = ({ latitude, longitude }) =>
  rideNetworkRequest({
    baseUrl: serverUrl,
    path: '/uber/products',
    params: {
      longitude,
      latitude,
    },
  })
    .then(response => response.data)
    .then(data => {
      if (!data || !data.products || data.products.length <= 0) {
        return Promise.reject({
          description: 'No products available.',
        })
      }

      return data.products
    })

export const getPickupEstimation = startingPlace =>
  Promise.resolve(startingPlace.location.coordinate)
    .then(startingPoint =>
      rideNetworkRequest({
        baseUrl: serverUrl,
        path: '/uber/estimates/time',
        params: {
          start_longitude: startingPoint.longitude,
          start_latitude: startingPoint.latitude,
        },
      }),
    )
    .then(response => response.data)
    .then(data => {
      if (!data || !data.times || data.times.length <= 0) {
        return Promise.reject({
          description: 'Unable to process time estimation.',
        })
      }

      return data.times.map(estimation => ({
        ...estimation,
        time: estimation.estimate / 60,
      }))
    })

export const getPriceEstimation = (startingPoint, destinationPoint) =>
  rideNetworkRequest({
    baseUrl: serverUrl,
    path: '/uber/estimates/price',
    params: {
      start_longitude: startingPoint.longitude,
      start_latitude: startingPoint.latitude,
      end_longitude: destinationPoint.longitude,
      end_latitude: destinationPoint.latitude,
    },
  })
    .then(response => response.data)
    .then(data => {
      if (!data || !data.prices || data.prices.length <= 0) {
        return Promise.reject({
          description: 'Unable to process price estimation.',
        })
      }

      return data.prices
    })

export const placeDetailFromLocation = region =>
  rideNetworkRequest({
    baseUrl: 'https://maps.googleapis.com',
    path: '/maps/api/geocode/json',
    params: {
      latlng: `${region.latitude},${region.longitude}`,
      key: googleapisKey,
    },
  }).then(response => {
    if (
      response.results &&
      Array.isArray(response.results) &&
      response.results.length <= 0
    ) {
      return Promise.reject({
        description: 'Location not found',
      })
    }

    const result = response.results[0]
    return {
      name: result.formatted_address,
      location: {
        placeId: result.place_id,
        coordinate: {
          latitude: region.latitude,
          longitude: region.longitude,
        },
      },
    }
  })

export const placeDetailFromId = placeId =>
  rideNetworkRequest({
    baseUrl: 'https://gw.tokopedia.com',
    path: '/maps/places/place-details',
    params: {
      placeid: placeId,
    },
  })
    .then(response => response.data)
    .then(place => ({
      name: place.name,
      location: {
        placeId: place.place_id,
        coordinate: {
          latitude: place.geometry.location.lat,
          longitude: place.geometry.location.lng,
        },
      },
    }))

export const getAutocomplete = query =>
  rideNetworkRequest({
    baseUrl: 'https://gw.tokopedia.com',
    path: '/maps/places/autocomplete',
    params: {
      input: query,
    },
  })
    .then(response => {
      if (response.message_error) {
        return Promise.reject({
          description: response.message_error,
        })
      }
      return response
    })
    .then(response => response.data)
    .then(response => response.predictions)
    .then(predictions =>
      predictions.map(prediction => ({
        name: prediction.structured_formatting.main_text,
        detailedName: prediction.structured_formatting.secondary_text,
        location: {
          placeId: prediction.place_id,
        },
      })),
    )

export const directionParam = place => {
  if (place.location.placeId) {
    return `place_id:${place.location.placeId}`
  }

  return `${place.location.coordinate.latitude},${place.location.coordinate
    .longitude}`
}

export const bookRide = ({
  productId,
  productName,
  promoCode,
  fareId,
  pickupPoint,
  dropOffPoint,
  tosConfirmation,
  startAddressName,
  endAddressName,
  startAddress,
  endAddress,
  deviceType,
}) =>
  rideNetworkRequest({
    baseUrl: serverUrl,
    method: 'POST',
    path: '/uber/request',
    authorizationMode: 'token',
    params: {
      alat: pickupPoint.latitude, // TODO: use gps
      along: pickupPoint.longitude,
      start_latitude: pickupPoint.latitude,
      start_longitude: pickupPoint.longitude,
      end_latitude: dropOffPoint.latitude,
      end_longitude: dropOffPoint.longitude,
      fare_id: fareId,
      product_id: productId,
      product_name: productName,
      ...promoCode,
      ...tosConfirmation,
      ...startAddressName,
      ...endAddressName,
      ...startAddress,
      ...endAddress,
      ...deviceType,
    },
  })

export const getProductDetail = productId =>
  rideNetworkRequest({
    baseUrl: serverUrl,
    path: '/uber/product/detail',
    params: {
      product_id: productId,
    },
  }).then(response => response.data)

export const getRoute = (source, destination) =>
  googleNetworkRequest({
    baseUrl: 'https://maps.googleapis.com',
    path: '/maps/api/directions/json',
    params: {
      origin: directionParam(source),
      destination: directionParam(destination),
      key: googleapisKey,
    },
  })
    .then(result => result.routes[0])
    .then(route => {
      if (!route) {
        return null
      }

      const encodedPoints = route.overview_polyline.points
      const decodedPoints = polyline.decode(encodedPoints)
      const coordinates = decodedPoints.map(point => ({
        latitude: point[0],
        longitude: point[1],
      }))

      const { bounds: { northeast, southwest } } = route

      const region = {
        latitude: (northeast.lat + southwest.lat) / 2,
        longitude: (northeast.lng + southwest.lng) / 2,
        latitudeDelta: Math.abs(northeast.lat - southwest.lat) * 2,
        longitudeDelta: Math.abs(northeast.lng - southwest.lng) * 2,
      }
      return { region, coordinates }
    })

export const getTripStatus = requestId =>
  rideNetworkRequest({
    baseUrl: serverUrl,
    method: 'GET',
    path: '/uber/request/details',
    authorizationMode: 'token',
    params: {
      request_id: requestId,
    },
  })
    .then(response => response.data)
    .then(data => ({
      status: data.status,
      driverLocation: data.location,
      pollWait: data.poll_wait,
      data,
    }))

// need special call request
// why? in this case, if response is not_found, it needs by pass result
export const getCurrentTrip = () =>
  request({
    baseUrl: serverUrl,
    method: 'GET',
    path: 'uber/request/current',
    authorizationMode: 'token',
  })
    .catch(extractErrorMessage)
    .then(
      result =>
        !result.data || result.data.code === 'not_found'
          ? { ...result, message_error: undefined }
          : result,
    )

export const cancelBooking = reason =>
  rideNetworkRequest({
    baseUrl: serverUrl,
    method: 'POST',
    path: '/uber/request/cancel',
    authorizationMode: 'token',
    params: {
      reason,
    },
  })

export const getRecentAddresses = () =>
  rideNetworkRequest({
    baseUrl: serverUrl,
    method: 'GET',
    path: 'user/address',
    authorizationMode: 'token',
  }).then(response => response.data)
