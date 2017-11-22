import { createAction } from 'redux-act'
import actionsGenerator from './actionsGenerator'

const actions = {
  dynamicFilterData: { load: createAction },
  purgeCache: createAction,
  temporaryValues: {
    set: createAction,
  },
  formReady: { set: createAction },
  price: {
    set: createAction,
  },
  uniqueIdAndSource: { set: createAction },
  optionsSearch: {
    set: createAction,
    clear: createAction,
  },
  connectionState: { set: createAction },
}
export default actionsGenerator(actions, '')
