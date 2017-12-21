import { Platform } from 'react-native'
import { some, find } from 'lodash'

const requiredParams = [
  {
    key: 'page',
    default: 1,
  },
  {
    key: 'start',
    default: 0,
  },
  {
    key: 'rows',
    default: 20,
  },
  {
    key: 'device',
    default: Platform.OS === 'ios' ? 'ios' : 'android',
  },
]

const getQueryParams = url => {
  if (!url) {
    return ''
  }
  const baseUrl = url.split('?')[0]
  const queryParamString = url.split('?')[1]
  const queryParamStringArray = queryParamString.split('&')
  const queryParamCollection = queryParamStringArray.map(qps => {
    const queryParamObj = {
      key: qps.split('=')[0],
      value: qps.split('=')[1],
    }

    return queryParamObj
  })

  return {
    queryParamCollection,
    baseUrl,
  }
}

const getUrl = (baseUrl, params) => {
  const queryStringColl = []
  params.forEach(p => {
    queryStringColl.push(`${p.key}=${p.value}`)
  })
  const str = queryStringColl.join('&')
  return `${baseUrl}?${str}`
}

const checkSanity = url => {
  let isValid = true

  const { queryParamCollection } = getQueryParams(url)

  for (let i = 0; i < requiredParams.length; i++) {
    const hasKey = some(
      queryParamCollection,
      qp => qp.key === requiredParams[i].key,
    )
    if (!hasKey) {
      isValid = false
      break
    }
  }

  const deviceObj = find(queryParamCollection, qp => qp.key === 'device')
  if (deviceObj) {
    if (deviceObj.value !== Platform.OS) {
      isValid = false
    }
  }

  return isValid
}

const sanitizeUrl = url => {
  const { queryParamCollection, baseUrl } = getQueryParams(url)
  for (let i = 0; i < requiredParams.length; i++) {
    const hasKey = some(
      queryParamCollection,
      qp => qp.key === requiredParams[i].key,
    )
    if (!hasKey) {
      queryParamCollection.push({
        key: requiredParams[i].key,
        value: requiredParams[i].default,
      })
    }
  }

  const deviceObj = find(queryParamCollection, qp => qp.key === 'device')
  if (deviceObj.value !== Platform.OS) {
    deviceObj.value = Platform.OS
  }

  return getUrl(baseUrl, queryParamCollection)
}

const Util = {
  getSanitizeUrl: url => {
    if (!url) {
      return url
    }

    const isValidUrl = checkSanity(url)
    if (!isValidUrl) {
      const sUrl = sanitizeUrl(url)
      return sUrl
    }

    return url
  },
}

export default Util
