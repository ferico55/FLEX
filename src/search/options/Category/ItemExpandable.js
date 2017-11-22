// @flow
import React from 'react'
import { View } from 'react-native'
import Item from './Item'

export default class CategoryItem extends React.Component {
  props: {
    onToggle: Function,
    onSelect: Function,
    formValues: Array<string>,
    category: { value: string, name: string },
    open: boolean,
  }
  render() {
    const {
      category,
      category: { child },
      open,
      onSelect,
      onToggle,
      formValues,
    } = this.props
    return (
      <View>
        {child ? (
          <Item
            category={category}
            onToggle={onToggle}
            openable
            open={open}
            level={2}
          />
        ) : (
          <Item
            active={formValues.includes(category.value)}
            category={category}
            onSelect={onSelect}
            level={2}
          />
        )}

        {child && open ? (
          child.map(item => (
            <Item
              active={formValues.includes(item.value)}
              key={item.value}
              category={item}
              onSelect={onSelect}
              level={3}
            />
          ))
        ) : null}
      </View>
    )
  }
}
