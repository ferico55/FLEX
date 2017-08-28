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
    case promotion
    case officialStoreBrand
    case officialStoreCampaign
    case toppicks
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
    var inspiration: FeedInspirationState?
}

struct FeedInspirationState: Render.StateType {
    let oniPad = (UI_USER_INTERFACE_IDIOM() == .pad)
    var title = ""
    var products: [FeedCardProductState?] = []
    
    init() {}
    
    init(data: FeedsQuery.Data.Inspiration.Datum) {
        self.title = data.title!
        
        let productArray: [FeedCardProductState] = data.recommendation!.map { product in
            var productState = FeedCardProductState(recommendationProduct: product!)
            productState.recommendationProductSource = data.source!
            
            return productState
        }
        
        self.products = productArray
    }
}

struct FeedCardSourceState: Render.StateType, ReSwift.StateType {
    let oniPad = (UI_USER_INTERFACE_IDIOM() == .pad)
    var type = 0
    var fromTokopedia = false
    var shopState = FeedCardShopState()
}

struct FeedCardContentState: Render.StateType, ReSwift.StateType {
    let oniPad = (UI_USER_INTERFACE_IDIOM() == .pad)
    var type: FeedContentType = .newProduct
    var totalProduct: Int? = 0
    var product: [FeedCardProductState?] = []
    var promotion: [FeedCardPromotionState] = []
    var activity = FeedCardActivityState()
    var officialStore: [FeedCardOfficialStoreState]?
    var redirectURL = ""
    var toppicks: [FeedCardToppicksState]?
}

struct FeedCardActivityState: Render.StateType, ReSwift.StateType {
    var source = ""
    var activity = ""
    var amount = 0
    
    init() {}
    
    init(statusActivity: FeedsQuery.Data.Feed.Datum.Content.NewStatusActivity) {
        self.source = NSString.convertHTML(statusActivity.source!)
        self.activity = statusActivity.activity!
        self.amount = statusActivity.amount!
    }
}

struct FeedCardToppicksState: Render.StateType, ReSwift.StateType {
    let onPad = (UI_USER_INTERFACE_IDIOM() == .pad)
    var name = ""
    var isParent = false
    var imageURL = ""
    var redirectURL = ""
    
    init() { }
    
