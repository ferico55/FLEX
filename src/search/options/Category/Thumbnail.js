// @flow
import React from 'react'
import { Text, View, Image, StyleSheet, TouchableOpacity } from 'react-native'

const styles = StyleSheet.create({
  icon: {
    width: 40,
    height: 40,
  },
  container: {
    alignItems: 'center',
    justifyContent: 'center',
    backgroundColor: 'rgb(241,241,241)',
    width: 95,
    height: 88,
    borderColor: 'rgb(224,224,224)',
    borderBottomWidth: 1,
  },
  selected: {
    backgroundColor: 'white',
  },
  text: {
    paddingTop: 2,
    fontSize: 12,
    textAlign: 'center',
  },
})

export default class CategoryThumbnail extends React.Component {
  constructor(props) {
    super(props)
    this.handleOnPress = this.handleOnPress.bind(this)
  }
  props: {
    active: boolean,
    value: string,
    name: string,
    icon: string,
    onSelect: Function,
  }
  handleOnPress() {
    this.props.onSelect(this.props.value)
  }
  render() {
    const { active, name, icon } = this.props
    return (
      <TouchableOpacity onPress={this.handleOnPress}>
        <View style={[styles.container, active && styles.selected]}>
          <Image
            resizeMode="contain"
            source={{ uri: icon }}
            style={styles.icon}
          />
          <Text style={styles.text}>{name}</Text>
        </View>
      </TouchableOpacity>
    )
  }
}
