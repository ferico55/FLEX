import { connect } from 'react-redux'
import { bindActionCreators } from 'redux'
import { sendMessage } from '@TopChatRedux/messages/Actions'
import { fetchShopProducts } from '@TopChatRedux/products/Actions'
import ProductView from './ProductView'

const mapStateToProps = state => ({
  products: state.products,
})

const mapDispatchToProps = dispatch => ({
  fetchShopProducts: bindActionCreators(fetchShopProducts, dispatch),
  sendMessage: bindActionCreators(sendMessage, dispatch),
})

export default connect(mapStateToProps, mapDispatchToProps)(ProductView)
