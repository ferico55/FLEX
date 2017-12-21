import React, { Component } from 'react'
import { Provider } from 'react-redux'
import store from './store/store'
import TopPick from './containers/TopPicksContainer'

// TODO: Get Page ID from props
const PAGE_ID = 1

export default class App extends Component {
  render() {
    return (
      <Provider store={store}>
        <TopPick pageId={PAGE_ID} />
      </Provider>
    )
  }
}