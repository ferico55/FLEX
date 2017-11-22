import { compose, createStore, applyMiddleware } from 'redux'
import { enableBatching } from 'redux-batched-actions'
import promiseMiddleware from 'redux-promise-middleware'
// import actions from './actions'
// import logger from 'redux-logger'
// import fp from 'lodash/fp'
import rootReducer from './reducer'
import initialState from './initialState'

const middlewares = [promiseMiddleware()]
// if (__DEV__) {
//   middlewares.push(() => next => action => {
//     const result = next(action)
//
//     // if ([actions.temporaryValues.set.getType()].includes(action.type)) {
//     if (
//       ![
//         actions.price.set.getType(),
//         // '@@redux-form/CHANGE',
//         '@@redux-form/REGISTER_FIELD',
//         '@@redux-form/UNREGISTER_FIELD',
//       ].includes(action.type)
//     ) {
//       console.log('action', action)
//       console.log('newState', store.getState())
//     }
//     return result
//   })
// }
const store = createStore(
  enableBatching(rootReducer),
  initialState,
  compose(applyMiddleware.apply(this, middlewares)),
)

const { dispatch, getState } = store
export default store
export { getState, dispatch }
