import React, { Component } from 'react'
import {
  StyleSheet,
  Text,
  View,
  TouchableOpacity,
  Image,
  FlatList,
} from 'react-native'

const styles = StyleSheet.create({
  wrapper: {
    backgroundColor: '#F1F1F1',
  },
  filterItem: {
    height: 56,
    backgroundColor: 'white',
    paddingLeft: 16,
    paddingRight: 8,
    paddingVertical: 18,
    borderBottomWidth: 1,
    borderColor: '#f1f1f1',
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
  },
  titleContainer: {
    height: 56,
    backgroundColor: 'white',
    paddingLeft: 16,
    paddingRight: 8,
    paddingVertical: 18,
    borderBottomWidth: 1,
    borderColor: '#f1f1f1',
  },
  title: {
    color: 'rgba(0,0,0,0.7)',
    fontWeight: '500',
    fontSize: 16,
  },
  option: {
    color: 'rgba(0,0,0,0.54)',
  },
  selectedOption: {
    color: 'rgb(66,181,73)',
  },
})

class FilterRadioGroup extends Component {
  constructor(props) {
    super(props)
    this.state = {
      dataSource: this.props.option,
      selectedIndex: this.props.selectedIndex,
    }
  }

  renderItem = item => (
    <TouchableOpacity
      onPress={() => {
        this.setState({ selectedIndex: item.index })
      }}
    >
      <View style={styles.filterItem}>
        <Text
          style={
            item.index === this.state.selectedIndex ? (
              styles.selectedOption
            ) : (
              styles.option
            )
          }
        >
          {item.item}
        </Text>
        {item.index === this.state.selectedIndex && (
          <Image
            source={{ uri: 'icon_checkmark_green' }}
            style={{ width: 14, height: 8 }}
          />
        )}
      </View>
    </TouchableOpacity>
  )

  selectedIndex = () => this.state.selectedIndex

  selectedOption = () => this.state.selectedIndex + 1

  render() {
    return (
      <View style={this.props.style}>
        <View style={styles.titleContainer}>
          <Text style={styles.title}>{this.props.title}</Text>
        </View>
        <FlatList
          ref={flatList => {
            this.flatList = flatList
          }}
          style={styles.wrapper}
          keyExtractor={(_, index) => index}
          ItemSeparatorComponent={this.listSeparator}
          data={this.state.dataSource}
          refreshing={false}
          extraData={this.state.selectedIndex}
          scrollEnabled={false}
          renderItem={this.renderItem}
        />
      </View>
    )
  }
}

export default FilterRadioGroup
