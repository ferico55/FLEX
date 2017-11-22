import fp from 'lodash/fp'

export default options =>
  fp.flow([
    fp.groupBy('value'),
    fp.values,
    fp.map(array => {
      const names = fp.flow([fp.map(fp.get('name'))])(array)
      const metrics = fp.flow([fp.map(fp.get('metric'))])(array)
      const name = fp.flow([
        fp.zip(names),
        fp.map(fp.invokeArgs('join', [' '])),
        fp.invokeArgs('join', [' / ']),
        fp.invokeArgs('replace', [' International', '']),
      ])(metrics)
      return { ...array[0], name, names, metrics }
    }),
  ])(options)
