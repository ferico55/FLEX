import fpRaw from 'lodash/fp'
import { NativeModules } from 'react-native'
import { actions } from '../redux'
import mapDynamicFilterData from './mapDynamicFilterData'

const fp = fpRaw.convert({
  cap: false,
})

const asUrl = url => // eslint-disable-line
  `${url.baseUrl}${url.path}?${fp
    .map((value, key) => `${key}=${value}`, url.params)
    .join('&')}`

const { request } = NativeModules.ReactNetworkManager

export default uniqueIdAndSource => params => {
  const requestParams = {
    baseUrl: 'http://ace.tokopedia.com',
    method: 'GET',
    path: '/v2/dynamic_attributes',
    params,
  }
  const { source } = params
  // console.log(asUrl(requestParams))

  return actions.dynamicFilterData.load(
    request(requestParams)
      // .then(data => console.log(JSON.stringify(data)) || data)
      .then(mapDynamicFilterData)
      .then(data => {
        if (source === 'search_catalog') {
          const priceFilter = fp.find(
            ({ template_name }) => template_name === 'template_price',
            data.filter,
          )
          const categoryFilter = fp.find(
            ({ template_name }) => template_name === 'template_category',
            data.filter,
          )
          priceFilter.options = fp.filter(
            ({ originalKey }) => originalKey !== 'wholesale',
            priceFilter.options,
          )

          return {
            data: {
              ...data,
              filter: [categoryFilter, priceFilter],
            },
            uniqueIdAndSource,
          }
        }
        return { data, uniqueIdAndSource }
      }),
  )
}
