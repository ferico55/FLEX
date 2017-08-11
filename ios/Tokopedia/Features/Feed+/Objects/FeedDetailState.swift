//
//  FeedDetailState.swift
//  Tokopedia
//
//  Created by Kenneth Vincent on 5/10/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

import UIKit
import Foundation
import Render
import Apollo

struct FeedDetailState: Render.StateType {
    let oniPad = (UI_USER_INTERFACE_IDIOM() == .pad)
    
    var hasNextPage = false
    var totalData = 0
    var source = FeedDetailSourceState()
    var content = FeedDetailContentState()
    var createTime = ""
    var isEmpty = false
}

struct FeedDetailSourceState: Render.StateType {
    let oniPad = (UI_USER_INTERFACE_IDIOM() == .pad)
    var type = 0
    var shopState = FeedDetailShopState()
}

struct FeedDetailContentState: Render.StateType {
    let oniPad = (UI_USER_INTERFACE_IDIOM() == .pad)
    var type: FeedContentType = .newProduct
    var totalProduct: Int! = 0
    var product: [FeedDetailProductState] = []
    var activity = FeedDetailActivityState()
}

struct FeedDetailActivityState: Render.StateType {
    var source = ""
    var activity = ""
    var amount = 0
    
    init() {}
    
    init(statusActivity: FeedDetailQuery.Data.Feed.Datum.Content.NewStatusActivity) {
        self.source = NSString.convertHTML(statusActivity.source!)
        self.activity = statusActivity.activity!
        self.amount = statusActivity.amount!
    }
}

struct FeedDetailShopState: Render.StateType {
    let oniPad = (UI_USER_INTERFACE_IDIOM() == .pad)
    
    var shopID = 0
    var shopName = ""
    var shopImage = ""
    var shopIsGold = false
    var shopIsOfficial = false
    var shopURL = ""
    var shareURL = ""
    var shareDescription = ""
}

struct FeedDetailProductState: Render.StateType {
    let oniPad = (UI_USER_INTERFACE_IDIOM() == .pad)
    
    var productID = ""
    var productName = ""
    var productImage = ""
    var productURL = ""
    var productPrice = ""
    var productRating = 0
    var productWholesale = false
    var productFreeReturns = false
    var productPreorder = false
    var productCashback = ""
    var productWishlisted = false
}

class FeedDetailStateManager: NSObject {
    class func initFeedDetailState(with queryResult: FeedDetailQuery.Data) -> FeedDetailState {
        var feedDetailState = FeedDetailState()
        
        if queryResult.feed?.data?.count == 0 {
            feedDetailState.isEmpty = true
            
            return feedDetailState
        }
        
        feedDetailState.source = self.initFeedDetailSource(with: (queryResult.feed?.data?[0]?.source)!)
        feedDetailState.content = self.initFeedDetailContent(with: (queryResult.feed?.data?[0]?.content)!)
        feedDetailState.createTime = (queryResult.feed?.data?[0]?.createTime)!
        feedDetailState.hasNextPage = (queryResult.feed?.data?[0]?.meta?.hasNextPage)!
        
        return feedDetailState
    }
    
    private class func initFeedDetailSource(with feedSource: FeedDetailQuery.Data.Feed.Datum.Source) -> FeedDetailSourceState {
        var source = FeedDetailSourceState()
        source.shopState = self.initFeedShop(with: feedSource.shop!)
        
        return source
    }
    
    private class func initFeedDetailContent(with feedContent: FeedDetailQuery.Data.Feed.Datum.Content) -> FeedDetailContentState {
        var content = FeedDetailContentState()
        
        var productArray: [FeedDetailProductState] = []
        
        for (_, product) in (feedContent.products?.enumerated())! {
            let productState = self.initFeedProduct(with: product!)
            
            productArray += [productState]
        }
        
        content.product = productArray
        content.totalProduct = feedContent.totalProduct
        content.activity = FeedDetailActivityState(statusActivity: feedContent.newStatusActivity!)
        
        return content
    }
    
    private class func initFeedShop(with feedShop: FeedDetailQuery.Data.Feed.Datum.Source.Shop) -> FeedDetailShopState {
        var shop = FeedDetailShopState()
        
        shop.shopID = feedShop.id!
        shop.shopName = NSString.convertHTML(feedShop.name!)
        shop.shopImage = feedShop.avatar!
        shop.shopIsGold = feedShop.isGold!
        shop.shopIsOfficial = feedShop.isOfficial!
        shop.shopURL = feedShop.shopLink!
        shop.shareURL = feedShop.shareLinkUrl!
        shop.shareDescription = NSString.convertHTML(feedShop.shareLinkDescription!)
        
        return shop
    }
    
    private class func initFeedProduct(with feedProduct: FeedDetailQuery.Data.Feed.Datum.Content.Product) -> FeedDetailProductState {
        var product = FeedDetailProductState()
        
        product.productID = "\(feedProduct.id!)"
        product.productName = feedProduct.name!
        product.productRating = feedProduct.rating!
        product.productCashback = feedProduct.cashback!
        product.productWholesale = ((feedProduct.wholesale?.count)! > 0)
        product.productPrice = feedProduct.price!
        product.productImage = feedProduct.image!
        product.productFreeReturns = feedProduct.freereturns!
        product.productWishlisted = feedProduct.wishlist!
        product.productPreorder = feedProduct.preorder!
        product.productURL = feedProduct.productLink!
        
        return product
    }
    
}
