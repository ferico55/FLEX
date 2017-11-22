import { connect } from 'react-redux'
import { bindActionCreators } from 'redux'
import { sendMessage } from '@redux/messages/Actions'
import { fetchShopProducts } from '@redux/products/Actions'
import ProductView from './ProductView'

const mapStateToProps = state => ({
  products: state.products,
})

const mapDispatchToProps = dispatch => ({
  fetchShopProducts: bindActionCreators(fetchShopProducts, dispatch),
  sendMessage: bindActionCreators(sendMessage, dispatch),
})

export default connect(mapStateToProps, mapDispatchToProps)(ProductView)
