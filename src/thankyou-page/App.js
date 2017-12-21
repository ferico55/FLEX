import React, { Component } from 'react'

// Digital
import DigitalTransferPage from './pages/digital/DigitalTransferPage'

// Marketplace
import MarketplaceTransferPage from './pages/marketplace/MarketplaceTransferPage'
import MarketplaceSuccessPage from './pages/marketplace/MarketplaceSuccessPage'

// Others
import PaymentFailed from './pages/PaymentFailed'

import { getDigitalData, getMarketplaceData } from './helper/ThankyouPageRequest'
import { gtmTrack, moeTrack, appsFlyerTrack, branchTrack } from '@analytics'

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
          var data = response.data.payment     
          console.log('DATA', JSON.stringify(data))       
          this.trackingGTMMarketplace(data)
          this.trackingAppsflyerMarketplace(data)
          this.trackingMoengageMarketplace(data)
          this.trackingBranchMarketplace(data)
        }).catch(e => {
          console.log('error', e)
        })
      }
    }

    trackingBranchMarketplace = (data) => {
      let products = []
      data.orders.forEach(order => {
        order.order_detail.forEach(orderDetail => {
            const product = {
              name: orderDetail.product.product_name,
              id: orderDetail.product.product_id,
              price: orderDetail.product.product_price,
              category: orderDetail.product.category.category_name,
              quantity: orderDetail.quantity
            }
            products.push(product)
        })
      })
      const dataTracking = {
        products: products,
        currency: 'IDR',
        revenue: data.payment_amount,
      }
      console.log('GET MARKETPLACE BRANCH TRACKING DATA', JSON.stringify(dataTracking))            
      appsFlyerTrack(dataTracking)
    }

    trackingAppsflyerMarketplace = (data) => {
      let productIDs = []
      let quantities = []
      data.orders.forEach(order => {
        order.order_detail.forEach(orderDetail => {
          productIDs.push(orderDetail.product.product_id)  
          quantities.push(orderDetail.quantity)        
        })
      })

      const dataTracking = {
        af_revenue: data.payment_amount,
        af_content_type: 'Product',
        af_content_id: `[${productIDs.toString()}]`, 
        af_quantity: quantities.reduce((total, amount) => total + amount),
        af_currency: 'IDR',
        af_order_id: data.payment_id
      }
      console.log('GET MARKETPLACE APPFLYERS TRACKING DATA', JSON.stringify(dataTracking))            
      appsFlyerTrack(dataTracking)
    }

    trackingMoengageMarketplace = (data) => {
      const dataTracking = {
        name: 'Thank_You_Page_Launched',
        payment_type: data.payment_method.method,
        total_price : data.payment_amount
      }
      console.log('GET MARKETPLACE MOENGAGE TRACKING DATA', JSON.stringify(dataTracking))            
      moeTrack(dataTracking)
    }

    trackingGTMMarketplace = (data) => {
      data.orders.forEach(order => {
        const dataTracking = {
            event : 'transaction',
            payment_id: data.payment_id,
            payment_status: '',
            payment_type: data.payment_method.method,
            shopId: order.shop.shop_id, 
            shopType: '',
            logistic_type: order.shipping.shipping_name,
            ecommerce: {
                currencyCode: 'IDR',
                purchase: {
                  actionField: {
                    id: order.order_id,          
                    affiliation: order.shop.shop_name,
                    revenue: data.payment_amount,
                    tax: '',
                    shipping: order.shipping_price,
                    coupon: '',
                  },
                  products: order.order_detail.map(orderDetail => ({
                    name: orderDetail.product.product_name,
                    id: orderDetail.product.product_id,
                    price: orderDetail.product.product_price,
                    brand: 'other',
                    category: orderDetail.product.category.category_name,
                    variant: 'other',
                    quantity: orderDetail.quantity,
                    coupon: ''
                  }))
                }
              }
            }
          console.log('GET MARKETPLACE GTM TRACKING DATA', JSON.stringify(dataTracking))            
          gtmTrack(dataTracking)    
        })
      }
}