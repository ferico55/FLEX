import React, { Component } from 'react'
import { Provider } from 'react-redux'
import store from './store/Store'
import App from './components/App'

class Root extends Component {
  render() {
    return (
      <Provider store={store}>
        <App slug={this.props.navigation.state.params.slug} />
      </Provider>
    )
  }
}

module.exports = Root
