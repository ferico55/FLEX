import React from 'react'
import { Provider } from 'react-redux'

import topAdsDashboardStore from './Redux/store'

import TopAdsDashboard from './Page/TopAdsDashboard'
import StatDetailPage from './Page/StatDetailPage'
import DateSettingsPage from './Page/DateSettingsPage'
import AddCreditPage from './Page/AddCreditPage'
import PromoListPage from './Page/PromoListPage'
import PromoDetailPage from './Page/PromoDetailPage'
import FilterPage from './Page/FilterPage'
import FilterDetailPage from './Page/FilterDetailPage'
import AddPromoPage from './Page/AddPromoPage'
import AddPromoPageStep1 from './Page/AddPromoPageStep1'
import AddPromoPageStep2 from './Page/AddPromoPageStep2'
import AddPromoPageStep3 from './Page/AddPromoPageStep3'
import ChooseProductPage from './Page/ChooseProductPage'
import EditPromoPage from './Page/EditPromoPage'
import EditPromoGroupNamePage from './Page/EditPromoGroupNamePage'

const withStore = store => Screen => props => (
  <Provider store={store}>
    <Screen {...props} />
  </Provider>
)

const provided = withStore(topAdsDashboardStore)

export default {
  TopAdsDashboard: provided(TopAdsDashboard),
  StatDetailPage: provided(StatDetailPage),
  DateSettingsPage: provided(DateSettingsPage),
  AddCreditPage: provided(AddCreditPage),
  PromoListPage: provided(PromoListPage),
  PromoDetailPage: provided(PromoDetailPage),
  FilterPage: provided(FilterPage),
  FilterDetailPage: provided(FilterDetailPage),
  AddPromoPage: provided(AddPromoPage),
  AddPromoPageStep1: provided(AddPromoPageStep1),
  AddPromoPageStep2: provided(AddPromoPageStep2),
  AddPromoPageStep3: provided(AddPromoPageStep3),
  ChooseProductPage: provided(ChooseProductPage),
  EditPromoPage: provided(EditPromoPage),
  EditPromoGroupNamePage: provided(EditPromoGroupNamePage),
}
