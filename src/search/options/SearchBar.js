// @flow
import React from 'react'
import {
  View,
  TextInput,
  StyleSheet,
  Image,
  TouchableOpacity,
} from 'react-native'

const styles = StyleSheet.create({
  textInputContainer: {
    backgroundColor: 'rgb(224, 224, 224)',
    padding: 15,
    paddingRight: 12,
    paddingLeft: 12,
  },
  textInputContainerInner: {
    flexDirection: 'row',
    justifyContent: 'center',
    alignItems: 'center',
    backgroundColor: 'white',
    borderRadius: 3,
  },
  textInput: {
    flex: 1,
    padding: 8,
    borderRadius: 3,
  },
  searchIcon: {
    marginLeft: 10,
    backgroundColor: 'white',
    paddingRight: 20,
    width: 20,
    height: 20,
  },
  clearIcon: {
    marginRight: 10,
    backgroundColor: 'white',
    width: 15,
    height: 15,
  },
})

const iconSearch = { uri: 'icon_search' }
const iconClear = { uri: 'icon_delete' }

export default ({
  onChange,
  onClear,
  search,
  placeholder,
}: {
  onChange: Function,
  onClear: Function,
  search: string,
  placeholder: string,
}) => (
  <View style={styles.textInputContainer}>
    <View style={styles.textInputContainerInner}>
      <Image source={iconSearch} style={styles.searchIcon} />
      <TextInput
        style={styles.textInput}
        onChangeText={onChange}
        value={search}
        autoCapitalize={'none'}
        autoCorrect={false}
        placeholder={placeholder}
      />
      {search.length ? (
        <TouchableOpacity onPress={onClear}>
          <Image source={iconClear} style={styles.clearIcon} />
        </TouchableOpacity>
      ) : null}
    </View>
  </View>
)
