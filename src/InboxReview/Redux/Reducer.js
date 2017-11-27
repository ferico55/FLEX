import { combineReducers } from 'redux'

const inboxReviewState = {
  errorStatus: [false, false, false],
  params: [{}, {}, {}],
  loadingStatus: [false, false, false],
  reviewLists: [[], [], []],
  notificationCount: [0, 0, 0],
  isInteractionBlocked: false,
  isOnboardingScrollEnabled: true,
}

export function inboxReviewReducer(state = inboxReviewState, action) {
  switch (action.type) {
    case 'SET_PARAMS':
      return {
        ...state,
        errorStatus: [
          ...state.errorStatus.slice(0, action.pageIndex),
          false,
          ...state.errorStatus.slice(action.pageIndex + 1),
        ],
        params: [
          ...state.params.slice(0, action.pageIndex),
          action.params,
          ...state.params.slice(action.pageIndex + 1),
        ],
        reviewLists: [
          ...state.reviewLists.slice(0, action.pageIndex),
          [],
          ...state.reviewLists.slice(action.pageIndex + 1),
        ],
        loadingStatus: [
          ...state.loadingStatus.slice(0, action.pageIndex),
          true,
          ...state.loadingStatus.slice(action.pageIndex + 1),
        ],
      }
    case 'UPDATE_PARAMS':
      return {
        ...state,
        params: [
          ...state.params.slice(0, action.pageIndex),
          action.newParams,
          ...state.params.slice(action.pageIndex + 1),
        ],
        loadingStatus: [
          ...state.loadingStatus.slice(0, action.pageIndex),
          true,
          ...state.loadingStatus.slice(action.pageIndex + 1),
        ],
      }
    case 'SET_FILTER':
      return {
        ...state,
        params: [
          ...state.params.slice(0, action.pageIndex),
          action.newParams,
          ...state.params.slice(action.pageIndex + 1),
        ],
        reviewLists: [
          ...state.reviewLists.slice(0, action.pageIndex),
          [],
          ...state.reviewLists.slice(action.pageIndex + 1),
        ],
        loadingStatus: [
          ...state.loadingStatus.slice(0, action.pageIndex),
          true,
          ...state.loadingStatus.slice(action.pageIndex + 1),
        ],
      }
    case 'GET_REVIEW_LIST_LOADING':
      return {
        ...state,
        errorStatus: [
          ...state.errorStatus.slice(0, action.pageIndex),
          false,
          ...state.errorStatus.slice(action.pageIndex + 1),
        ],
        loadingStatus: [
          ...state.loadingStatus.slice(0, action.pageIndex),
          true,
          ...state.loadingStatus.slice(action.pageIndex + 1),
        ],
      }
    case 'GET_REVIEW_LIST_SUCCESS':
      return {
        ...state,
        loadingStatus: [
          ...state.loadingStatus.slice(0, action.pageIndex),
          false,
          ...state.loadingStatus.slice(action.pageIndex + 1),
        ],
        reviewLists: [
          ...state.reviewLists.slice(0, action.pageIndex),
          state.reviewLists[action.pageIndex].concat(action.payload),
          ...state.reviewLists.slice(action.pageIndex + 1),
        ],
        params: [
          ...state.params.slice(0, action.pageIndex),
          {
            ...state.params[action.pageIndex],
            page: action.hasNext ? state.params[action.pageIndex].page : -1,
          },
          ...state.params.slice(action.pageIndex + 1),
        ],
      }
    case 'GET_REVIEW_LIST_FAILED':
      return {
        ...state,
        errorStatus: [
          ...state.errorStatus.slice(0, action.pageIndex),
          true,
          ...state.errorStatus.slice(action.pageIndex + 1),
        ],
        loadingStatus: [
          ...state.loadingStatus.slice(0, action.pageIndex),
          false,
          ...state.loadingStatus.slice(action.pageIndex + 1),
        ],
      }
    case 'SET_LAST_PAGE':
      return {
        ...state,
        loadingStatus: [
          ...state.loadingStatus.slice(0, action.pageIndex),
          false,
          ...state.loadingStatus.slice(action.pageIndex + 1),
        ],
        params: [
          ...state.params.slice(0, action.pageIndex),
          {
            ...state.params[action.pageIndex],
            page: -1,
          },
          ...state.params.slice(action.pageIndex + 1),
        ],
      }
    case 'SET_INVOICE':
      return {
        ...state,
        item: action.item,
        invoicePageIndex: action.pageIndex,
      }
    case 'CHANGE_INVOICE_PAGE':
      return {
        ...state,
        invoicePageIndex: action.pageIndex,
      }
    case 'RESET_INVOICE':
      return {
        ...state,
        item: null,
        invoicePageIndex: 0,
      }
    case 'DISABLE_INTERACTION':
      return {
        ...state,
        isInteractionBlocked: true,
      }
    case 'ENABLE_INTERACTION':
      return {
        ...state,
        isInteractionBlocked: false,
      }
    case 'ENABLE_ONBOARDING_SCROLL':
      return {
        ...state,
        isOnboardingScrollEnabled: true,
      }
    case 'DISABLE_ONBOARDING_SCROLL':
      return {
        ...state,
        isOnboardingScrollEnabled: false,
      }
    default:
      return state
  }
}

