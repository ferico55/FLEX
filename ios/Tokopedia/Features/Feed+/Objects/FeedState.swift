//
//  FeedState.swift
//  Tokopedia
//
//  Created by Kenneth Vincent on 4/6/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

import Apollo
import Foundation
import Render
import ReSwift
import UIKit

internal enum FeedContentType {
    case invalid
    case notHandled
    case newProduct
    case editProduct
    case topAdsShop
    case topAdsProduct
    case promotion
    case officialStoreBrand
    case officialStoreCampaign
    case toppicks
    case inspiration
    case KOLPost
    case KOLRecommendation
    case followedKOLPost
    case favoriteCTA
    case kolCTA
    case emptyState
    case nextPageError
}

internal enum FeedErrorType {
    case emptyFeed
    case serverError
}

internal struct FeedState: Render.StateType, ReSwift.StateType {
    internal let oniPad = (UI_USER_INTERFACE_IDIOM() == .pad)
    internal var hasNextPage = false
    internal var totalData = 0
    internal var feedCards: [FeedCardState] = []
    internal var cursor = ""
    internal var topads: TopAdsFeedPlusState?
    internal var errorType: FeedErrorType = .emptyFeed
    internal var emptyStateButtonIsLoading = false
    internal var page = 0
}

internal struct FeedCardState: Render.StateType, ReSwift.StateType {
    internal let oniPad = (UI_USER_INTERFACE_IDIOM() == .pad)
    internal var cursor: String? = ""
    internal var cardID: String? = ""
    internal var createTime: String? = ""
    internal var type: String? = ""
    internal var source = FeedCardSourceState()
    internal var content = FeedCardContentState()
    internal var topads: TopAdsFeedPlusState?
    internal var isEmptyState = false
    internal var errorType: FeedErrorType = .emptyFeed
    internal var refreshButtonIsLoading = false
    internal var isNextPageError = false
    internal var nextPageReloadIsLoading = false
    internal var row = 0
    internal var page = 0
    internal var isImpression = false
}

internal struct FeedCardSourceState: Render.StateType, ReSwift.StateType {
    internal let oniPad = (UI_USER_INTERFACE_IDIOM() == .pad)
    internal var type = 0
    internal var fromTokopedia = false
    internal var shopState = FeedCardShopState()
}

internal struct FeedCardContentState: Render.StateType, ReSwift.StateType {
    internal let oniPad = (UI_USER_INTERFACE_IDIOM() == .pad)
    internal var type: FeedContentType = .notHandled
    internal var typeString = ""
    internal var totalProduct: Int? = 0
    internal var product: [FeedCardProductState?] = []
    internal var promotion: [FeedCardPromotionState] = []
    internal var activity = FeedCardActivityState()
    internal var officialStore: [FeedCardOfficialStoreState]?
    internal var redirectURL = ""
    internal var toppicks: [FeedCardToppicksState]?
    internal var inspiration: FeedCardInspirationState?
    internal var kolPost: FeedCardKOLPostState?
    internal var kolRecommendation: FeedCardKOLRecommendationState?
    internal var favoriteCTA: FeedCardFavoriteCTAState?
    internal var kolCTA: FeedCardContentProductCommunicationState?
    internal var topads: FeedCardTopAdsState?
    internal var page = 0
    internal var row = 0
    internal var isKOLContent = false
    internal var isTopAds = false
    internal var display = ""
}

internal struct FeedCardFavoriteCTAState: Render.StateType, ReSwift.StateType {
    internal var title = ""
    internal var subtitle = ""
    
    internal init() {}
    
    internal init(favoriteCTA: FeedsQuery.Data.Feed.Datum.Content.FavoriteCtum) {
        if let title = favoriteCTA.titleId,
            let subtitle = favoriteCTA.subtitleId {
            self.title = title
            self.subtitle = subtitle
        }
    }
}

internal struct FeedCardActivityState: Render.StateType, ReSwift.StateType {
    internal var source = ""
    internal var activity = ""
    internal var amount = 0
    
    internal init() {}
    
    internal init(statusActivity: FeedsQuery.Data.Feed.Datum.Content.NewStatusActivity) {
        if let source = statusActivity.source,
            let activity = statusActivity.activity,
            let amount = statusActivity.amount {
            self.source = NSString.convertHTML(source)
            self.activity = activity
            self.amount = amount
        }
        
    }
}

