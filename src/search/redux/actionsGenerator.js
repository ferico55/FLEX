// in each tree leaf which is a function inject string with it's path.
// i.e. actionsGenerator({task:{toggle:handlerFunction}})
// handlerFunction will be invoked with 'task.toggle' as only argument
// and result of the invocation will replace original handlerFunction
// used to avoid mistypes in action declaration and for DRY
// see usage in `./actions.js`

const actionsGenerator = (tree, pathArrray) => {
  switch (typeof tree) {
    case 'object': {
      const newTree = {}
      Object.keys(tree).forEach(key => {
        newTree[key] = actionsGenerator(tree && tree[key], [...pathArrray, key])
      })
      return newTree
    }
    case 'function':
      return tree(pathArrray.join('.'))
    default:
      throw new Error('Incorrect argument given to actionsGenerator')
  }
}

export default actionsGenerator
