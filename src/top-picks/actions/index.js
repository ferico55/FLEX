import axios from 'axios'
import { TKPReactURLManager } from 'NativeModules'

// TODO: Get api url based on env
const APP_URL = `${TKPReactURLManager.aceUrl}/hoth/discovery/api/page`

export const FETCH_TOP_PICKS = 'FETCH_TOP_PICKS'
export const fetchTopPicks = pageId => {
  const url = `${APP_URL}/${pageId}`
  return {
    type: FETCH_TOP_PICKS,
    payload: axios.get(url),
  }
}

export const RELOADSTATE = 'RELOADSTATE'
export const reloadState = () => ({
  type: RELOADSTATE,
})
