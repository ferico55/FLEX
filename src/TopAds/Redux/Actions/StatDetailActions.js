import { ReactInteractionHelper } from 'NativeModules'
import { requestDashboardInfo } from '../../Helper/Requests'

export const changeStatDetailTab = index => ({
  type: 'CHANGE_STATDETAIL_TAB',
  index,
})

export const setInitialDataStatDetail = ({
  dataSource,
  selectedPresetDateRangeIndex,
  promoType,
  startDate,
  endDate,
}) => ({
  type: 'SET_INITIAL_DATA_STATDETAIL',
  payload: dataSource,
  selectedPresetDateRangeIndex,
  promoType,
  startDate,
  endDate,
})

export const getStatDetailStatistic = ({
  shopId,
  type,
  startDate,
  endDate,
}) => dispatch => {
  dispatch({
    type: 'GET_STATDETAIL_STATISTIC_LOADING',
  })
  requestDashboardInfo({ shopId, type, startDate, endDate })
    .then(result => {
      if (!result.data && result.errors && result.errors.length > 0) {
        ReactInteractionHelper.showErrorStickyAlert(result.errors[0].detail)
      }
      dispatch({
        type: 'GET_STATDETAIL_STATISTIC_SUCCESS',
        payload: result.data,
      })
    })
    .catch(error => {
      ReactInteractionHelper.showErrorStickyAlert(error.message)
      dispatch({
        type: 'GET_STATDETAIL_STATISTIC_FAILED',
        payload: error,
      })
    })
}
