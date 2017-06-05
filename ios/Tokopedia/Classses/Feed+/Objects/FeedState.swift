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
    var activity = ""
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
    var productID: Int! = 0
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
    func initFeedState(withResult queryResult: FeedsQuery.Data?) -> FeedState {
        guard let _ = queryResult else { return FeedState() }
        
        var feedState = FeedState()
        feedState.totalData = queryResult?.feed?.meta?.totalData ?? 0
        feedState.hasNextPage = (queryResult?.feed?.links?.pagination?.hasNextPage)!
        
        if feedState.hasNextPage {
            let dataSize = queryResult?.feed?.data?.count
            feedState.cursor = (queryResult?.feed?.data?[dataSize! - 1]?.cursor)!
        }
        
        var cards: [FeedCardState] = []
        
        queryResult?.feed?.data?.forEach({ card in
            let feedCard = self.initFeedCard(with: card!)
            cards += [feedCard]
        })
        
        feedState.feedCards = cards
        
        return feedState
    }
    
    private func initFeedCard(with feedData: FeedsQuery.Data.Feed.Datum) -> FeedCardState {
        var feedCard = FeedCardState()
        feedCard.cardID = feedData.id
        feedCard.createTime = feedData.createTime
        feedCard.cursor = feedData.cursor
        feedCard.createTime = feedData.createTime
        feedCard.type = feedData.type
        feedCard.source = self.initFeedCardSource(with: feedData.source!)
        feedCard.content = self.initFeedCardContent(with: feedData.content!, cardID: feedData.id!)
        
        return feedCard
    }
    
    private func initFeedCardSource(with feedSource: FeedsQuery.Data.Feed.Datum.Source) -> FeedCardSourceState {
        var source = FeedCardSourceState()
        source.type = feedSource.type!
        
        if feedSource.shop != nil {
            source.shopState = self.initFeedCardShop(with: feedSource.shop!)
        } else {
            source.fromTokopedia = true
        }
        
        return source
    }
    
    private func initFeedCardShop(with feedShop: FeedsQuery.Data.Feed.Datum.Source.Shop) -> FeedCardShopState {
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
    
    private func initFeedCardContent(with feedContent: FeedsQuery.Data.Feed.Datum.Content, cardID: String) -> FeedCardContentState {
        var content = FeedCardContentState()
        
        if feedContent.type == "promotion" {
            content.type = .promotion
            
            var promotionArray: [FeedCardPromotionState] = []
            
            feedContent.promotions?.forEach({ promotion in
                var promotionState = self.initFeedPromotion(with: promotion!)
                
                if feedContent.promotions?.count == 1 {
                    promotionState.isSinglePromotion = true
                }
                
                promotionArray += [promotionState]
            })
            
            content.promotion = promotionArray
        } else if feedContent.type == "new_product" {
            content.type = .newProduct
            
            var productArray: [FeedCardProductState] = []
            
            for (index, product) in (feedContent.products?.enumerated())! {
                var productState = self.initFeedProduct(with: product!, cardID: cardID)
                
                if ((feedContent.products?.count)! > 6) && (index == 5) {
                    productState.isMore = true
                    productState.remaining = feedContent.totalProduct! - 5
                }
                
                if feedContent.totalProduct == 1 {
                    productState.isLargeCell = true
                }
                
                productArray += [productState]
            }
            
            content.product = productArray
            content.totalProduct = feedContent.totalProduct!
            content.activity = feedContent.statusActivity!
        }
        
        return content
    }
    
    private func initFeedPromotion(with promotion: FeedsQuery.Data.Feed.Datum.Content.Promotion) -> FeedCardPromotionState {
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
    
    private func initFeedProduct(with feedProduct: FeedsQuery.Data.Feed.Datum.Content.Product, cardID: String) -> FeedCardProductState {
        var product = FeedCardProductState()
        
        product.productID = feedProduct.id
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
