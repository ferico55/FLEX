/* @flow */

import React, { PureComponent } from 'react'
import { View, StyleSheet, Linking } from 'react-native'
import HTMLView from 'react-native-htmlview'

const TOKOPEDIA_URL_PATTERN = /www.tokopedia.com/i

export default class MessageText extends PureComponent {
  constructor(props) {
    super(props)
    this.state = {
      highlightText: props.searchKeyword,
    }
  }

  onUrlPress = url => {
    if (this.props.onUrlPress) {
      if (TOKOPEDIA_URL_PATTERN.test(url)) {
        this.props.onUrlPress(url)
      } else {
        this.props.onUrlPress(`https://tkp.me/r?url=${url}`)
      }
    }
  }

  wrapWithHTML = html => `<div>${html}</div>`

  render() {
    return (
      <View style={[styles[this.props.position].container]}>
        <HTMLView
          stylesheet={HTMLStyles[this.props.position]}
          style={[styles[this.props.position].text]}
          value={this.wrapWithHTML(this.props.msg)}
          onLinkPress={this.onUrlPress}
        />
      </View>
    )
  }
}

const textStyle = {
  marginTop: 5,
  marginBottom: 5,
  marginLeft: 10,
  marginRight: 10,
}

const HTMLStyles = {
  left: StyleSheet.create({
    div: {
      color: 'rgba(0,0,0,0.7)',
    },
    span: {
      backgroundColor: 'rgb(255,193,7)',
      fontSize: 16,
      lineHeight: 20,
    },
    a: {
      textDecorationLine:'underline',
      fontWeight: '300',
    },
  }),
  right: StyleSheet.create({
    div: {
      color: 'rgb(255,255,255)',
    },
    span: {
      backgroundColor: 'rgb(255,193,7)',
      color: 'rgb(255,255,255)',
      fontSize: 16,
      lineHeight: 20,
    },
    a: {
      textDecorationLine:'underline',
      fontWeight: '300',
      color: 'rgb(255,255,255)',
    },
  }),
}

const styles = {
  left: StyleSheet.create({
    container: {},
    text: {
      // color: 'black',
      flexDirection: 'row',
      ...textStyle,
    },
    link: {
      color: 'black',
      textDecorationLine: 'underline',
    },
  }),
  right: StyleSheet.create({
    container: {},
    text: {
      // color: 'white',
      flexDirection: 'row',
      ...textStyle,
    },
    link: {
      color: 'white',
      textDecorationLine: 'underline',
    },
  }),
}
