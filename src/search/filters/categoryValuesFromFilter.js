import fp from 'lodash/fp'

const childFlattner = option =>
  option.child ? [option, ...option.child.map(childFlattner)] : [option]
export default fp.flow([
  fp.get('options'),
  fp.map(childFlattner),
  fp.flattenDeep,
  fp.keyBy('value'),
])
