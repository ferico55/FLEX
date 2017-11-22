import fp from 'lodash/fp'

export default fp.flow([
  fp.map(fp.get('options')),
  fp.map(
    fp.flow([
      fp.map(({ key, ...rest }) => ({
        ...rest,
        key: fp.first(key.split('[')),
      })),
      fp.groupBy('key'),
      fp.pickBy(fp.every(({ input_type }) => input_type === 'checkbox')),
    ]),
  ),
  fp.reduce((sum, value) => ({ ...sum, ...value }), {}),
])
