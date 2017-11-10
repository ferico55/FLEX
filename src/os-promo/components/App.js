import React, { Component } from 'react'
import { connect } from 'react-redux'
import CategoryContainer from '../containers/CategoryContainer'

class App extends Component {
  static navigationOptions = {
    header: null,
  }

  render() {
    return (
      <CategoryContainer
        navigation={this.props.navigation}
        termsConditions={this.props.dataTermsConditions}
        slug={this.props.slug}
      />
    )
  }
}

export default connect()(App)