internal struct FeedCardInspirationState: Render.StateType, ReSwift.StateType {
    internal let onPad = (UI_USER_INTERFACE_IDIOM() == .pad)
    internal var title = ""
    internal var products: [FeedCardProductState?] = []
    
    internal init() {}
    
    internal init(data: FeedsQuery.Data.Feed.Datum.Content.Inspirasi, row: Int) {
        self.title = data.title ?? ""
        
        if let recommendation = data.recommendation {
            let productArray: [FeedCardProductState] = recommendation.enumerated().map { index, product in
                if let product = product, let source = data.source {
                    var productState = FeedCardProductState(recommendationProduct: product, row: row, position: index)
                    productState.recommendationProductSource = source
                    
                    return productState
                }
                
                return FeedCardProductState()
            }
            
            self.products = productArray
        }
    }
}

internal struct FeedCardToppicksState: Render.StateType, ReSwift.StateType {
    internal let onPad = (UI_USER_INTERFACE_IDIOM() == .pad)
    internal var name = ""
    internal var isParent = false
    internal var imageURL = ""
    internal var redirectURL = ""
    internal var page = 0
    internal var row = 0
    
    internal init() {}
    
    internal init(toppick: FeedsQuery.Data.Feed.Datum.Content.TopPick, page: Int, row: Int) {
        self.name = toppick.name ?? ""
        self.isParent = toppick.isParent ?? false
        self.imageURL = toppick.imageUrl ?? ""
        self.redirectURL = toppick.url ?? ""
        self.page = page
        self.row = row
    }
}

internal struct FeedCardShopState: Render.StateType, ReSwift.StateType {
    internal var shopName = ""
    internal var shopImage = ""
    internal var shopIsGold = false
    internal var shopIsOfficial = false
    internal var shopURL = ""
    internal var shareURL = ""
    internal var shareDescription = ""
}

internal struct FeedCardProductState: Render.StateType, ReSwift.StateType {
    internal let oniPad = (UI_USER_INTERFACE_IDIOM() == .pad)
    internal var productID = ""
    internal var productName = ""
    internal var productPrice = ""
    internal var productPriceAmount = 0
    internal var productImageSmall = ""
    internal var productImageLarge = ""
    internal var productURL = ""
    internal var productRating = 0
    internal var productWholesale = false
    internal var productFreeReturns = false
    internal var productPreorder = false
    internal var productCashback = ""
    internal var productWishlisted = false
    internal var isMore = false
    internal var isLargeCell = false
    internal var remaining: Int? = 0
    internal var cardID = ""
    internal var isRecommendationProduct = false
    internal var recommendationProductSource = ""
    
    internal var isTopAdsProduct = false
    internal var topAdsProductClickURL = ""
    internal var topAdsProductImpressionURL = ""
    
    internal var isCampaign = false
    internal var originalPrice = ""
    internal var discountPercentage = 0
    internal var hasLabels = false
    internal var labels: [FeedCardProductLabelState] = []
    internal var shopImageURL = ""
    internal var shopName = ""
    internal var shopURL = ""
    internal var isFreeReturns = false
    internal var page = 0
    internal var row = 0
    internal var position = 0
    internal init() {}
    
    internal init(topAdsProduct: FeedsQuery.Data.Feed.Datum.Content.Topad.Product, url: String, topAdsProductClickURL: String, topAdsProductImpressionURL: String) {
        guard let name = topAdsProduct.name,
            let price = topAdsProduct.priceFormat,
            let image = topAdsProduct.image?.sEcs else {
            return
        }
        
        self.productName = name
        self.productPrice = price
        self.productURL = url
        self.productImageSmall = image
        self.isTopAdsProduct = true
        self.topAdsProductClickURL = topAdsProductClickURL
        self.topAdsProductImpressionURL = topAdsProductImpressionURL
    }
    
