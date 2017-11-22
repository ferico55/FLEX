import React from 'react'
import { Provider } from 'react-redux'
import { store } from '../redux'

export default Component => props => (
  <Provider store={store}>
    <Component {...props} />
  </Provider>
)
