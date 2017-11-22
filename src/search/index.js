// @flow
import React from 'react'
import { View, NativeEventEmitter, NativeModules, NetInfo } from 'react-native'
import Navigator from 'native-navigation'
import { initialize } from 'redux-form'
import { batchActions } from 'redux-batched-actions'
import { createStructuredSelector } from 'reselect'
import './options'
import loadDynamicFilterData from './filters/downloadDynamicFilterData'
import provider from './HOC/provider'
import sharedStyles from './sharedStyles'
import WaitForFiltersReady from './WaitForFiltersReady'
import { dispatch, actions, getState, connect } from './redux'
import formName from './formName'
import initialValuesFromDynamicFilterData from './filters/initialValuesFromDynamicFilterData'
import NoConnectionBar from './NoConnectionBar'

const leftImage = {
  uri: 'icon_cancel_grey',
  scale: 1.5,
}
const emitter = new NativeEventEmitter(NativeModules.ReactDynamicFilterModule)
this.subscription = emitter.addListener('purgeCache', uniqueId => {
  dispatch(actions.purgeCache(uniqueId))
})

const handleOnRightPress = () => {
  const {
    uniqueIdAndSource,
    dynamicFilterData: dynamicFilterDataHash,
  } = getState()
  const initValues = initialValuesFromDynamicFilterData(
    dynamicFilterDataHash[uniqueIdAndSource],
  )
  const { pmin: min, pmax: max } = initValues
  dispatch(
    batchActions([
      actions.price.set({ min, max }),
      initialize(formName, initValues),
    ]),
  )
}
const handleOnLeftPress = () => {
  const { temporaryValues, uniqueIdAndSource } = getState()
  dispatch(initialize(formName, temporaryValues[uniqueIdAndSource]))
  dispatch(actions.formReady.set(false))
  Navigator.dismiss()
}
const onConnectionChage = type => {
  if (type === 'none') {
    dispatch(actions.connectionState.set(type))
    setTimeout(() => {
      dispatch(actions.connectionState.set(''))
    }, 3000)
  }
}
const selector = createStructuredSelector({
  connectionState: ({ connectionState }) => connectionState,
})
export default provider(
  connect(selector)(
    class MainScreen extends React.Component {
      componentDidMount() {
        const { source = '', uniqueId, searchParams } = this.props
        if (!uniqueId) {
          throw new Error('No uniqueId given')
        }
        NetInfo.addEventListener('connectionChange', onConnectionChage)
        const uniqueIdAndSource = `${uniqueId}$${source}`
        const state = getState()
        const temporaryValues = state.temporaryValues[uniqueIdAndSource]
        dispatch(actions.uniqueIdAndSource.set(uniqueIdAndSource))

        const restoreTemporaryValues = () => {
          const { pmin: min, pmax: max } = temporaryValues
          dispatch(
            batchActions([
              initialize(formName, temporaryValues),
              actions.price.set({ min, max }),
              actions.formReady.set(true),
            ]),
          )
        }

        const reinitState = ({ value: { data } }) => {
          const initialValues = initialValuesFromDynamicFilterData(data)
          const { pmin: min, pmax: max } = initialValues
          dispatch(
            batchActions([
              initialize(formName, initialValues),
              actions.price.set({ min, max }),
              actions.temporaryValues.set({
                data: initialValues,
                uniqueIdAndSource,
              }),
              actions.formReady.set(true),
            ]),
          )
        }

        if (temporaryValues) {
          restoreTemporaryValues()
        } else {
          dispatch(
            loadDynamicFilterData(uniqueIdAndSource)({
              ...searchParams,
              source, // source for /dynamic_attributes is different from /search
            }),
          ).then(reinitState, () => {
            dispatch(actions.formReady.set('error'))
          })
        }
      }

      componentWillUnmount() {
        NetInfo.removeEventListener('connectionChange', onConnectionChage)
      }

      props: {
        connectionState: string,
        uniqueId: string,
        nativeNavigationInstanceId: string,
        source: string,
        searchParams: Object,
        initialValues: Object,
      }

      render() {
        return (
          <View style={sharedStyles.flexContainer}>
            <Navigator.Config
              title="Filter"
              leftImage={leftImage}
              rightTitle="Reset"
              rightTitleColor="rgb(66,181,73)"
              onRightPress={handleOnRightPress}
              onLeftPress={handleOnLeftPress}
            />
            {this.props.connectionState === 'none' ? <NoConnectionBar /> : null}
            <WaitForFiltersReady
              nativeNavigationInstanceId={this.props.nativeNavigationInstanceId}
            />
          </View>
        )
      }
    },
  ),
)
