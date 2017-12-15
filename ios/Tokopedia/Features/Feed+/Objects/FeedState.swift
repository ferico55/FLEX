//
//  FeedState.swift
//  Tokopedia
//
//  Created by Kenneth Vincent on 4/6/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

import UIKit
import Foundation
import Render
import ReSwift
import Apollo

enum FeedContentType {
    case invalid
    case notHandled
    case newProduct
    case editProduct
    case topAds
    case promotion
    case officialStoreBrand
    case officialStoreCampaign
    case toppicks
    case inspiration
    case KOLPost
    case KOLRecommendation
    case followedKOLPost
    case favoriteCTA
    case emptyState
    case nextPageError
}

enum FeedErrorType {
    case emptyFeed
    case serverError
}

struct FeedState: Render.StateType, ReSwift.StateType {
    let oniPad = (UI_USER_INTERFACE_IDIOM() == .pad)
    var hasNextPage = false
    var totalData = 0
    var feedCards: [FeedCardState] = []
    var cursor = ""
    var topads: TopAdsFeedPlusState?
    var errorType: FeedErrorType = .emptyFeed
    var emptyStateButtonIsLoading = false
    var page = 0
}

struct FeedCardState: Render.StateType, ReSwift.StateType {
    let oniPad = (UI_USER_INTERFACE_IDIOM() == .pad)
    var cursor: String? = ""
    var cardID: String? = ""
    var createTime: String? = ""
    var type: String? = ""
    var source = FeedCardSourceState()
    var content = FeedCardContentState()
    var topads: TopAdsFeedPlusState?
    var isEmptyState = false
    var errorType: FeedErrorType = .emptyFeed
    var refreshButtonIsLoading = false
    var isNextPageError = false
    var nextPageReloadIsLoading = false
    var row = 0
    var page = 0
    var isImpression = false
}

struct FeedCardSourceState: Render.StateType, ReSwift.StateType {
    let oniPad = (UI_USER_INTERFACE_IDIOM() == .pad)
    var type = 0
    var fromTokopedia = false
    var shopState = FeedCardShopState()
}

struct FeedCardContentState: Render.StateType, ReSwift.StateType {
    let oniPad = (UI_USER_INTERFACE_IDIOM() == .pad)
    var type: FeedContentType = .notHandled
    var totalProduct: Int? = 0
    var product: [FeedCardProductState?] = []
    var promotion: [FeedCardPromotionState] = []
    var activity = FeedCardActivityState()
    var officialStore: [FeedCardOfficialStoreState]?
    var redirectURL = ""
    var toppicks: [FeedCardToppicksState]?
    var inspiration: FeedCardInspirationState?
    var kolPost: FeedCardKOLPostState?
    var kolRecommendation: FeedCardKOLRecommendationState?
    var favoriteCTA: FeedCardFavoriteCTAState?
    var page = 0
    var row = 0
}

struct FeedCardFavoriteCTAState: Render.StateType, ReSwift.StateType {
    var title = ""
    var subtitle = ""
    
    init() {}
    
    init(favoriteCTA: FeedsQuery.Data.Feed.Datum.Content.FavoriteCtum) {
        if let title = favoriteCTA.titleId,
            let subtitle = favoriteCTA.subtitleId {
            self.title = title
            self.subtitle = subtitle
        }
    }
}

struct FeedCardActivityState: Render.StateType, ReSwift.StateType {
    var source = ""
    var activity = ""
    var amount = 0
    
    init() {}
    
    init(statusActivity: FeedsQuery.Data.Feed.Datum.Content.NewStatusActivity) {
        if let source = statusActivity.source,
            let activity = statusActivity.activity,
            let amount = statusActivity.amount {
            self.source = NSString.convertHTML(source)
            self.activity = activity
            self.amount = amount
        }
        
    }
}

struct FeedCardInspirationState: Render.StateType, ReSwift.StateType {
    let onPad = (UI_USER_INTERFACE_IDIOM() == .pad)
    var title = ""
    var products: [FeedCardProductState?] = []
    
    init() {}
    
    init(data: FeedsQuery.Data.Feed.Datum.Content.Inspirasi, row: Int) {
        self.title = data.title ?? ""
        
        if let recommendation = data.recommendation {
            let productArray: [FeedCardProductState] = recommendation.map { product in
                if let product = product, let source = data.source {
                    var productState = FeedCardProductState(recommendationProduct: product, row: row)
                    productState.recommendationProductSource = source
                    
                    return productState
                }
                
                return FeedCardProductState()
            }
            
            self.products = productArray
        }
    }
}

struct FeedCardToppicksState: Render.StateType, ReSwift.StateType {
    let onPad = (UI_USER_INTERFACE_IDIOM() == .pad)
    var name = ""
    var isParent = false
    var imageURL = ""
    var redirectURL = ""
    var page = 0
    var row = 0
    
    init() {}
    
    init(toppick: FeedsQuery.Data.Feed.Datum.Content.TopPick, page: Int, row: Int) {
        self.name = toppick.name ?? ""
        self.isParent = toppick.isParent ?? false
        self.imageURL = toppick.imageUrl ?? ""
        self.redirectURL = toppick.url ?? ""
        self.page = page
        self.row = row
    }
}

struct FeedCardShopState: Render.StateType, ReSwift.StateType {
    var shopName = ""
    var shopImage = ""
    var shopIsGold = false
    var shopIsOfficial = false
    var shopURL = ""
    var shareURL = ""
    var shareDescription = ""
}

