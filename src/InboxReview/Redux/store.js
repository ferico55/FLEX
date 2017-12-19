import thunk from 'redux-thunk'
import { applyMiddleware, createStore } from 'redux'

import inboxReviewReducer from './Reducer'

const middleware = applyMiddleware(thunk)
const inboxReviewStore = createStore(inboxReviewReducer, middleware)

export default inboxReviewStore
