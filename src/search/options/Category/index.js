// @flow
import React from 'react'
import fp from 'lodash/fp'
import Navigator from 'native-navigation'
import { View, StyleSheet, ScrollView } from 'react-native'
import { arrayPush, formValueSelector, arrayRemoveAll } from 'redux-form'
import { batchActions } from 'redux-batched-actions'
import { createStructuredSelector } from 'reselect'
import { dispatch, connect } from '../../redux'
import Thumbnail from './Thumbnail'
import ItemExpandable from './ItemExpandable'
import formName from '../../formName'
import NoConnectionBar from '../../NoConnectionBar'

const styles = StyleSheet.create({
  container: { flex: 1 },
  sideBySide: {
    flex: 1,
    flexDirection: 'row',
    alignItems: 'flex-start',
    justifyContent: 'flex-start',
    backgroundColor: 'white',
  },
  thumbnailOuter: {
    backgroundColor: '#e1e1e1',
    width: 95,
  },
  thumbnailInnder: {
    alignItems: 'flex-start',
  },
  items: {},
})
const handleOnSelect = ({ value, active }) => {
  if (!active) {
    dispatch(
      batchActions([
        arrayRemoveAll(formName, 'sc'),
        arrayPush(formName, 'sc', value),
      ]),
    )
  }
  Navigator.pop()
}
const formValueSelectorInstance = formValueSelector(formName)
const selector = createStructuredSelector({
  formValues: state => formValueSelectorInstance(state, 'sc') || [],
})

export default connect(selector)(
  class Category extends React.Component {
    constructor(props) {
      super(props)
      this.handleSelectTopLevelCategory = this.handleSelectTopLevelCategory.bind(
        this,
      )
      this.handleToggleSecondLevelCategory = this.handleToggleSecondLevelCategory.bind(
        this,
      )
      const { formValues, filter: { options } } = this.props

      const findInChild = cb => category =>
        fp.getOr([], 'child', category).find(cb)

      const findFormValuesInSecondLevelCategory = findInChild(({ value }) =>
        formValues.includes(value),
      )

      const findFormValuesInFirstOrSecondLevelCategory = category =>
        formValues.includes(category.value) ||
        findInChild(({ value }) => formValues.includes(value))(category)

      const openSubcategories = fp.flow([
        fp.map(fp.get('child')),
        fp.flatten,
        fp.filter(findFormValuesInSecondLevelCategory),
        fp.map(fp.get('value')),
      ])(options)

      const currentCategory = formValues.length
        ? fp.find(findInChild(findFormValuesInFirstOrSecondLevelCategory))(
            options,
          )
        : options[0]

      this.state = {
        currentCategory,
        openSubcategories,
      }
    }

    props: {
      connectionState: string,
      filter: { options: Array<Object> },
      formValues: Array<string>,
      navigatorInstance: Object,
      onLeftPress: Function,
      leftImage: Object,
    }
    handleSelectTopLevelCategory(value) {
      this.setState({
        currentCategory: this.props.filter.options.find(
          option => option.value === value,
        ),
      })
    }
    handleToggleSecondLevelCategory(value) {
      const { openSubcategories } = this.state

      if (openSubcategories.includes(value)) {
        this.setState({
          openSubcategories: openSubcategories.filter(val => value !== val),
        })
      } else {
        this.setState({
          openSubcategories: [...openSubcategories, value],
        })
      }
    }

    render() {
      const {
        state: { currentCategory, openSubcategories },
        props: {
          connectionState,
          filter: { options: firstLevelCategories, title },
          leftImage,
          onLeftPress,
          formValues,
        },
      } = this
      return (
        <View style={styles.container}>
          {connectionState === 'none' ? <NoConnectionBar /> : null}
          <View style={styles.sideBySide}>
            <Navigator.Config
              {...{
                title,
                leftImage,
                onLeftPress,
              }}
            />

            <View style={styles.thumbnailOuter}>
              <ScrollView
                contentContainerStyle={styles.thumbnailInnder}
                showsVerticalScrollIndicator={false}
              >
                {firstLevelCategories.map(category => {
                  const { icon, name, value } = category

                  if (!icon || !icon.length) {
                    return null
                  }
                  return (
                    <Thumbnail
                      key={value}
                      active={currentCategory === category}
                      value={value}
                      icon={icon}
                      name={name}
                      onSelect={this.handleSelectTopLevelCategory}
                    />
                  )
                })}
              </ScrollView>
            </View>

            <ScrollView contentContainerStyle={styles.items}>
              {currentCategory.child.map(category => (
                <ItemExpandable
                  formValues={formValues}
                  key={category.value}
                  open={openSubcategories.includes(category.value)}
                  category={category}
                  onToggle={this.handleToggleSecondLevelCategory}
                  onSelect={handleOnSelect}
                  openable
                />
              ))}
            </ScrollView>
          </View>
        </View>
      )
    }
  },
)
