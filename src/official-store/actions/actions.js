import axios from 'axios'
import find from 'lodash/find'
import { 
  ReactNetworkManager,
  TKPReactURLManager,
  ReactUserManager
} from 'NativeModules';
import DeviceInfo from 'react-native-device-info';

const MOJITO_HOSTNAME = 'https://mojito.tokopedia.com'
const TOME_HOSTNAME = 'https://tome.tokopedia.com'

const endpoints = {
  campaign: `${MOJITO_HOSTNAME}/os/api/v1/brands/microsite/campaigns?device=:device&full_domain=:domain&image_size=:imageSize&image_square=:imageSquare`,
  banners: `${MOJITO_HOSTNAME}/os/api/v1/brands/microsite/banners?device=2`,
  checkWishlist: `${MOJITO_HOSTNAME}/v1/users/:id/wishlist/check/:list_id`,
}

const checkProductInWishlist = (userId, pIds) => {
  if (userId == 0) {
    return Promise.resolve({
      data: {
        data: {
          ids: []
        }
      }
    })
  }

  const url = endpoints.checkWishlist
    .replace(':id', userId)
    .replace(':list_id', pIds)

  const headers = {
    'X-Device': 'lite-0.0'
  }

  const config = {
    headers: headers,
    url: url,
    method: 'GET'
  }

  return axios(config)
}

export const FETCH_CAMPAIGNS = 'FETCH_CAMPAIGNS'
export const fetchCampaigns = () => {
  const device = 'lite'
  const imageSize = 200
  const imageSquare = true
  const domain = 'm.tokopedia.com'

  const url = endpoints.campaign.replace(':device', device)
    .replace(':domain', domain)
    .replace(':imageSize', imageSize)
    .replace(':imageSquare', imageSquare)

  const getBanners = () => {
    const url = endpoints.banners
    return axios.get(url)
  }

  const getCampaigns = () => {
    return axios.get(url)
      .then(response => {
        let campaigns = response.data.data.campaigns || []
        return getBanners()
          .then(res => {
            const banners = res.data.data.banners
            const promoBanner = find(banners, { html_id: 6 })
            if (promoBanner) {
              promoBanner.Products = []
              campaigns.splice(2, 0, promoBanner)
            }
            const pIds = []
            campaigns.forEach(c => {
              const products = c.Products
              products.forEach(product => {
                pIds.push(product.data.id)
              })
            })

            let wishlistProd = []

            return ReactUserManager.getUserId().then(userId => {
              return checkProductInWishlist(userId, pIds.toString())
            }).then(res => {
                wishlistProd = res.data.data.ids.map(id => +id)
                return {
                  data: campaigns.map(c => {
                    return {
                      ...c,
                      Products: c.Products.map(p => {
                        const is_wishlist = wishlistProd.indexOf(p.data.id) > -1 ? true : false
                        return {
                          ...p,
                          data: {
                            ...p.data,
                            is_wishlist,
                          }
                        }
                      })
                    }
                  })
                }
              })
              .catch(err => {
                return {
                  data: campaigns.map(c => {
                    return {
                      ...c,
                      Products: c.Products.map(p => {
                        const is_wishlist = wishlistProd.indexOf(p.data.id) > -1 ? true : false
                        return {
                          ...p,
                          data: {
                            ...p.data,
                            is_wishlist,
                          }
                        }
                      })
                    }
                  })
                }
              })
          })
          .catch(err => {
            return {
              data: campaigns
            }
          })
      })
      .catch(error => {
        return {
          data: []
        }
      })
  }

  return {
    type: FETCH_CAMPAIGNS,
    payload: getCampaigns()
  }
}

export const FETCH_BANNERS = 'FETCH_BANNERS'
export const fetchBanners = () => ({
  type: FETCH_BANNERS,
  payload: axios.get(endpoints.banners)
    .then(response => {
      const banners = response.data.data.banners || []
      return {
        data: banners
      }
    })
    .catch(err => {
      return {
        data: []
      }
    })
})

export const REFRESH_STATE = 'REFRESH_STATE'
export const refreshState = () => ({
  type: REFRESH_STATE
})

