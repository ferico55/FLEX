import get from 'lodash/get'
import { combineReducers } from 'redux'
import { createReducer } from 'redux-act'
import initialState from './initialState'

class Reducer {
  constructor(handlers) {
    this.handlers = handlers
  }
}

const reducerGenerator = (tree, pathArrray = []) => {
  if (tree instanceof Reducer) {
    const initState = get(initialState, pathArrray)
    if (initState === undefined) {
      throw new Error(
        `Initial state value for ${pathArrray.join('.')} is not defined`,
      )
    }
    switch (typeof tree) {
      case 'object':
        return createReducer(tree.handlers, initState)
      case 'function': {
        return createReducer(
          tree.handlers({ initState, path: pathArrray.join('.') }),
          initState,
        )
      }
      default:
        throw new Error(
          'Incorrect argument given to new Reducer, must be function or object',
        )
    }
  }
  switch (typeof tree) {
    case 'object': {
      const newTree = {}
      Object.keys(tree).forEach(key => {
        newTree[key] = reducerGenerator(tree && tree[key], [...pathArrray, key])
      })
      return combineReducers(newTree)
    }
    case 'function':
      return tree
    default:
      throw new Error('Incorrect argument given to reducerGenerator')
  }
}

export default reducerGenerator
export { Reducer }
