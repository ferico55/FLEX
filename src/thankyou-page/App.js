import React, { Component } from 'react'

// Digital
import DigitalTransferPage from './pages/digital/DigitalTransferPage'

// Marketplace
import MarketplaceTransferPage from './pages/marketplace/MarketplaceTransferPage'
import MarketplaceSuccessPage from './pages/marketplace/MarketplaceSuccessPage'

// Others
import PaymentFailed from './pages/PaymentFailed'

import { getDigitalData, getMarketplaceData } from './helper/ThankyouPageRequest'
import { gtmTrack } from '@analytics'

export default class App extends Component {
    render() {
      const { 
        template,
        platform,
      } = this.props.data

      console.log(this.props.data)

      if (platform === 'marketplace'){
        // this.trackingMarketplace()
        if (template === 'instant') {
          return <MarketplaceSuccessPage data={this.props.data} />
        } else if (template === 'transfer'){
          return <MarketplaceTransferPage data={this.props.data} />
        }
      } else if (platform === 'digital'){
        this.trackingDigital()
        if (template === 'transfer'){
          return <DigitalTransferPage data={this.props.data}/>
        }
      } else {
        return <PaymentFailed data={this.props.data} />
      }
    }

    trackingDigital = ()  => {
      console.log('DIGITAL TRACKING')
      if (this.props.data.transaction_id) {
        getDigitalData({
          userID: this.props.userID,
          orderID: parseInt(this.props.data.transaction_id),
          deviceToken: this.props.deviceToken
        }).then(data => {
          console.log('GET DIGITAL TRACKING DATA', data)
          gtmTrack({ data })
        }).catch(e => {
          console.log('error', e)
        })
      }
    }

    // trackingMarketplace = ()  => {
    //   if (this.props.data.transaction_id) {
    //     getMarketplaceData({
    //       paymentID: parseInt(this.props.data.transaction_id)
    //     }).then(data => {
    //       console.log('GET MARKETPLACE TRACKING DATA', data)
    //       for() { // list cart
    //         var dataTracking = {
    //           'event' : 'transaction',
    //           'payment_id': data.payment.payment_id,
    //           'payment_status': data.payment.payment_status,
    //           'payment_type': data.payment.payment_type,
    //           // 'shopId': , 
    //           // 'shopType': , 
    //           // 'logistic_type': ,
    //           'ecommerce': {
    //               // 'currencyCode': ,
    //               'purchase': {
    //               'actionField': {
    //               'id': data.payment.payment_id,          //  payment_id
    //               // 'affiliation': '',     // shop_name
    //               // 'revenue': , // total amount
    //               // 'tax': '',
    //               // 'shipping': '', //ongkir
    //               // 'coupon': ''
    //               },
    //               // 'products': [{
    //               //     'name': 'P1',
    //               //     'id': 'PId1',
    //               //     'price': 19.00,
    //               //     'brand': '',
    //               //     'category': '',
    //               //     'variant': '',
    //               //     'quantity': 1,
    //               //     'coupon': ''
    //               //     }]
    //               }
    //           },
    //         }
    //         gtmTrack({ dataTracking })
    //       }
    //     }).catch(e => {
    //       console.log('error', e)
    //     })
    //   }
    // }
}