// @flow

import React from 'react'
import { View, Text, TouchableOpacity, StyleSheet, Image } from 'react-native'

const styles = StyleSheet.create({
  iconCollapse: {
    width: 18,
    height: 18,
  },
  panel: {
    paddingRight: 17,
    height: 64,
    borderColor: 'rgb(224,224,224)',
    borderBottomWidth: 1,
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
  },
  level2: {
    paddingLeft: 18,
  },
  level3: {
    paddingLeft: 18 * 2,
  },
  active: {
    color: 'rgb(66,181,73)',
  },
  normal: {},
})

const iconDown = { uri: 'expand_arrow' }
const iconUp = { uri: 'collapse_arrow' }
const getIcon = (open, openable) => {
  if (!openable) {
    return null
  }
  return open ? (
    <Image source={iconUp} style={styles.iconCollapse} />
  ) : (
    <Image source={iconDown} style={styles.iconCollapse} />
  )
}
export default class extends React.Component {
  constructor(props) {
    super(props)
    this.handleOnPress = this.handleOnPress.bind(this)
  }
  props: {
    active: boolean,
    onToggle: Function,
    onSelect: Function,
    openable: boolean,
    open: boolean,
    category: { name: string, value: string },
    level: number,
  }
  handleOnPress() {
    const {
      onSelect,
      onToggle,
      category: { value },
      openable,
      active,
    } = this.props
    if (openable) {
      onToggle(this.props.category.value)
    } else {
      onSelect({ value, active })
    }
  }

  render() {
    const { open, openable, category: { name }, level, active } = this.props

    return (
      <TouchableOpacity onPress={this.handleOnPress}>
        <View style={[styles.panel, styles[`level${level}`]]}>
          <Text style={active ? styles.active : styles.normal}>{name}</Text>
          {getIcon(open, openable)}
        </View>
      </TouchableOpacity>
    )
  }
}
