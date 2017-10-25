import moment from 'moment'

const addPromoState = {
  adId: '', // used on edit promo only
  productId: '', // used on edit promo only
  status: 1, // used on edit promo only
  stepCount: 3,
  groupType: 0, // 0 for new group, 1 for existing group, 2 for no group, 3 for shop
  newGroupName: '', // groupType = 0
  existingGroup: {
    group_id: '',
    group_name: '',
    total_item: 0,
  }, // groupType = 1
  isLoading: false,
  isFailedFetch: false,
  isLoadingPost: false,
  isFailedPost: false,
  isDonePost: false,
  isGroup: false, // used on edit promo only
  productKeyword: '',
  productEOF: false,
  productDataSource: [],
  tempSelectedProducts: [],
  selectedProducts: [],
  maxPrice: 0,
  maxPriceFMT: '', // used on edit promo only
  suggestionPrice: 0,
  budgetType: 0, // 0 for no budget, 1 for use budget
  budgetPerDay: 0, // budgetType = 1
  budgetPerDayFMT: '', // used on edit promo only
  scheduleType: 0, // 0 for no schedule, 1 for use schedule
  startDate: moment().add(30, 'minutes'), // scheduleType = 1
  endDate: moment()
    .add(30, 'minutes')
    .add(1, 'months'), // scheduleType = 1
  productFilter: {
    promotedStatus: 1,
    etalase: {
      menu_id: '',
      menu_name: '',
    },
  },
  tempProductFilter: {
    promotedStatus: 1,
    etalase: {
      menu_id: '',
      menu_name: '',
    },
  },
  currentStart: 0, // for handling bad paging logic from API :(
  isCallNextDataNeeded: false, // for handling bad paging logic from API :(
}

