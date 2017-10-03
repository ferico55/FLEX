export const changeTempFilterGroup = ({ tempGroup, key }) => ({
  type: 'CHANGE_FILTER_PROMOLIST_TEMP_GROUP',
  tempFilter: {
    group: tempGroup,
  },
  key,
})

export const changeTempFilterStatus = ({ tempStatus, key }) => ({
  type: 'CHANGE_FILTER_PROMOLIST_TEMP_STATUS',
  tempFilter: {
    status: tempStatus,
  },
  key,
})

export const changePromoListFilter = ({ key }) => ({
  type: 'CHANGE_FILTER_PROMOLIST',
  key,
})

export const resetFilter = key => ({
  type: 'RESET_FILTER',
  key,
})