    internal init(recommendationProduct: FeedsQuery.Data.Feed.Datum.Content.Inspirasi.Recommendation, row: Int, position: Int) {
        guard let name = recommendationProduct.name,
            let price = recommendationProduct.price,
            let image = recommendationProduct.imageUrl,
            let url = recommendationProduct.appUrl,
            let priceAmount = recommendationProduct.priceInt else { return }
        
        self.productName = name
        self.productPrice = price
        self.productPriceAmount = priceAmount
        self.productImageSmall = image
        self.productURL = url
        self.isRecommendationProduct = true
        self.row = row
        self.position = position
    }
    
    internal init(officialStoreProduct: FeedsQuery.Data.Feed.Datum.Content.OfficialStore.Product, page: Int, row: Int) {
        guard let product = officialStoreProduct.data,
            let shop = product.shop,
            let badges = product.badges,
            let price = product.price,
            let name = product.name,
            let imageURL = product.imageUrl,
            let originalPrice = product.originalPrice,
            let discount = product.discountPercentage,
            let productURL = product.urlApp,
            let shopName = shop.name,
            let logo = officialStoreProduct.brandLogo,
            let shopURL = shop.urlApp else { return }
        
        self.productPrice = price
        self.productName = name
        self.productImageSmall = imageURL
        self.originalPrice = originalPrice
        self.discountPercentage = discount
        self.isCampaign = true
        self.productURL = productURL
        
        self.shopName = NSString.convertHTML(shopName)
        self.shopImageURL = logo
        self.shopURL = shopURL
        self.page = page
        self.row = row
        
        _ = badges.map { badge in
            if badge?.title == "Free Return" {
                self.isFreeReturns = true
            }
        }
        
        if let productLabels = product.labels {
            if productLabels.count > 0 {
                self.labels = productLabels.map { productLabel in
                    guard let productLabel = productLabel else { return FeedCardProductLabelState() }
                    
                    return FeedCardProductLabelState(productLabel: productLabel)
                }
            }
        }
    }
}

internal struct FeedCardPromotionState: Render.StateType, ReSwift.StateType {
    internal let oniPad = (UI_USER_INTERFACE_IDIOM() == .pad)
    internal var banneriPad = ""
    internal var banneriPhone = ""
    internal var promotionID = ""
    internal var period = ""
    internal var voucherCode = ""
    internal var desc = ""
    internal var minimumTransaction = ""
    internal var promoURL = ""
    internal var isSinglePromotion = false
    internal var hasNoCode = false
    internal var promoName = ""
    internal var page = 0
    internal var row = 0
}

internal struct FeedCardOfficialStoreState: Render.StateType, ReSwift.StateType {
    internal let oniPad = (UI_USER_INTERFACE_IDIOM() == .pad)
    internal var title = ""
    internal var shopImageURL = ""
    internal var shopURL = ""
    internal var isCampaign = false
    internal var bannerURL = ""
    internal var borderHexString = ""
    internal var redirectURL = "tokopedia://official-store/mobile"
    internal var products: [FeedCardOfficialStoreProductState] = []
    internal var incomplete = false
    internal var page = 0
    internal var row = 0
    
    internal init() {}
    
    internal init(data: FeedsQuery.Data.Feed.Datum.Content.OfficialStore, redirectURL: String, page: Int, row: Int) {
        self.shopURL = data.shopAppsUrl ?? ""
        self.shopImageURL = data.micrositeUrl ?? ""
        
        self.title = data.title ?? ""
        self.bannerURL = data.mobileImgUrl ?? ""
        self.borderHexString = data.feedHexaColor ?? ""
        self.redirectURL = redirectURL
        self.page = page
        self.row = row
        
        if let offStoreProducts = data.products {
            let tempProducts: [FeedCardOfficialStoreProductState] = offStoreProducts.map { product in
                if let product = product {
                    return FeedCardOfficialStoreProductState(productData: product, page: page, row: row)
                } else {
                    return FeedCardOfficialStoreProductState()
                }
                
            }
            
            self.products = tempProducts
            self.isCampaign = true
            
            if self.products.count != (self.oniPad ? 6 : 4) {
                self.incomplete = true
            }
        }
    }
}

internal struct FeedCardOfficialStoreProductState: Render.StateType, ReSwift.StateType {
    internal var brandLogoURL = ""
    internal var productDetail = FeedCardProductState()
    
    internal init() {}
    
