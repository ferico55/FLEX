import { connect } from 'react-redux'
import { bindActionCreators } from 'redux'
import { fetchBrands, slideBrands } from '../actions/actions'

import BrandGrid from '../components/brandGrid'

const mapStateToProps = state => ({
  brands: state.brands,
  limit: state.brands.pagination.limit,
  offset: state.brands.pagination.offset,
})

const mapDispatchToProps = dispatch => ({
  loadMore: bindActionCreators(fetchBrands, dispatch),
  slideMore: bindActionCreators(slideBrands, dispatch),
})

export default connect(mapStateToProps, mapDispatchToProps)(BrandGrid)