struct FeedCardProductState: Render.StateType, ReSwift.StateType {
    let oniPad = (UI_USER_INTERFACE_IDIOM() == .pad)
    var productID = ""
    var productName = ""
    var productPrice = ""
    var productImageSmall = ""
    var productImageLarge = ""
    var productURL = ""
    var productRating = 0
    var productWholesale = false
    var productFreeReturns = false
    var productPreorder = false
    var productCashback = ""
    var productWishlisted = false
    var isMore = false
    var isLargeCell = false
    var remaining: Int? = 0
    var cardID = ""
    var isRecommendationProduct = false
    var recommendationProductSource = ""
    
    var isCampaign = false
    var originalPrice = ""
    var discountPercentage = 0
    var hasLabels = false
    var labels: [FeedCardProductLabelState] = []
    var shopImageURL = ""
    var shopName = ""
    var shopURL = ""
    var isFreeReturns = false
    var page = 0
    var row = 0
    
    init() {}
    
    init(recommendationProduct: FeedsQuery.Data.Feed.Datum.Content.Inspirasi.Recommendation, row: Int) {
        guard let name = recommendationProduct.name,
            let price = recommendationProduct.price,
            let image = recommendationProduct.imageUrl,
            let url = recommendationProduct.appUrl else { return }
        
        self.productName = name
        self.productPrice = price
        self.productImageSmall = image
        self.productURL = url
        self.isRecommendationProduct = true
        self.row = row
    }
    
    init(officialStoreProduct: FeedsQuery.Data.Feed.Datum.Content.OfficialStore.Product, page: Int, row: Int) {
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

struct FeedCardPromotionState: Render.StateType, ReSwift.StateType {
    let oniPad = (UI_USER_INTERFACE_IDIOM() == .pad)
    var banneriPad = ""
    var banneriPhone = ""
    var promotionID = ""
    var period = ""
    var voucherCode = ""
    var desc = ""
    var minimumTransaction = ""
    var promoURL = ""
    var isSinglePromotion = false
    var hasNoCode = false
    var promoName = ""
    var page = 0
    var row = 0
}

struct FeedCardOfficialStoreState: Render.StateType, ReSwift.StateType {
    let oniPad = (UI_USER_INTERFACE_IDIOM() == .pad)
    var title = ""
    var shopImageURL = ""
    var shopURL = ""
    var isCampaign = false
    var bannerURL = ""
    var borderHexString = ""
    var redirectURL = "tokopedia://official-store/mobile"
    var products: [FeedCardOfficialStoreProductState] = []
    var incomplete = false
    var page = 0
    var row = 0
    
    init() {}
    
    init(data: FeedsQuery.Data.Feed.Datum.Content.OfficialStore, redirectURL: String, page: Int, row: Int) {
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

struct FeedCardOfficialStoreProductState: Render.StateType, ReSwift.StateType {
    var brandLogoURL = ""
    var productDetail = FeedCardProductState()
    
    init() {}
    
    init(productData: FeedsQuery.Data.Feed.Datum.Content.OfficialStore.Product, page: Int, row: Int) {
        self.brandLogoURL = productData.brandLogo ?? ""
        self.productDetail = FeedCardProductState(officialStoreProduct: productData, page: page, row: row)
        self.productDetail.page = page
        self.productDetail.row = row
    }
}

struct FeedCardProductLabelState: Render.StateType, ReSwift.StateType {
    var hasLabel = false
    var backgroundColor = ""
    var text = ""
    var textColor: UIColor = .white
    
    init() {}
    
    init(productLabel: FeedsQuery.Data.Feed.Datum.Content.OfficialStore.Product.Datum.Label) {
        self.backgroundColor = productLabel.color
        self.text = productLabel.title
        
        if self.backgroundColor == "#ffffff" {
            self.textColor = .tpDisabledBlackText()
        }
    }
}

struct FeedCardKOLRecommendedUserState: Render.StateType, ReSwift.StateType {
    var isFollowed = false
    var userName = ""
    var userID = 0
    var userPhoto = ""
    var userInfo = ""
    var userURL = ""
    
    init() {}
    
    init(recommendedUser: FeedsQuery.Data.Feed.Datum.Content.Kolrecommendation.Kol, page: Int, row: Int) {
        self.isFollowed = recommendedUser.isFollowed ?? false
        self.userName = recommendedUser.userName ?? ""
        self.userID = recommendedUser.userId ?? 0
        self.userPhoto = recommendedUser.userPhoto ?? ""
        self.userInfo = recommendedUser.info ?? ""
        self.userURL = recommendedUser.url ?? ""
    }
}

class FeedStateManager: NSObject {
    func initFeedState(queryResult: FeedsQuery.Data?, page: Int, row: inout Int) -> FeedState {
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
            
            if let data = feedData[dataSize - 1], let cursor = data.cursor {
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
                    var productState = self.initFeedProduct(feedProduct: product, cardID: cardID, page: page, row: row)
                    
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
            } else if let followedKOLPost = feedContent.followedkolpost {
                content.kolPost = FeedCardKOLPostState(post: followedKOLPost, page: page, row: row)
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
        default:
            content.type = .notHandled
        }
        
        content.page = page
        content.row = row
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
    
    private func initFeedProduct(feedProduct: FeedsQuery.Data.Feed.Datum.Content.Product, cardID: String, page: Int, row: Int) -> FeedCardProductState {
        
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
            let url = feedProduct.productLink else {
            return FeedCardProductState()
        }
        
        var product = FeedCardProductState()
        
        product.productID = "\(productID)"
        product.productName = name
        product.productRating = Int(rating)
        product.productCashback = cashback
        product.productWholesale = (wholesale.count == 0)
        product.productPrice = price
        product.productImageSmall = image
        product.productImageLarge = imageLarge
        product.productFreeReturns = freeReturns
        product.productWishlisted = wishlist
        product.productPreorder = preorder
        product.productURL = url
        product.cardID = cardID
        product.page = page
        product.row = row
        return product
    }
}
