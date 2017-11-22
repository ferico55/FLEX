import { reducer as formReducer } from 'redux-form'
import fp from 'lodash/fp'
import reducerGenerator, { Reducer } from './reducerGenerator'
import actions from './actions'

const setPayload = (state, payload) => payload
const removeKeyFromState = (state, uniqueId) =>
  fp.pickBy((_, key) => !key.includes(uniqueId))(state)
const setDataToUniqueIdKey = (state, { data, uniqueIdAndSource }) => ({
  ...state,
  [uniqueIdAndSource]: data,
})
export default reducerGenerator({
  form: formReducer,
  dynamicFilterData: new Reducer({
    [actions.purgeCache.getType()]: removeKeyFromState,
    [`${actions.dynamicFilterData.load.getType()}_FULFILLED`]: setDataToUniqueIdKey,
  }),
  price: {
    min: new Reducer({
      [actions.price.set.getType()]: (state, { min }) =>
        typeof min === 'number' ? min : state,
    }),
    max: new Reducer({
      [actions.price.set.getType()]: (state, { max }) =>
        typeof max === 'number' ? max : state,
    }),
  },
  uniqueIdAndSource: new Reducer({
    [actions.uniqueIdAndSource.set.getType()]: setPayload,
  }),
  optionsSearch: new Reducer({
    [actions.optionsSearch.set.getType()]: setPayload,
    [actions.optionsSearch.clear.getType()]: () => '',
  }),
  formReady: new Reducer({
    [actions.formReady.set.getType()]: setPayload,
  }),
  temporaryValues: new Reducer({
    [actions.purgeCache.getType()]: removeKeyFromState,
    [actions.temporaryValues.set.getType()]: setDataToUniqueIdKey,
  }),
  connectionState: new Reducer({
    [actions.connectionState.set.getType()]: setPayload,
  }),
})
