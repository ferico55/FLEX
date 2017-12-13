import thunk from 'redux-thunk'
import { applyMiddleware, createStore } from 'redux'

import topAdsDashboardReducer from './Reducers/GeneralReducer'

const middleware = applyMiddleware(thunk)
const topAdsDashboardStore = createStore(topAdsDashboardReducer, middleware)

export default topAdsDashboardStore
