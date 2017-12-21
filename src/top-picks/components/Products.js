import React, { Component } from 'react'
import { View, StyleSheet, ActivityIndicator } from 'react-native'
import axios from 'axios'
import Product from './Product'
import Util from '../util/util'

const styles = StyleSheet.create({
  container: {
    flex: 1,
    flexDirection: 'row',
    flexWrap: 'wrap',
  },
})

class Products extends Component {
  constructor() {
    super()
    this.state = {
      data: [],
      isFetching: true,
    }
  }

  componentDidMount() {
    console.log('componentDidMount called')
    const urls = this.props.urls
    const validUrls = []
    urls.forEach(u => {
      if (u.url) {
        validUrls.push(Util.getSanitizeUrl(u.url))
      }
    })

    const promiseArray = validUrls.map(vUrl => axios.get(vUrl))
    Promise.all(promiseArray)
      .then(response => {
        const products = []
        response.forEach(r => {
          products.push(...r.data.data.products)
        })
        this.setState({
          data: products,
          isFetching: false,
        })
      })
      .catch(err => {
        console.log(err)
      })
  }

  render() {
    if (this.state.data.length) {
      return (
        <View style={styles.container}>
          {this.state.data.map(d => <Product product={d} key={d.id} />)}
        </View>
      )
    }

    return (
      <View style={{ backgroundColor: 'white', justifyContent: 'center' }}>
        <ActivityIndicator size="small" animating={this.state.isFetching} />
      </View>
    )
  }
}

export default Products
