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
    case newProduct
    case editProduct
    case promotion
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
    
    init() { }
    
    init(data: FeedsQuery.Data.Inspiration.Datum) {
        self.title = data.title!
        
        var productArray: [FeedCardProductState] = []
        
        data.recommendation!.map { product in
            var productState = FeedCardProductState(recommendationProduct: product!)
            productState.recommendationProductSource = data.source!
            
            productArray += [productState]
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
}

struct FeedCardActivityState: Render.StateType, ReSwift.StateType {
    var source = ""
    var activity = ""
    var amount = 0
    
    init() { }
    
    init(statusActivity: FeedsQuery.Data.Feed.Datum.Content.NewStatusActivity) {
        self.source = NSString.convertHTML(statusActivity.source!)
        self.activity = statusActivity.activity!
        self.amount = statusActivity.amount!
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
    
    init() { }
    
    init(recommendationProduct: FeedsQuery.Data.Inspiration.Datum.Recommendation) {
        self.productName = recommendationProduct.name!
        self.productPrice = recommendationProduct.price!
        self.productImageSmall = recommendationProduct.imageUrl!
        self.productURL = recommendationProduct.appUrl!
        self.isRecommendationProduct = true
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

class FeedStateManager: NSObject {
    func initFeedState(queryResult: FeedsQuery.Data?) -> FeedState {
        guard let `queryResult` = queryResult else { return FeedState() }
        
        var feedState = FeedState()
        feedState.totalData = queryResult.feed?.meta?.totalData ?? 0
        feedState.hasNextPage = (queryResult.feed?.links?.pagination?.hasNextPage)!
        
        if feedState.hasNextPage {
            let dataSize = queryResult.feed?.data?.count
            feedState.cursor = (queryResult.feed?.data?[dataSize! - 1]?.cursor)!
        }
        
        var cards: [FeedCardState] = []
        
        queryResult.feed?.data?.forEach({ card in
            let feedCard = self.initFeedCard(feedData: card!)
            cards += [feedCard]
        })
        
        var inspirationAmountIsCorrect = false
        
        if let recommendationCount = queryResult.inspiration?.data?[0]?.recommendation?.count, (feedState.oniPad && recommendationCount == 6) || (!feedState.oniPad && recommendationCount == 4) {
            inspirationAmountIsCorrect = true
        }
        
        if inspirationAmountIsCorrect {
            let feedInspiration = self.initFeedInspirationCard(data: (queryResult.inspiration?.data?[0])!)
            
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
            
            let productArray: [FeedCardProductState] = products.enumerated().map { (index, product) in
                var productState = self.initFeedProduct(feedProduct: product!, cardID: cardID)
                
                if ((feedContent.products?.count)! > 6) && (index == 5) {
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
