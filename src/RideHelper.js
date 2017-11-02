import { TKPReactAnalytics } from 'NativeModules'

export const rupiahFormat = x => String(x).replace(/\B(?=(\d{3})+(?!\d))/g, '.')

export const currencyFormat = x => (x === 'IDR' || x === 'Rp' ? 'Rp' : x)

export const getCurrentLocation = () =>
  new Promise((resolve, reject) => {
    const options = {
      enableHighAccuracy: false,
      timeout: 3000,
      maximumAge: 250,
    }
    navigator.geolocation.getCurrentPosition(
      position =>
        resolve({
          latitude: position.coords.latitude,
          longitude: position.coords.longitude,
        }),
      reject,
      options,
    )
  })

export const getFollowLocation = () =>
  new Promise((resolve, reject) => {
    const options = {
      enableHighAccuracy: false,
      timeout: 3000,
      maximumAge: 250,
    }
    navigator.geolocation.watchPosition(
      position =>
        resolve({
          latitude: position.coords.latitude,
          longitude: position.coords.longitude,
        }),
      reject,
      options,
    )
  })

export const trackEvent = (name, action, label) => {
  // console.log('TRACKER!')
  // console.log(`${name} - digital uber - ${action} - ${label}`)
  TKPReactAnalytics.trackEvent({
    name: name || 'GenericUberEvent',
    category: 'digital - uber',
    action: action || '',
    label: label || '',
  })
}