    internal init(productData: FeedsQuery.Data.Feed.Datum.Content.OfficialStore.Product, page: Int, row: Int) {
        self.brandLogoURL = productData.brandLogo ?? ""
        self.productDetail = FeedCardProductState(officialStoreProduct: productData, page: page, row: row)
        self.productDetail.page = page
        self.productDetail.row = row
    }
}

internal struct FeedCardProductLabelState: Render.StateType, ReSwift.StateType {
    internal var hasLabel = false
    internal var backgroundColor = ""
    internal var text = ""
    internal var textColor: UIColor = .white
    
    internal init() {}
    
    internal init(productLabel: FeedsQuery.Data.Feed.Datum.Content.OfficialStore.Product.Datum.Label) {
        self.backgroundColor = productLabel.color
        self.text = productLabel.title
        
        if self.backgroundColor == "#ffffff" {
            self.textColor = .tpDisabledBlackText()
        }
    }
}

internal struct FeedCardKOLRecommendedUserState: Render.StateType, ReSwift.StateType {
    internal var isFollowed = false
    internal var userName = ""
    internal var userID = 0
    internal var userPhoto = ""
    internal var userInfo = ""
    internal var userURL = ""
    
    internal init() {}
    
    internal init(recommendedUser: FeedsQuery.Data.Feed.Datum.Content.Kolrecommendation.Kol, page: Int, row: Int) {
        self.isFollowed = recommendedUser.isFollowed ?? false
        self.userName = recommendedUser.userName ?? ""
        self.userID = recommendedUser.userId ?? 0
        self.userPhoto = recommendedUser.userPhoto ?? ""
        self.userInfo = recommendedUser.info ?? ""
        self.userURL = recommendedUser.url ?? ""
    }
}

internal class FeedStateManager: NSObject {
    internal func initFeedState(queryResult: FeedsQuery.Data?, page: Int, row: inout Int) -> FeedState {
        guard let result = queryResult,
            let feed = result.feed,
            let feedData = feed.data,
            let feedMeta = feed.meta,
            let feedLinks = feed.links,
            let pagination = feedLinks.pagination else { return FeedState() }
        
        var feedState = FeedState()
        feedState.totalData = feedMeta.totalData ?? 0
        
        if let hasNextPage = pagination.hasNextPage {
            feedState.hasNextPage = hasNextPage
        }
        
        feedState.page = page
        if feedState.hasNextPage {
            let dataSize = feedData.count
            
            if dataSize > 0, let data = feedData[dataSize - 1], let cursor = data.cursor {
                feedState.cursor = cursor
            }
        }
        
        var cards: [FeedCardState] = []
        feedData.forEach({ card in
            row = row + 1
            
            if let card = card {
                let feedCard = self.initFeedCard(feedData: card, page: feedState.page, row: row)
                
                if feedCard.content.type == .notHandled || feedCard.content.type == .invalid {
                    return
                }
                
                cards += [feedCard]
            }
        })
        
        feedState.feedCards = cards
        
        return feedState
    }
    
    private func initFeedCard(feedData: FeedsQuery.Data.Feed.Datum, page: Int, row: Int) -> FeedCardState {
        guard let source = feedData.source, let content = feedData.content, let cardID = feedData.id else {
            return FeedCardState()
        }
        
        var feedCard = FeedCardState()
        feedCard.cardID = feedData.id
        feedCard.createTime = feedData.createTime
        feedCard.cursor = feedData.cursor
        feedCard.createTime = feedData.createTime
        feedCard.type = feedData.type
        feedCard.source = self.initFeedCardSource(feedSource: source)
        feedCard.content = self.initFeedCardContent(feedContent: content, cardID: cardID, page: page, row: row)
        feedCard.row = row
        feedCard.page = page
        return feedCard
    }
    
    private func initFeedCardSource(feedSource: FeedsQuery.Data.Feed.Datum.Source) -> FeedCardSourceState {
        var source = FeedCardSourceState()
        source.type = feedSource.type ?? 0
        
        if let shop = feedSource.shop {
            source.shopState = self.initFeedCardShop(feedShop: shop)
        } else {
            source.fromTokopedia = true
        }
        
        return source
    }
    