export default function addPromoReducer(state = addPromoState, action) {
  switch (action.type) {
    case 'CHANGE_GROUPTYPE_ADDPROMO':
      return {
        ...state,
        stepCount: action.stepCount,
        groupType: action.groupType,
      }
    case 'RESET_PROGRESS_ADDPROMO':
      return {
        ...addPromoState,
        ad: state.ad,
      }
    case 'SET_NEWGROUPNAME_ADDPROMO':
      return {
        ...state,
        newGroupName: action.name,
      }
    case 'SET_EXISTINGGROUP_ADDPROMO':
      return {
        ...state,
        existingGroup: action.group,
      }
    case 'CHANGE_FILTER_ADDPROMOPRODUCT_TEMP_PROMOTEDSTATUS':
      return {
        ...state,
        tempProductFilter: {
          promotedStatus: action.tempPromotedStatus,
          etalase: state.tempProductFilter.etalase,
        },
      }
    case 'CHANGE_FILTER_ADDPROMOPRODUCT_TEMP_ETALASE':
      return {
        ...state,
        tempProductFilter: {
          promotedStatus: state.tempProductFilter.promotedStatus,
          etalase: action.tempEtalase,
        },
      }
    case 'CHANGE_FILTER_ADDPROMOPRODUCT':
      return {
        ...state,
        productFilter: state.tempProductFilter,
      }
    case 'GET_PRODUCTDATASOURCE_ADDPROMO_LOADING':
      return {
        ...state,
        isLoading: true,
        isFailedFetch: false,
        isCallNextDataNeeded: false,
      }
    case 'GET_PRODUCTDATASOURCE_ADDPROMO_SUCCESS': {
      let tempProductDataSource = action.payload
      if (action.page > 0) {
        tempProductDataSource = state.productDataSource.concat(action.payload)
      }
      return {
        ...state,
        isLoading: false,
        productDataSource: tempProductDataSource,
        productEOF: action.eof,
        productKeyword: action.keyword,
        currentStart: action.page + 30,
        isCallNextDataNeeded: action.payload < 1 && !action.eof,
      }
    }
    case 'GET_PRODUCTDATASOURCE_ADDPROMO_FAILED':
      return {
        ...state,
        isLoading: false,
        isFailedFetch: true,
      }
    case 'SET_SELECTEDPRODUCTS_ADDPROMO':
      return {
        ...state,
        tempSelectedProducts: action.products,
        productDataSource: [].concat(state.productDataSource),
      }
    case 'SAVE_SELECTEDPRODUCTS_ADDPROMO':
      return {
        ...state,
        selectedProducts: state.tempSelectedProducts,
      }
    case 'GET_SUGGESTION_PRICE_LOADING':
      return {
        ...state,
        isLoading: true,
        isFailedFetch: false,
      }
    case 'GET_SUGGESTION_PRICE_SUCCESS': {
      return {
        ...state,
        isLoading: false,
        suggestionPrice: action.payload.median,
      }
    }
    case 'GET_SUGGESTION_PRICE_FAILED':
      return {
        ...state,
        isLoading: false,
        isFailedFetch: true,
      }
    case 'SET_MAXPRICE_ADDPROMO':
      return {
        ...state,
        maxPrice: action.price,
      }
    case 'CHANGE_BUDGETTYPE_ADDPROMO':
      return {
        ...state,
        budgetType: action.budgetType,
      }
    case 'SET_BUDGETPERDAY_ADDPROMO':
      return {
        ...state,
        budgetPerDay: action.budget,
      }
    case 'CHANGE_SCHEDULETYPE_ADDPROMO':
      return {
        ...state,
        scheduleType: action.scheduleType,
      }
    case 'SET_SCHEDULE_ADDPROMO':
      return {
        ...state,
        startDate: action.startDate,
        endDate: action.endDate,
      }
    case 'POST_ADDGROUP_ADDPROMO_LOADING':
      return {
        ...state,
        isLoadingPost: true,
        isFailedPost: false,
      }
    case 'POST_ADDGROUP_ADDPROMO_SUCCESS':
      return {
        ...state,
        isLoadingPost: false,
        isDonePost: !!action.payload,
        isFailedPost: !action.payload,
      }
    case 'POST_ADDGROUP_ADDPROMO_FAILED':
      return {
        ...state,
        isLoadingPost: false,
        isFailedPost: true,
      }
    case 'RESET_ADDGROUP_ADDPROMO_REQUESTSTATE':
      return {
        ...state,
        isDonePost: false,
        isLoadingPost: false,
        isFailedPost: false,
      }
    case 'EDIT_SETINITIAL_ADDPROMO':
      return {
        ...state,
        adId: action.adId,
        productId: action.productId,
        status: action.status,
        isGroup: action.isGroup,
        groupType: action.groupType,
        newGroupName: action.isGroup ? action.existingGroup.group_name : '',
        existingGroup: action.existingGroup,
        maxPrice: action.maxPrice,
        budgetType: action.budgetType,
        budgetPerDay: action.budgetPerDay,
        scheduleType: action.scheduleType,
        startDate: action.startDate,
        endDate: action.endDate,
      }
    case 'GET_PROMODETAIL_EDIT_LOADING':
      return {
        ...state,
        isLoading: true,
      }
    case 'GET_PROMODETAIL_EDIT_SUCCESS': {
      const tempScheduleType = action.isGroup
        ? action.payload.group_end_time ? 1 : 0
        : action.payload.ad_end_time ? 1 : 0

      const nowPlus30Minutes = moment().add(30, 'minutes')
      const nowPlus1months = moment()
        .add(30, 'minutes')
        .add(1, 'months')

      const tempStartDateMoment =
        tempScheduleType === 0
          ? nowPlus30Minutes
          : moment(action.startDateString, 'DD/MM/YYYY - HH:mm A')

      const tempEndDateMoment =
        action.endDateString === ''
          ? nowPlus1months
          : moment(action.endDateString, 'DD/MM/YYYY - HH:mm A')

      return {
        ...state,
        isLoading: false,
        existingGroup: {
          group_id: action.payload.group_id,
          group_name:
            action.payload.group_name || state.existingGroup.group_name,
          total_item: action.payload.group_total,
        },
        maxPrice: action.payload.price_bid,
        budgetType: action.payload.price_daily ? 1 : 0,
        budgetPerDay: action.payload.price_daily
          ? action.payload.price_daily
          : 0,
        scheduleType: tempScheduleType,
        startDate: tempStartDateMoment,
        endDate: tempEndDateMoment,
      }
    }
    case 'GET_PROMODETAIL_EDIT_FAILED':
      return {
        ...state,
        isLoading: false,
      }
    default:
      return state
  }
}
