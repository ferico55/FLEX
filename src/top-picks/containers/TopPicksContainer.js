import { connect } from 'react-redux'
import {
  fetchTopPicks,
  fetchTopPicksProduct,
  showMoreProducts,
  reloadState,
} from '../actions/index'
import TopPick from '../components/TopPick'

const mapStateToProps = (state, ownProps) => ({
  components: state.topPicks.components,
  isFetching: state.topPicks.isFetching,
  pageId: ownProps.pageId,
  products: state.topPicks.products,
  isError: state.topPicks.error,
  title: state.topPicks.title
})

const mapDispatchToProps = dispatch => ({
  getTopPicks: pageId => {
    dispatch(fetchTopPicks(pageId))
  },
  getProducts: urls => {
    dispatch(fetchTopPicksProduct(urls))
  },
  showMoreProducts: (limit, offset) => {
    dispatch(showMoreProducts(limit, offset))
  },
  resetState: () => {
    dispatch(reloadState())
  },
})

export default connect(mapStateToProps, mapDispatchToProps)(TopPick)
