import { connect } from 'react-redux'
import Categories from '../components/Categories'
import { fetchCategories } from '../actions/index'

const mapStateToProps = (state, ownProps) => ({
  categories: state.categories,
  navigation: ownProps.navigation,
  termsConditions: ownProps.termsConditions,
  slug: ownProps.slug,
})

const mapDispatchToProps = dispatch => ({
  getCategories: (slug, offset, limit) => {
    dispatch(fetchCategories(slug, offset, limit))
  },
})

export default connect(mapStateToProps, mapDispatchToProps)(Categories)
