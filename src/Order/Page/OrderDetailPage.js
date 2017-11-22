import React, { Component } from 'react'
import Navigator from 'native-navigation'
import {
  View,
  ScrollView,
  StyleSheet,
  RefreshControl,
  NativeEventEmitter,
} from 'react-native'
import {
  ReactOrderManager,
  EventManager,
  ReactInteractionHelper,
  ReactTPRoutes,
  TKPReactAnalytics,
} from 'NativeModules'

import { getOrderDetail } from '../Helper/OrderRequest'

import OrderDetailHeaderView from '../Components/OrderDetailHeaderView'
import OrderDetailProductCell from '../Components/OrderDetailProductCell'
import OrderDetailPricingView from '../Components/OrderDetailPricingView'
import OrderDetailButtonView from '../Components/OrderDetailButtonView'

const nativeTabEmitter = new NativeEventEmitter(EventManager)

const styles = StyleSheet.create({
  container: {
    backgroundColor: 'rgba(241, 241, 241, 1.0)',
  },
})

export default class OrderDetailPage extends Component {
  constructor(props) {
    super(props)
    this.state = {
      isLoading: true,
      orderData: {},
      orderProducts: [],
      actionButtons: {},
      shouldPop: false,
      shouldRefresh: false,
      isAppeared: true,
    }
  }

  componentDidMount = () => {
    this.getData()
    this.subscription = nativeTabEmitter.addListener('popNavigation', () => {
      if (this.state.isAppeared) {
        Navigator.pop()
      } else {
        this.setState({
          shouldPop: true,
        })
      }
    })
  }

  didAppear = () => {
    TKPReactAnalytics.trackScreenName('Order Detail Page')
    this.setState({
      isAppeared: true,
    })
    if (this.state.shouldPop) {
      Navigator.pop()
    } else if (this.state.shouldRefresh) {
      this.getData()
    }
  }

  didDisappear = () => {
    this.setState({
      isAppeared: false,
    })
  }

  componentWillUnmount = () => {
    this.subscription.remove()
  }

  getData = () => {
    this.setState({
      isLoading: true,
      shouldRefresh: false,
    })
    getOrderDetail({
      userID: this.props.user_id,
      orderID: this.props.order_id,
      type: this.props.type,
    })
      .then(response => {
        this.setState({
          isLoading: false,
          orderData: response.data,
          orderProducts: response.data.products,
          actionButtons: response.data.buttons,
        })
      })
      .catch(error => {
        ReactInteractionHelper.showErrorStickyAlert(error.description)
        this.setState({
          isLoading: false,
        })
      })
  }
  goToHistory = () => {
    Navigator.push('HistoryPage', {
      user_id: this.props.user_id,
      order_id: this.props.order_id,
      type: this.props.type,
    })
  }
  seeInvoice = () => {
    ReactOrderManager.seeInvoice(this.state.orderData.invoice_url)
  }
  goToPDP = productId => {
    ReactTPRoutes.navigate(`tokopedia://product/${productId}`)
  }
  doAction = actionId => {
    if (actionId === 'ask_buyer') {
      ReactOrderManager.askBuyer()
    } else if (actionId === 'accept_order') {
      ReactOrderManager.acceptOrder()
    } else if (actionId === 'reject_new_order') {
      ReactOrderManager.rejectNewOrder()
    } else if (actionId === 'reject_order') {
      ReactOrderManager.rejectOrder()
    } else if (
      actionId === 'confirm_shipping' ||
      actionId === 'request_pickup'
    ) {
      ReactOrderManager.confirmShipping()
    } else if (actionId === 'change_awb') {
      ReactOrderManager.changeAWB()
        .then(_ => {
          this.getData()
        })
        .catch(() => {
          console.log('error')
        })
    } else if (actionId === 'view_complaint') {
      ReactOrderManager.seeComplaint(`${this.state.orderData.reso_id}`)
    } else if (actionId === 'track') {
      this.setState({
        shouldRefresh: true,
      })
      ReactOrderManager.trackOrder()
    }
  }
  render = () => (
    <Navigator.Config
      title="Detail Transaksi"
      onAppear={this.didAppear}
      onDisappear={this.didDisappear}
    >
      <ScrollView
        style={styles.container}
        refreshControl={
          <RefreshControl
            refreshing={this.state.isLoading}
            onRefresh={() => this.getData()}
          />
        }
      >
        <OrderDetailHeaderView
          orderId={this.state.orderId}
          invoice={{ text: this.state.orderData.invoice }}
          status={this.state.orderData.status}
          detail={this.state.orderData.detail}
          goToHistory={this.goToHistory}
          seeInvoice={this.seeInvoice}
          orderStatus={this.state.orderData.order_status}
        />
        <View style={{ paddingHorizontal: 10, backgroundColor: 'transparent' }}>
          {this.state.orderProducts.map(product => (
            <OrderDetailProductCell
              key={product.id}
              product={product}
              action={this.goToPDP}
            />
          ))}
        </View>
        <OrderDetailPricingView summary={this.state.orderData.summary} />
        <OrderDetailButtonView
          actionButtons={this.state.actionButtons}
          doAction={this.doAction}
        />
      </ScrollView>
    </Navigator.Config>
  )
}
