import numeral from 'numeral'

numeral.register('locale', 'toko', {
  delimiters: {
    thousands: '.',
    decimal: ',',
  },
  abbreviations: {
    thousand: 'k',
    million: 'm',
    billion: 'b',
    trillion: 't',
  },
  currency: {
    symbol: 'Rp',
  },
})

numeral.locale('toko')

export default numeral
