import React from 'react'
import { View, Text } from 'react-native'
import PropTypes from 'prop-types'
import { ReactTPRoutes, TKPReactAnalytics } from 'NativeModules'
import ProductList from './ProductList'
import TKPButton from '../common/TKPPrimaryBtn'

const PRODUCT_LIST_THRESHOLD = 12

const handleViewAllTap = (catLevel, catName, slug, catSlug) => {
  const level = catLevel + 1
  const catLocation = `Level - ${level}`

  TKPReactAnalytics.trackEvent({
    name: 'clickOSMicrosite',
    category: 'Promo - Product List',
    action: 'Click',
    label: `View All - ${catLocation} - ${catName}`,
  })

  ReactTPRoutes.navigate(
    `https://www.tokopedia.com/official-store/promo/${slug}/${catSlug}`,
  )
}

const Category = ({ category, slug, index }) => {
  const totalProducts = category.products.length
  const productsToShow =
    totalProducts > PRODUCT_LIST_THRESHOLD
      ? category.products.slice(0, 12)
      : category.products
  return (
    <View style={{ marginBottom: 10 }}>
      <View
        style={{
          backgroundColor: '#FFF',
          borderTopWidth: 1,
          borderBottomWidth: 1,
          borderColor: '#e0e0e0',
          marginVertical: 10,
        }}
      >
        <View style={{ paddingVertical: 15, paddingHorizontal: 10 }}>
          <Text
            numberOfLines={1}
            style={{ fontSize: 16, fontWeight: '600', color: 'rgba(0,0,0,.7)' }}
          >
            {category.category_name}
          </Text>
        </View>
        <ProductList products={productsToShow} category={category} />
      </View>

      {totalProducts > 12 && (
        <View
          style={{ flex: 1, justifyContent: 'center', alignItems: 'center' }}
        >
          <TKPButton
            content="View All"
            onTap={() =>
              handleViewAllTap(
                index,
                category.category_name,
                slug,
                category.slug,
              )}
            type="small"
          />
        </View>
      )}
    </View>
  )
}

Category.propTypes = {
  category: PropTypes.shape({
    category_name: PropTypes.string.isRequired,
  }).isRequired,
  slug: PropTypes.string.isRequired,
  index: PropTypes.number.isRequired,
}

export default Category
