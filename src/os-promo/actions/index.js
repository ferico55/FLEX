import axios from 'axios'

const BASE_API_URL = {
    mojito: 'https://mojito.tokopedia.com/os/api/v1/ospromo'
}




// =================== Reload State =================== //
export const RELOADSTATE = 'RELOADSTATE'
export const reloadState = () => {
    return {
        type: RELOADSTATE
    }
}


// =================== Fetch Banner =================== //
export const FETCH_TOPBANNER = 'FETCH_TOPBANNER'
export const fetchTopBanner = (slug) => {
    return {
        type: FETCH_TOPBANNER,
        payload: fetchBanners(slug)
    }
}

fetchBanners = async (slug) => {
    const url = `${BASE_API_URL.mojito}/topcontent/${slug}?device=mobile`
    return axios.get(url)
        .then(res => {
            const objData = res.data
            return objData
        })
        .catch(err => { console.log(err) })
}

export const FETCH_CATEGORIES = 'FETCH_CATEGORIES'
export const fetchCategories = (slug, offset, limit) => {
  const url = `${BASE_API_URL.mojito}/categories?promo=${slug}&device=mobile&limit=${limit}&offset=${offset}`
  return {
    type: FETCH_CATEGORIES,
    payload: axios.get(url),
  }
}