    init(toppick: FeedsQuery.Data.Feed.Datum.Content.TopPick) {
        self.name = toppick.name ?? ""
        self.isParent = toppick.isParent ?? false
        self.imageURL = toppick.imageUrl ?? ""
        self.redirectURL = toppick.url ?? ""
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
    
    init() {}
    
    init(recommendationProduct: FeedsQuery.Data.Inspiration.Datum.Recommendation) {
        self.productName = recommendationProduct.name!
        self.productPrice = recommendationProduct.price!
        self.productImageSmall = recommendationProduct.imageUrl!
        self.productURL = recommendationProduct.appUrl!
        self.isRecommendationProduct = true
    }
    
    init(officialStoreProduct: FeedsQuery.Data.Feed.Datum.Content.OfficialStore.Product) {
        guard let product = officialStoreProduct.data, let shop = product.shop, let badges = product.badges else { return }
        
        self.productPrice = product.price!
        self.productName = product.name!
        self.productImageSmall = product.imageUrl!
        self.originalPrice = product.originalPrice!
        self.discountPercentage = product.discountPercentage!
        self.isCampaign = true
        self.productURL = product.urlApp!
        
        self.shopName = NSString.convertHTML(shop.name!)
        self.shopImageURL = officialStoreProduct.brandLogo!
        self.shopURL = shop.urlApp!
        
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
    
    init() {}
    
    init(data: FeedsQuery.Data.Feed.Datum.Content.OfficialStore, redirectURL: String) {
        self.shopURL = data.shopAppsUrl ?? ""
        self.shopImageURL = data.micrositeUrl ?? ""
        
        self.title = data.title ?? ""
        self.bannerURL = data.mobileImgUrl ?? ""
        self.borderHexString = data.feedHexaColor ?? ""
        self.redirectURL = redirectURL
        
        if let offStoreProducts = data.products {
            let tempProducts: [FeedCardOfficialStoreProductState] = offStoreProducts.map { product in
                return FeedCardOfficialStoreProductState(productData: product!)
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
    
    init(productData: FeedsQuery.Data.Feed.Datum.Content.OfficialStore.Product) {
        self.brandLogoURL = productData.brandLogo ?? ""
        self.productDetail = FeedCardProductState(officialStoreProduct: productData)
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

class FeedStateManager: NSObject {
    func initFeedState(queryResult: FeedsQuery.Data?) -> FeedState {
        guard let result = queryResult,
            let feed = result.feed,
            let feedData = feed.data,
            let feedMeta = feed.meta,
            let feedLinks = feed.links,
            let pagination = feedLinks.pagination,
            let inspiration = result.inspiration,
            let inspirationData = inspiration.data else { return FeedState() }
        
        var feedState = FeedState()
        feedState.totalData = feedMeta.totalData ?? 0
        feedState.hasNextPage = pagination.hasNextPage!
        
        if feedState.hasNextPage {
            let dataSize = feedData.count
            feedState.cursor = (feedData[dataSize - 1]?.cursor)!
        }
        
        var cards: [FeedCardState] = []
        
        feedData.forEach({ card in
            let feedCard = self.initFeedCard(feedData: card!)
            
            if feedCard.content.type == .notHandled || feedCard.content.type == .invalid {
                return
            }
            
            cards += [feedCard]
        })
        
        if inspirationData.count > 0, let recommendationCount = inspirationData[0]?.recommendation?.count, (feedState.oniPad && recommendationCount == 6) || (!feedState.oniPad && recommendationCount == 4) {
            let feedInspiration = self.initFeedInspirationCard(data: inspirationData[0]!)
            
            cards += [feedInspiration]
        }
        
        feedState.feedCards = cards
        
        return feedState
    }
    
    private func initFeedCard(feedData: FeedsQuery.Data.Feed.Datum) -> FeedCardState {
        var feedCard = FeedCardState()
        feedCard.cardID = feedData.id
        feedCard.createTime = feedData.createTime
        feedCard.cursor = feedData.cursor
        feedCard.createTime = feedData.createTime
        feedCard.type = feedData.type
        feedCard.source = self.initFeedCardSource(feedSource: feedData.source!)
        feedCard.content = self.initFeedCardContent(feedContent: feedData.content!, cardID: feedData.id!)
        
        return feedCard
    }
    
    private func initFeedInspirationCard(data: FeedsQuery.Data.Inspiration.Datum) -> FeedCardState {
        var inspirationCard = FeedCardState()
        
        inspirationCard.inspiration = FeedInspirationState(data: data)
        
        return inspirationCard
    }
    
    private func initFeedCardSource(feedSource: FeedsQuery.Data.Feed.Datum.Source) -> FeedCardSourceState {
        var source = FeedCardSourceState()
        source.type = feedSource.type!
        
        if let shop = feedSource.shop {
            source.shopState = self.initFeedCardShop(feedShop: shop)
        } else {
            source.fromTokopedia = true
        }
        
        return source
    }
    
    private func initFeedCardShop(feedShop: FeedsQuery.Data.Feed.Datum.Source.Shop) -> FeedCardShopState {
        var shop = FeedCardShopState()
        shop.shopName = NSString.convertHTML(feedShop.name!)
        shop.shopImage = feedShop.avatar!
        shop.shopIsGold = feedShop.isGold!
        shop.shopIsOfficial = feedShop.isOfficial!
        shop.shopURL = feedShop.shopLink!
        shop.shareURL = feedShop.shareLinkUrl!
        shop.shareDescription = NSString.convertHTML(feedShop.shareLinkDescription!)
        
        return shop
    }
    
    private func initFeedCardContent(feedContent: FeedsQuery.Data.Feed.Datum.Content, cardID: String) -> FeedCardContentState {
        var content = FeedCardContentState()
        
        if feedContent.type == "promotion" {
            content.type = .promotion
            
            var promotionArray: [FeedCardPromotionState] = []
            
            feedContent.promotions?.forEach({ promotion in
                var promotionState = self.initFeedPromotion(promotion: promotion!)
                
                if feedContent.promotions?.count == 1 {
                    promotionState.isSinglePromotion = true
                }
                
                promotionArray += [promotionState]
            })
            
            content.promotion = promotionArray
        } else if feedContent.type == "new_product" {
            content.type = .newProduct
            
            guard let products = feedContent.products else { return FeedCardContentState() }
            
            let productArray: [FeedCardProductState] = products.enumerated().map { index, product in
                var productState = self.initFeedProduct(feedProduct: product!, cardID: cardID)
                
                if products.count > 6 && index == 5 {
                    productState.isMore = true
                    productState.remaining = feedContent.totalProduct! - 5
                }
                
                if feedContent.totalProduct == 1 {
                    productState.isLargeCell = true
                }
                
                return productState
            }
            
            content.product = productArray
            content.totalProduct = feedContent.totalProduct!
            content.activity = FeedCardActivityState(statusActivity: feedContent.newStatusActivity!)
        } else if feedContent.type == "toppick" {
            content.type = .toppicks
            
            guard let toppicks = feedContent.topPicks else { return FeedCardContentState() }
            
            content.toppicks = toppicks.map { item in
                return FeedCardToppicksState(toppick: item!)
            }
            
            if (content.oniPad && content.toppicks?.count != 5) || (!content.oniPad && content.toppicks?.count != 4) {
                content.type = .invalid
            }            
        } else if feedContent.type == "official_store_brand" || feedContent.type == "official_store_campaign" {
            content.type = (feedContent.type == "official_store_brand") ? .officialStoreBrand : .officialStoreCampaign
            content.redirectURL = feedContent.redirectUrlApp ?? "tokopedia://official-store/mobile"
            
            if let officialStores = feedContent.officialStore {
                content.officialStore = officialStores.map { officialStore in
                    let store = FeedCardOfficialStoreState(data: officialStore!, redirectURL: officialStore?.redirectUrlApp ?? "tokopedia://official-store/mobile")
                    
                    if store.incomplete {
                        content.type = .invalid
                    }
                    
                    return store
                }
            }
        } else {
            content.type = .notHandled
        }
        
        return content
    }
    
    private func initFeedPromotion(promotion: FeedsQuery.Data.Feed.Datum.Content.Promotion) -> FeedCardPromotionState {
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
        
        return promo
    }
    
    private func initFeedProduct(feedProduct: FeedsQuery.Data.Feed.Datum.Content.Product, cardID: String) -> FeedCardProductState {
        var product = FeedCardProductState()
        
        product.productID = "\(feedProduct.id!)"
        product.productName = feedProduct.name!
        product.productRating = feedProduct.rating!
        product.productCashback = feedProduct.cashback!
        product.productWholesale = (feedProduct.wholesale?.count == 0)
        product.productPrice = feedProduct.price!
        product.productImageSmall = feedProduct.image!
        product.productImageLarge = feedProduct.imageSingle!
        product.productFreeReturns = feedProduct.freereturns!
        product.productWishlisted = feedProduct.wishlist!
        product.productPreorder = feedProduct.preorder!
        product.productURL = feedProduct.productLink!
        product.cardID = cardID
        
        return product
    }
}