    private func initFeedCardShop(feedShop: FeedsQuery.Data.Feed.Datum.Source.Shop) -> FeedCardShopState {
        guard let name = feedShop.name,
            let image = feedShop.avatar,
            let isGM = feedShop.isGold,
            let isOS = feedShop.isOfficial,
            let shopURL = feedShop.shopLink,
            let shareURL = feedShop.shareLinkUrl,
            let shareDesc = feedShop.shareLinkDescription else {
            return FeedCardShopState()
        }
        
        var shop = FeedCardShopState()
        shop.shopName = NSString.convertHTML(name)
        shop.shopImage = image
        shop.shopIsGold = isGM
        shop.shopIsOfficial = isOS
        shop.shopURL = shopURL
        shop.shareURL = shareURL
        shop.shareDescription = NSString.convertHTML(shareDesc)
        
        return shop
    }
    
    private func initFeedCardContent(feedContent: FeedsQuery.Data.Feed.Datum.Content, cardID: String, page: Int, row: Int) -> FeedCardContentState {
        var content = FeedCardContentState()
        
        guard let type = feedContent.type else {
            return FeedCardContentState()
        }
        
        switch type {
        case "promotion":
            content.type = .promotion
            
            var promotionArray: [FeedCardPromotionState] = []
            
            if let feedPromotions = feedContent.promotions {
                feedPromotions.forEach({ promotion in
                    if let promotion = promotion {
                        var promotionState = self.initFeedPromotion(promotion: promotion, page: page, row: row)
                        
                        if feedPromotions.count == 1 {
                            promotionState.isSinglePromotion = true
                        }
                        
                        promotionArray += [promotionState]
                    }
                })
                
                content.promotion = promotionArray
            } else {
                content.type = .invalid
            }
        case "new_product":
            content.type = .newProduct
            
            guard let products = feedContent.products, let total = feedContent.totalProduct, let activity = feedContent.newStatusActivity else {
                return FeedCardContentState()
            }
            
            let productArray: [FeedCardProductState] = products.enumerated().map { index, product in
                if let product = product {
                    var productState = self.initFeedProduct(feedProduct: product, cardID: cardID, page: page, row: row, position: index)
                    
                    if products.count > 6 && index == 5 {
                        productState.isMore = true
                        productState.remaining = total - 5
                    }
                    
                    if feedContent.totalProduct == 1 {
                        productState.isLargeCell = true
                    }
                    
                    return productState
                }
                
                return FeedCardProductState()
            }
            
            content.product = productArray
            content.totalProduct = total
            content.activity = FeedCardActivityState(statusActivity: activity)
        case "toppick":
            content.type = .toppicks
            
            guard let toppicks = feedContent.topPicks, toppicks.count > 0 else { return FeedCardContentState() }
            
            content.toppicks = toppicks.map { item in
                if let item = item {
                    return FeedCardToppicksState(toppick: item, page: page, row: row)
                }
                
                return FeedCardToppicksState()
            }
            
            if (content.oniPad && content.toppicks?.count != 5) || (!content.oniPad && content.toppicks?.count != 4) {
                content.type = .invalid
            }
        case "official_store_brand", "official_store_campaign":
            content.type = (feedContent.type == "official_store_brand") ? .officialStoreBrand : .officialStoreCampaign
            content.redirectURL = feedContent.redirectUrlApp ?? "tokopedia://official-store/mobile"
            
            if let officialStores = feedContent.officialStore {
                content.officialStore = officialStores.map { officialStore in
                    guard let officialStore = officialStore else {
                        return FeedCardOfficialStoreState()
                    }
                    
                    let store = FeedCardOfficialStoreState(data: officialStore, redirectURL: officialStore.redirectUrlApp ?? "tokopedia://official-store/mobile", page: page, row: row)
                    
                    if store.incomplete {
                        content.type = .invalid
                    }
                    
                    return store
                }
            }
        case "inspirasi":
            content.type = .inspiration
            
            if let inspirasi = feedContent.inspirasi,
                inspirasi.count > 0,
                let data = inspirasi[0],
                let recommendation = data.recommendation,
                (content.oniPad && recommendation.count == 6) || (!content.oniPad && recommendation.count == 4) {
                let inspiration = FeedCardInspirationState(data: data, row: row)
                
                content.inspiration = inspiration
            } else {
                content.type = .invalid
            }
        case "kolpost", "followedkolpost":
            content.type = (feedContent.type == "kolpost") ? .KOLPost : .followedKOLPost
            
            if let kolPost = feedContent.kolpost {
                content.kolPost = FeedCardKOLPostState(post: kolPost, page: page, row: row)
                content.isKOLContent = true
            } else if let followedKOLPost = feedContent.followedkolpost {
                content.kolPost = FeedCardKOLPostState(post: followedKOLPost, page: page, row: row)
                content.isKOLContent = true
            } else {
                content.type = .invalid
            }
        case "kolrecommendation":
            guard feedContent.kolrecommendation != nil else {
                return FeedCardContentState()
            }
            
            let state = FeedCardKOLRecommendationState(content: feedContent, page: page, row: row)
            
            if state.users.count > 0 {
                content.kolRecommendation = FeedCardKOLRecommendationState(content: feedContent, page: page, row: row)
                content.type = .KOLRecommendation
                content.isKOLContent = true
            } else {
                content.type = .invalid
            }
        case "favorite_cta":
            content.type = .favoriteCTA
            
            if let favoriteCTA = feedContent.favoriteCta {
                content.favoriteCTA = FeedCardFavoriteCTAState(favoriteCTA: favoriteCTA)
            } else {
                content.type = .invalid
            }
        case "kol_cta":
            content.type = .kolCTA
            
            if let kolCTA = feedContent.kolCta {
                content.kolCTA = FeedCardContentProductCommunicationState(data: kolCTA, page: page, row: row)
            } else {
                content.type = .invalid
            }
        case "topads":
            if let display = feedContent.display {
                content.type = display == "product" ? .topAdsProduct : .topAdsShop
                content.topads = FeedCardTopAdsState(content: feedContent)
                content.isTopAds = true
                
                if content.topads?.validity == .invalid {
                    content.type = .invalid
                    content.isTopAds = false
                }
            } else {
                content.type = .invalid
            }
        default:
            content.type = .notHandled
        }
        
        content.page = page
        content.row = row
        content.typeString = type
        return content
    }
    
