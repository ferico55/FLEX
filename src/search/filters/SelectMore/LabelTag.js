// @flow
import React from 'react'
import { Text, Image, StyleSheet, View, TouchableOpacity } from 'react-native'
import { change, arrayRemove, formValueSelector } from 'redux-form'
import makeStarArray from '../../makeStarArray'
import { dispatch, getState } from '../../redux'
import formName from '../../formName'

const iconRemove = { uri: 'icon_cancel_grey' }
const styles = StyleSheet.create({
  container: {
    borderWidth: 1,
    borderRadius: 18,
    marginLeft: 10,
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'space-between',
    borderColor: '#e0e0e0',
  },
  iconRemoveContainer: {
    borderColor: '#e0e0e0',
    backgroundColor: '#f8f8f8',
    padding: 8,
    borderLeftWidth: 1,
    borderRadius: 18,
  },
  iconRemove: {
    width: 16,
    height: 16,
    padding: 5,
    tintColor: '#e0e0e0',
  },
  icon: {
    width: 16,
    height: 16,
    marginLeft: 5,
  },
  textContainer: {
    flexDirection: 'row',
    alignItems: 'center',
    paddingLeft: 10,
    paddingRight: 10,
  },
  text: { color: 'grey', fontSize: 14 },
  ratingStar: {
    width: 16,
    height: 16,
  },
})

const starArray = makeStarArray(styles.ratingStar)

export default class LabelTag extends React.Component {
  constructor(props) {
    super(props)
    this.handleOnPress = this.handleOnPress.bind(this)
  }
  props: {
    value: string,
    formKey: string,
    icon: string,
    name: string,
    metric: string,
    input_type: string,
    template_name: string,
  }
  handleOnPress() {
    const { formKey, value } = this.props
    if (formKey === 'sc') {
      dispatch(
        arrayRemove(
          formName,
          'sc',
          formValueSelector(formName)(getState(), 'sc').indexOf(value),
        ),
      )
    } else {
      dispatch(change(formName, this.props.formKey, false))
    }
  }
  render() {
    const { name, template_name } = this.props

    return (
      <View style={styles.container}>
        <View style={styles.textContainer}>
          {template_name === 'template_rating' ? (
            starArray[parseInt(name, 10)]
          ) : (
            <Text style={styles.text}>{name}</Text>
          )}
        </View>
        <TouchableOpacity onPress={this.handleOnPress}>
          <View style={styles.iconRemoveContainer}>
            <Image source={iconRemove} style={styles.iconRemove} />
          </View>
        </TouchableOpacity>
      </View>
    )
  }
}
