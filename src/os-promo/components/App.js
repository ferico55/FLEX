import React, { Component } from 'react'
import {
  View,
  ScrollView
} from 'react-native'
import { reloadState } from '../actions/index'
import { connect } from 'react-redux'
import BackToTop from './BackToTop'
import CategoryContainer from '../containers/CategoryContainer'


class App extends Component {
  render() {
    return (
      <CategoryContainer
        navigation={this.props.navigation}
        termsConditions={this.props.dataTermsConditions}
        slug={this.props.slug}
      />
    )
  }

  static navigationOptions = {
    header: null
  }
}


export default connect()(App)