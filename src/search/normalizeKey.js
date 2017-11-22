import fp from 'lodash/fp'

export default key => fp.last(key.split('$'))
