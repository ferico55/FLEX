import React, { Component } from 'react'
import { Text, View, StyleSheet } from 'react-native'
import MessageComposer from '@SendChatComponents/SendChatMessageComposer'

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: 'rgb(248, 248, 248)',
  },
})

export default class SendChatView extends Component {
  render() {
    console.log(this.props)
    return (
      <View style={styles.container}>
        <MessageComposer data={this.props.data} />
      </View>
    )
  }
}
