import React from 'react'
import { createStructuredSelector } from 'reselect'
import { reduxForm } from 'redux-form'
import { connect } from '../redux'
import formName from '../formName'

const selector = createStructuredSelector({
  dynamicFilterData: ({ dynamicFilterData, uniqueIdAndSource }) =>
    dynamicFilterData[uniqueIdAndSource],
})

const reduxFormConnect = reduxForm({
  form: formName,
  destroyOnUnmount: false,
})

export default Component => props => {
  const ConnectedComponentWithForm = connect(selector)(
    reduxFormConnect(Component),
  )
  return <ConnectedComponentWithForm {...props} />
}
