import React, { Component } from 'react'
import Navigator from 'native-navigation'

import { ApolloClient } from 'apollo-client'
import { HttpLink } from 'apollo-link-http'
import { InMemoryCache } from 'apollo-cache-inmemory'
import { setContext } from 'apollo-link-context'
import { onError } from 'apollo-link-error'
import {
  ReactUserManager,
  TKPReactURLManager,
  ReactInteractionHelper,
} from 'NativeModules'

const httpLink = new HttpLink({
  uri: TKPReactURLManager.graphQLURL,
})

const authLink = setContext(() =>
  ReactUserManager.getGraphQLRequestHeader().then(header => ({
    headers: {
      ...header,
    },
  })),
)

const errorLink = onError(({ graphQLErrors, networkError }) => {
  if (graphQLErrors) {
    graphQLErrors.map(
      ({ message, locations, path }) => {},
      client.resetStore().catch(e => {
        ReactInteractionHelper.showErrorStickyAlert(
          'Mohon maaf, terjadi kendala pada server. Silakan coba kembali.',
        )
        Navigator.pop()
      }),
    )
  }

  if (networkError) {
    client.resetStore().catch(e => {
      Navigator.pop()
    })
  }
})

export default new ApolloClient({
  link: errorLink.concat(authLink).concat(httpLink),
  cache: new InMemoryCache(),
})