const uploadImageState = {
  selectedImages: ['default'],
  imageDescriptions: ['', '', '', '', ''],
  previewImage: { uri: 'icon_image', index: -1, description: '' },
}

export function uploadImageReducer(state = uploadImageState, action) {
  let selector = []
  switch (action.type) {
    case 'ADD_IMAGE':
      if (state.selectedImages.length < 5) {
        selector = ['default']
      }
      return {
        ...state,
        selectedImages: [
          ...state.selectedImages.slice(0, state.selectedImages.length - 1),
          action.image,
          ...selector,
        ],
        previewImage: {
          uri: action.image.uri,
          index: state.selectedImages.length - 1,
        },
      }
    case 'ADD_UPLOADED_IMAGE':
      selector = []
      if (action.images.length < 5) {
        selector = ['default']
      }
      return {
        ...state,
        selectedImages: [...action.images, ...selector],
        imageDescriptions: [
          ...action.descriptions,
          ...state.imageDescriptions.slice(action.images.length),
        ],
      }
    case 'UPDATE_PREVIEW_IMAGE':
      return {
        ...state,
        imageDescriptions: [
          ...state.imageDescriptions.slice(0, state.previewImage.index),
          state.previewImage.description,
          ...state.imageDescriptions.slice(state.previewImage.index + 1),
        ],
        previewImage: {
          uri: action.uri,
          index: action.index,
          description: state.imageDescriptions[action.index],
        },
      }
    case 'REMOVE_CURRENT_IMAGE':
      let nextPreviewIndex = state.previewImage.index - 1
      // -2 considering default image
      if (nextPreviewIndex < 0 && state.selectedImages.length - 2 > 0) {
        // 1 because it get the un-updated state
        nextPreviewIndex = 1
      }
      selector = []
      let descs = []
      if (
        state.selectedImages.length === 5 &&
        state.selectedImages[4] !== 'default'
      ) {
        selector = ['default']
        descs = ['']
      }

      return {
        ...state,
        selectedImages: [
          ...state.selectedImages.slice(
            0,
            state.previewImage.index < 0 ? 0 : state.previewImage.index,
          ),
          ...state.selectedImages.slice(
            (state.previewImage.index < 0 ? 0 : state.previewImage.index) + 1,
          ),
          ...selector,
        ],
        imageDescriptions: [
          ...state.imageDescriptions.slice(
            0,
            state.previewImage.index < 0 ? 0 : state.previewImage.index,
            ...descs,
          ),
          ...state.imageDescriptions.slice(
            (state.previewImage.index < 0 ? 0 : state.previewImage.index) + 1,
          ),
          '',
        ],
        previewImage:
          nextPreviewIndex < 0
            ? { uri: 'icon_image', index: -1, description: '' }
            : {
                uri: state.selectedImages[nextPreviewIndex].uri,
                index: nextPreviewIndex - 1,
                description: state.imageDescriptions[nextPreviewIndex],
              },
      }
    case 'CHANGE_DESCRIPTION_TEXT':
      return {
        ...state,
        previewImage: {
          ...state.previewImage,
          description: action.description,
        },
        imageDescriptions: [
          ...state.imageDescriptions.slice(0, state.previewImage.index),
          action.description,
          ...state.imageDescriptions.slice(state.previewImage.index + 1),
        ],
      }
    case 'REMOVE_ALL_IMAGES':
      return uploadImageState
    default:
      return state
  }
}

export default combineReducers({
  inboxReviewReducer,
  uploadImageReducer,
})