function getBrands(limit, offset) {
  
  return ReactUserManager.getUserId().then(userId => {
    return axios.get(`${MOJITO_HOSTNAME}/os/api/v1/brands/list?device=lite&microsite=true&user_id=${userId}&limit=${limit}&offset=${offset}`)
    .then(response => {
      const brands = response.data.data
      const total_brands = response.data.total_brands
      let shopList = brands.map(shop => ({
        id: shop.shop_id,
        name: shop.shop_name,
        brand_img_url: shop.brand_img_url,
        logo_url: shop.logo_url,
        microsite_url: shop.microsite_url,
        shop_mobile_url: shop.shop_mobile_url,
        shop_domain: shop.shop_domain,
        shop_apps_url: shop.shop_apps_url,
        isFav: false,
      }))
      let shopIds = brands.map(shop => shop.shop_id)
      shopIds = shopIds.toString()
      const shopCount = shopIds.length
      const bannerRows = DeviceInfo.isTablet() ? 8 : 4
      const url = `${MOJITO_HOSTNAME}/os/api/v1/brands/microsite/products?device=lite&source=osmicrosite&rows=${bannerRows}&full_domain=tokopedia.lite:3000&ob=11&image_size=200&image_square=true&brandCount=${shopCount}&brands=${shopIds}`
      

      let ids = []
      let wishlistProd = []
      return axios.get(`${url}`)
        .then(response => response.data.data.brands)
        .then(brandsProducts => {
          shopList = shopList.map(shop => {
            const shopProduct = find(brandsProducts, product => {
              return product.brand_id === shop.id
            })

            if (shopProduct && shopProduct.data) {
              shopProduct.data.map(product => {
                ids.push(product.id)
              })

              shop.products = shopProduct.data.map(product => ({
                id: product.id,
                name: product.name,
                price: product.price,
                image_url: product.image_url,
                is_wishlist: true,
                url: product.url,
                shop_name: product.shop.name,
                labels: product.labels,
                badges: product.badges,
                discount_percentage: product.discount_percentage,
                original_price: product.original_price,
                url_app: product.url_app
              }))
              
              return shop
            } else {
              shop.products = []
              return shop
            }
          })

          return checkProductInWishlist(userId, ids.toString())
          .then(res => {
            wishlistProd = res.data.data.ids.map(id => +id)
            
            return {
              data: shopList.map(s => {
                return {
                  ...s,
                  products : s.products.map(p => {
                    return {
                      ...p,
                      is_wishlist : wishlistProd.indexOf(p.id) > -1 ? true : false
                    }
                  })
                }
              }),
              total_brands,
            }
          })    

        })
    })
  })
}



export const FETCH_BRANDS = 'FETCH_BRANDS'
export const fetchBrands = (limit, offset) => ({
  type: FETCH_BRANDS,
  payload: getBrands(limit, offset)
})

export const RESET_BRANDS = 'RESET_BRANDS'
export const resetBrands = (limit, offset) => ({
  type: RESET_BRANDS,
  payload: getBrands(limit, offset)
})

export const SLIDE_BRANDS = 'SLIDE_BRANDS'
export const slideBrands = () => ({
  type: SLIDE_BRANDS
})

function getProductIdList(products) {
  const productIdList = []
  products.forEach((product) => {
    productIdList.push(product.data.map(p => p.id))
  })
  const pIds = []
  productIdList.forEach((p) => {
    p.forEach(o => {
      pIds.push(o)
    })
  })
  return pIds
}

export const ADD_TO_WISHLIST = 'ADD_TO_WISHLIST'
export const addToWishlist = (productId) => ({
  type: ADD_TO_WISHLIST,
  payload: ReactUserManager.getUserId()
    .then(userId => {
        if(userId == '0') {
          return
        }

        return ReactNetworkManager.request({
          method: 'POST',
          baseUrl: TKPReactURLManager.mojitoUrl,
          path: '/users/'+ userId +'/wishlist/'+ productId +'/v1.1',
          params: {},
          headers: {'X-User-ID' : userId},
        })
    .then(response => {
      return productId
    })
  }) 
})

export const ADD_WISHLIST_FROM_PDP = 'ADD_WISHLIST_FROM_PDP'
export const addWishlistPdp = (productId) => ({
  type: ADD_WISHLIST_FROM_PDP,
  payload: productId
})

export const REMOVE_WISHLIST_FROM_PDP = 'REMOVE_WISHLIST_FROM_PDP'
export const removeWishlistPdp = (productId) => ({
  type: REMOVE_WISHLIST_FROM_PDP,
  payload: productId
})

export const REMOVE_FROM_WISHLIST = 'REMOVE_FROM_WISHLIST'
export const removeFromWishlist = (productId) => ({
  type: REMOVE_FROM_WISHLIST,
  payload: ReactUserManager.getUserId()
    .then(userId => {
      if(userId == '0') {
        return
      }

      return ReactNetworkManager.request({
        method: 'DELETE',
        baseUrl: TKPReactURLManager.mojitoUrl,
        path: '/users/'+ userId +'/wishlist/'+ productId +'/v1.1',
        params: {},
        headers: {'X-User-ID' : ReactUserManager.userId},
      })
    .then(res => {
        return productId
      })
    })
  }) 

export const REMOVE_FROM_FAVOURITE = 'REMOVE_FROM_FAVOURITE'
export const removeFromFavourite = (shopId) => ({
  type: REMOVE_FROM_FAVOURITE,
  payload: ReactUserManager.getUserId()
  .then(userId => {
    if(userId == '0') {
      return
    }

    return ReactNetworkManager.request({
      method: 'POST',
      baseUrl: TKPReactURLManager.v4Url,
      path: '/v4/action/favorite-shop/fav_shop.pl',
      params: {'shop_id' : shopId}
    }).then(res => {
      return shopId
    })

  }),
})

export const ADD_TO_FAVOURITE = 'ADD_TO_FAVOURITE'
export const addToFavourite = (shopId) => ({
  type: ADD_TO_FAVOURITE,
  payload: ReactUserManager.getUserId()
  .then(userId => {
    if(userId == '0') {
      return
    }
    
    return ReactNetworkManager.request({
      method: 'POST',
      baseUrl: TKPReactURLManager.v4Url,
      path: '/v4/action/favorite-shop/fav_shop.pl',
      params: {'shop_id' : shopId}
    }).then(res => {
      return shopId
    })

  }),
})





