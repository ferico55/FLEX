// for grid and list cell
export const ProductCellViewModel = (cellData, isTopAds) => ({
  productId: isTopAds ? cellData.product.id : cellData.product_id,
  productImage: isTopAds
    ? cellData.product.image.s_ecs
    : cellData.product_image,
  productName: isTopAds ? cellData.product.name : cellData.product_name,
  productPrice: isTopAds
    ? cellData.product.price_format
    : cellData.product_price,
  productRate: isTopAds ? cellData.product.product_rating : cellData.rate,
  productReviewCount: isTopAds
    ? cellData.product.count_review_format
    : cellData.product_review_count,
  productLabels: isTopAds ? cellData.product.labels : cellData.labels,
  shopName: isTopAds ? cellData.shop.name : cellData.shop_name,
  shopLocation: isTopAds ? cellData.shop.location : cellData.shop_location,
  badges: isTopAds ? cellData.shop.badges : cellData.badges,
  isOnWishlist: isTopAds ? false : cellData.isOnWishlist,
})

export const ProductCellThumbnailViewModel = cellData => ({
  productId: cellData.product_id,
  productImage: cellData.product_image,
  productName: cellData.product_name,
  productPrice: cellData.product_price,
  productReviewCount: cellData.product_review_count,
  productLabels: cellData.labels,
  shopName: cellData.shop_name,
  shopLocation: cellData.shop_location,
  badges: cellData.badges,
  isOnWishlist: cellData.isOnWishlist,
  productTalkCount: cellData.product_talk_count,
})
