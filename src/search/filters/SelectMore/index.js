// @flow
import React from 'react'
import { View, TouchableOpacity, Text, Image, StyleSheet } from 'react-native'
import Navigator from 'native-navigation'
import fp from 'lodash/fp'
import sharedStyles from '../../sharedStyles'
import LabelTagsCheckbox from './LabelTagsCheckbox'
import LabelTagsCategory from './LabelTagsCategory'

const styles = StyleSheet.create({
  panel: {
    marginBottom: 1,
    backgroundColor: 'white',
  },
  sideBySide: {
    paddingTop: 22,
    paddingLeft: 15,
    paddingRight: 15,
    paddingBottom: 22,
    flex: 1,
    alignItems: 'center',
    flexDirection: 'row',
    justifyContent: 'space-between',
  },
})

const iconForward = { uri: 'icon-forward' }
export default class extends React.Component {
  props: { filter: Object }

  handleOnPress = () => {
    const { filter } = this.props

    // JSON stringify to avoid mutation of object on Native side
    Navigator.push('ListOfOptions', {
      filter: JSON.parse(JSON.stringify(filter)),
    })
  }
  render() {
    const { filter, filter: { template_name } } = this.props
    if (!fp.getOr(0, 'options.length', filter)) {
      return null
    }
    return (
      <View style={styles.panel}>
        <TouchableOpacity onPress={this.handleOnPress}>
          <View style={styles.sideBySide}>
            <View>
              <Text style={sharedStyles.textLabel}>{filter.title}</Text>
            </View>
            <Image source={iconForward} style={sharedStyles.iconForward} />
          </View>
        </TouchableOpacity>
        {template_name === 'template_category' ? (
          <LabelTagsCategory filter={filter} />
        ) : (
          <LabelTagsCheckbox filter={filter} />
        )}
      </View>
    )
  }
}
