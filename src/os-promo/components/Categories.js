import React, { PureComponent } from 'react'
import { View, FlatList } from 'react-native'
import PropTypes from 'prop-types'
import Category from './Category'
import Footer from '../components/Infographics'
import BannerContainer from '../containers/BannerContainer'

class Categories extends PureComponent {
  componentDidMount() {
    const { offset, limit } = this.props.categories.pagination
    const slug = this.props.slug
    this.props.getCategories(slug, offset, limit)
  }

  loadMore = () => {
    if (
      this.props.categories.isFetching ||
      !this.props.categories.canLoadMore
    ) {
      return
    }
    const { offset, limit } = this.props.categories.pagination
    const slug = this.props.slug
    this.props.getCategories(slug, offset, limit)
  }

  renderCategory = ({ item, index }) => (
    <Category category={item} slug={this.props.slug} index={index} />
  )

  renderFooter = () => <Footer />

  renderHeader = () => (
    <View>
      <BannerContainer
        navigation={this.props.navigation}
        termsConditions={this.props.dataTermsConditions}
        slug={this.props.slug}
      />
    </View>
  )

  render() {
    const categories = this.props.categories.items
    return (
      <FlatList
        data={categories}
        keyExtractor={item => item.category_id}
        renderItem={this.renderCategory}
        onEndReached={this.loadMore}
        onEndReachedThreshold={0.5}
        ListFooterComponent={this.renderFooter}
        ListHeaderComponent={this.renderHeader}
        style={{ backgroundColor: '#F8F8F8' }}
      />
    )
  }
}

Categories.propTypes = {
  getCategories: PropTypes.func.isRequired,
  categories: PropTypes.shape({
    items: PropTypes.array,
    isFetching: PropTypes.bool,
    pagination: PropTypes.shape({
      offset: PropTypes.number,
      limit: PropTypes.number,
    }),
  }).isRequired,
  slug: PropTypes.string.isRequired,
}

export default Categories
