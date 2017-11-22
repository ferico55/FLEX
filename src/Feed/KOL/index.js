import React from 'react'
import { ApolloProvider } from 'react-apollo'

import Client from '../Client'
import FeedKOLActivityComment from './comment'

export default props => (
  <ApolloProvider client={Client}>
    <FeedKOLActivityComment {...props} />
  </ApolloProvider>
)
