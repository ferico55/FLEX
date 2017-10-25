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

export const changeTempFilterPromotedStatus = tempPromotedStatus => ({
  type: 'CHANGE_FILTER_ADDPROMOPRODUCT_TEMP_PROMOTEDSTATUS',
  tempPromotedStatus,
})

export const changeTempFilterEtalase = tempEtalase => ({
  type: 'CHANGE_FILTER_ADDPROMOPRODUCT_TEMP_ETALASE',
  tempEtalase,
})

export const changeAddPromoProductListFilter = () => ({
  type: 'CHANGE_FILTER_ADDPROMOPRODUCT',
})
