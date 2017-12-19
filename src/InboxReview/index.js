import React from 'react'
import { Provider } from 'react-redux'

import inboxReviewStore from './Redux/store'

import InboxReview from './Screen/InboxReview'
import ReviewFilterScreen from './Screen/ReviewFilterScreen'
import InvoiceDetailScreen from './Screen/InvoiceDetailScreen'
import ProductReviewFormScreen from './Screen/ProductReviewFormScreen'
import ImageUploadScreen from './Screen/ImageUploadScreen'
import ReportReviewScreen from './Screen/ReportReviewScreen'
import ImageDetailScreen from './Screen/ImageDetailScreen'
import ProductReviewScreen from './Screen/ProductReviewScreen'
import ShopReviewScreen from './Screen/ShopReviewScreen'

// TODO with store perlu di extract juga
const withStore = store => Screen => props => (
  <Provider store={store}>
    <Screen {...props} />
  </Provider>
)

const provided = withStore(inboxReviewStore)

export default {
  InboxReview: provided(InboxReview),
  ReviewFilterScreen: provided(ReviewFilterScreen),
  InvoiceDetailScreen: provided(InvoiceDetailScreen),
  ProductReviewFormScreen: provided(ProductReviewFormScreen),
  ImageUploadScreen: provided(ImageUploadScreen),
  ReportReviewScreen: provided(ReportReviewScreen),
  ImageDetailScreen: provided(ImageDetailScreen),
  ProductReviewScreen: provided(ProductReviewScreen),
  ShopReviewScreen: provided(ShopReviewScreen),
}
