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
        this.trackingMarketplace()
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

    trackingMarketplace = ()  => {
      if (this.props.data.transaction_id) {
        getMarketplaceData({
          paymentID: parseInt(this.props.data.transaction_id)
        }).then(response => {
          let data = response.data.payment
          for(var index in data.orders) { 
            var products = []
            var order = data.orders[index]   
            for(let indexProduct in order.order_detail) {
              var orderDetail = order.order_detail[indexProduct]
              var product = orderDetail.product   
              var productData = {
                'name': product.product_name,
                'id': product.product_id,
                'price': product.product_price,
                'brand': 'other',
                'category': product.category.category_name,
                'variant': 'other',
                'quantity': orderDetail.quantity,
                'coupon': ''
              }
              products.push(productData)
            }
            var dataTracking = {
              'event' : 'transaction',
              'payment_id': data.payment_id,
              'payment_status': '',
              'payment_type': data.payment_method.method,
              'shopId': order.shop.shop_id, 
              'shopType': '',
              'logistic_type': order.shipping.shipping_name,
              'ecommerce': {
                  'currencyCode': 'IDR',
                  'purchase': {
                    'actionField': {
                      'id': order.order_id,          
                      'affiliation': order.shop.shop_name,
                      'revenue': data.payment_amount,
                      'tax': '',
                      'shipping': order.shipping_price,
                      'coupon': '',
                    },
                    'products': products
                  }
              },
            }
            console.log('GET MARKETPLACE GTM TRACKING DATA', JSON.stringify(dataTracking))            
            gtmTrack({ dataTracking })
          }
        }).catch(e => {
          console.log('error', e)
        })
      }
    }
}