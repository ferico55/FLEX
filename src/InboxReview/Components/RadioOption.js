import React, { Component } from 'react'
import {
  StyleSheet,
  Text,
  View,
  TouchableOpacity,
  FlatList,
  TextInput,
} from 'react-native'
import PropTypes from 'prop-types'

const styles = StyleSheet.create({
  optionContainer: {
    paddingHorizontal: 7,
    flexDirection: 'row',
    alignItems: 'flex-start',
  },
  radioContainer: {
    width: 18,
    height: 18,
    borderWidth: 1,
    borderColor: 'rgba(0,0,0,0.54)',
    borderRadius: 18,
    marginTop: 3,
    justifyContent: 'center',
    alignItems: 'center',
  },
  bullet: {
    width: 12,
    height: 12,
    backgroundColor: 'rgb(66,181,73)',
    borderRadius: 18,
  },
  optionText: {
    color: 'rgba(0,0,0,0.54)',
    fontSize: 15,
    lineHeight: 21,
  },
  otherInput: {
    marginTop: 8,
    flex: 1,
    paddingBottom: 1,
    borderBottomWidth: 1,
    borderColor: 'rgba(0,0,0,0.54)',
    backgroundColor: 'white',
    fontSize: 15,
    lineHeight: 21,
  },
})

class RadioOption extends Component {
  constructor(props) {
    super(props)
    this.state = {
      dataSource: this.props.options,
      selectedIndex: this.props.selectedIndex,
      otherIndex: this.props.otherIndex,
      other: '',
      shouldEnableSubmit: false,
    }
  }

  listSeparator = () => <View style={{ marginTop: 20 }} />

  selectedIndex = () => this.state.selectedIndex

  selectedOption = () => this.state.selectedIndex + 1

  otherText = () => this.state.other

  verifyInput = () => {
    if (
      this.state.selectedIndex >= 0 &&
      this.state.selectedIndex < this.state.dataSource.length
    ) {
      if (this.state.selectedIndex === this.state.otherIndex) {
        if (this.state.other === '') {
          this.props.validationChanged(false)
          return
        }
      }
      this.props.validationChanged(true)
      return
    }
    this.props.validationChanged(false)
  }

  renderItem = item => (
    <TouchableOpacity
      onPress={() => {
        this.setState({ selectedIndex: item.index }, () => {
          this.verifyInput()
          if (item.index !== this.props.otherIndex) {
            this.textInput.setNativeProps({ text: '' })
          }
        })
      }}
    >
      <View style={styles.optionContainer}>
        <View
          style={[
            styles.radioContainer,
            {
              borderColor:
                item.index === this.state.selectedIndex
                  ? 'rgb(66,181,73)'
                  : 'rgba(0,0,0,0.54)',
            },
          ]}
        >
          {item.index === this.state.selectedIndex && (
            <View style={styles.bullet} />
          )}
        </View>
        <View style={{ marginLeft: 13, flex: 1 }}>
          <Text style={styles.optionText}>{item.item}</Text>
          {item.index === this.state.otherIndex && (
            <TextInput
              ref={input => {
                this.textInput = input
              }}
              onChangeText={value => {
                this.setState({ other: value === '' ? '' : value }, () => {
                  this.verifyInput()
                })
              }}
              onFocus={() => {
                if (this.state.selectedIndex !== this.props.otherIndex) {
                  this.setState({ selectedIndex: this.props.otherIndex })
                }
              }}
              style={styles.otherInput}
              placeholder="Isi alasan disini"
              multiline
            />
          )}
        </View>
      </View>
    </TouchableOpacity>
  )

  render() {
    return (
      <View style={this.props.style}>
        <FlatList
          ref={flatList => {
            this.flatList = flatList
          }}
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

RadioOption.propTypes = {
  style: PropTypes.object,
  validationChanged: PropTypes.func,
  options: PropTypes.arrayOf(PropTypes.string).isRequired,
  selectedIndex: PropTypes.number,
  otherIndex: PropTypes.number,
}

RadioOption.defaultProps = {
  style: {},
  validationChanged: null,
  selectedIndex: 0,
  otherIndex: 0,
}

export default RadioOption
