import React, { Component } from 'react'
import { Provider } from 'react-redux'
import store from './store/Store'
import App from './components/App'
import FlashSale from './components/FlashSale'

class Root extends Component {
  render() {
    if (this.props.navigation.state.params.slug === 'flash-sale') {
      return <FlashSale />
    } else {
      return (
        <Provider store={store}>
          <App slug={this.props.navigation.state.params.slug} />
        </Provider>
      )
    }
  }
}

module.exports = Root
