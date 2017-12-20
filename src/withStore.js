import React from 'react'
import { Provider } from 'react-redux'

const withStore = store => Screen => props => (
  <Provider store={store}>
    <Screen {...props} />
  </Provider>
)

export default withStore
