// @flow
import React from 'react'
import Navigator from 'native-navigation'
import {
  View,
  ScrollView,
  StyleSheet,
  NativeModules,
  Keyboard,
} from 'react-native'
import { getFormValues } from 'redux-form'
import formConnector from '../HOC/formConnector'
import FilterItems from './FilterItems'
import Apply from '../Apply'
import onSubmit from '../filters/onSubmit'
import { dispatch, getState, actions } from '../redux'
import { shouldComponentUpdateCreator } from '../performanceUtils'
import formName from '../formName'

const styles = StyleSheet.create({
  container: {
    backgroundColor: '#e1e1e1',
    flex: 1,
    flexDirection: 'column',
    justifyContent: 'space-between',
  },
})

export default formConnector(
  class Filters extends React.Component {
    constructor(props) {
      super(props)
      this.handleSubmit = this.handleSubmit.bind(this)
      this.enableScroll = this.enableScroll.bind(this)
      this.disableScroll = this.disableScroll.bind(this)
      this.setPriceRef = this.setPriceRef.bind(this)
      this.state = { scrollEnabled: true }
    }
    props: {
      nativeNavigationInstanceId: string,
      dynamicFilterData: { filter: Array<Object> },
    }
    shouldComponentUpdate = shouldComponentUpdateCreator('filters')

    enableScroll() {
      this.setState({ scrollEnabled: true })
    }
    disableScroll() {
      this.setState({ scrollEnabled: false })
    }
    handleSubmit() {
      const { nativeNavigationInstanceId } = this.props
      if (this.priceRef) {
        this.priceRef.prepareForUnmount()
      }
      const state = getState()
      const {
        dynamicFilterData: dynamicFilterDataHash,
        uniqueIdAndSource,
      } = state
      const { filter: filters } = dynamicFilterDataHash[uniqueIdAndSource]
      const form = getFormValues(formName)(state)
      // JSON stringify to avoid mutation of object on Native side
      // console.log('submit', JSON.stringify(onSubmit({ filters, form })))
      const result = JSON.parse(JSON.stringify(onSubmit({ filters, form })))
      NativeModules.ReactDynamicFilterModule.setFilters(
        result,
        nativeNavigationInstanceId,
      )
      dispatch(actions.temporaryValues.set({ data: form, uniqueIdAndSource }))
      dispatch(actions.formReady.set(false))
      Navigator.dismiss()
    }

    setPriceRef(el) {
      this.priceRef = el
    }
    render() {
      return (
        <View style={styles.container}>
          <ScrollView
            scrollEnabled={this.state.scrollEnabled}
            scrollEventThrottle={1000}
            onScroll={Keyboard.dismiss} // eslint-disable-line
          >
            <FilterItems
              priceRef={this.setPriceRef}
              enableScroll={this.enableScroll}
              disableScroll={this.disableScroll}
            />
          </ScrollView>
          <Apply onPress={this.handleSubmit} label="Terapkan" />
        </View>
      )
    }
  },
)