    private func initFeedPromotion(promotion: FeedsQuery.Data.Feed.Datum.Content.Promotion, page: Int, row: Int) -> FeedCardPromotionState {
        var promo = FeedCardPromotionState()
        
        promo.banneriPhone = promotion.thumbnail
        promo.banneriPad = promotion.featureImage
        promo.promotionID = promotion.id
        promo.period = promotion.periode
        promo.voucherCode = promotion.code
        promo.minimumTransaction = promotion.minTranscation
        promo.desc = promotion.description
        promo.hasNoCode = (promotion.code == "")
        promo.promoURL = promotion.url
        promo.promoName = promotion.name
        promo.page = page
        promo.row = row
        return promo
    }
    
    private func initFeedProduct(feedProduct: FeedsQuery.Data.Feed.Datum.Content.Product, cardID: String, page: Int, row: Int, position: Int) -> FeedCardProductState {
        
        guard let productID = feedProduct.id,
            let name = feedProduct.name,
            let rating = feedProduct.rating,
            let cashback = feedProduct.cashback,
            let wholesale = feedProduct.wholesale,
            let price = feedProduct.price,
            let image = feedProduct.image,
            let imageLarge = feedProduct.imageSingle,
            let freeReturns = feedProduct.freereturns,
            let wishlist = feedProduct.wishlist,
            let preorder = feedProduct.preorder,
            let url = feedProduct.productLink,
            let priceAmount = feedProduct.priceInt else {
            return FeedCardProductState()
        }
        
        var product = FeedCardProductState()
        
        product.productID = "\(productID)"
        product.productName = name
        product.productRating = Int(rating)
        product.productCashback = cashback
        product.productWholesale = (wholesale.count == 0)
        product.productPrice = price
        product.productPriceAmount = priceAmount
        product.productImageSmall = image
        product.productImageLarge = imageLarge
        product.productFreeReturns = freeReturns
        product.productWishlisted = wishlist
        product.productPreorder = preorder
        product.productURL = url
        product.cardID = cardID
        product.page = page
        product.row = row
        product.position = position
        return product
    }
}
