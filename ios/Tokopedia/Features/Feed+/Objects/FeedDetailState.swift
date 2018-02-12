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
    var page = 0
    var row = 0
    
    init() { }
    
    init(queryResult: FeedDetailQuery.Data) {
        if let feed = queryResult.feed, let feedData = feed.data {
            if feedData.count == 0 {
                self.isEmpty = true
            } else {
                if let data = feedData[0], let meta = data.meta, let source = data.source, let content = data.content {
                    self.createTime = data.createTime ?? ""
                    self.hasNextPage = meta.hasNextPage ?? false
                    self.source = FeedDetailSourceState(source: source)
                    self.content = FeedDetailContentState(content: content)
                }
            }
        }
    }
}

struct FeedDetailSourceState: Render.StateType {
    let oniPad = (UI_USER_INTERFACE_IDIOM() == .pad)
    var shopState = FeedDetailShopState()
    
    init() {}
    
    init(source: FeedDetailQuery.Data.Feed.Datum.Source) {
        if let shop = source.shop {
            self.shopState = FeedDetailShopState(shop: shop)
        }
    }
}

struct FeedDetailContentState: Render.StateType {
    let oniPad = (UI_USER_INTERFACE_IDIOM() == .pad)
    var type: FeedContentType = .newProduct
    var totalProduct = 0
    var product: [FeedDetailProductState] = []
    var activity = FeedDetailActivityState()
    
    init() {}
    
    init(content: FeedDetailQuery.Data.Feed.Datum.Content) {
        if let products = content.products {
            self.product = products.map { product in
                if let product = product {
                    return FeedDetailProductState(product: product)
                }
                
                return FeedDetailProductState()
            }
        }
        
        self.totalProduct = content.totalProduct ?? 0
        
        if let activity = content.newStatusActivity {
            self.activity = FeedDetailActivityState(statusActivity: activity)
        }
        
    }
}

struct FeedDetailActivityState: Render.StateType {
    var source = ""
    var activity = ""
    var amount = 0
    
    init() {}
    
    init(statusActivity: FeedDetailQuery.Data.Feed.Datum.Content.NewStatusActivity) {
        self.source = NSString.convertHTML(statusActivity.source ?? "")
        self.activity = statusActivity.activity ?? ""
        self.amount = statusActivity.amount ?? 0
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
    
    init() {}
    
    init(shop: FeedDetailQuery.Data.Feed.Datum.Source.Shop) {
        self.shopID = shop.id ?? 0
        self.shopName = NSString.convertHTML(shop.name ?? "")
        self.shopImage = shop.avatar ?? ""
        self.shopIsGold = shop.isGold ?? false
        self.shopIsOfficial = shop.isOfficial ?? false
        self.shopURL = shop.shopLink ?? ""
        self.shareURL = shop.shareLinkUrl ?? ""
        self.shareDescription = NSString.convertHTML(shop.shareLinkDescription ?? "")
    }
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
    var page = 0
    var row = 0
    
    init() {}
    
    init(product: FeedDetailQuery.Data.Feed.Datum.Content.Product) {
        self.productID = "\(product.id ?? 0)"
        self.productName = product.name ?? ""
        self.productRating = Int(product.rating ?? 0)
        self.productCashback = product.cashback ?? ""
        
        if let wholesale = product.wholesale, wholesale.count > 0 {
            self.productWholesale = true
        }
        
        self.productPrice = product.price ?? ""
        self.productImage = product.image ?? ""
        self.productFreeReturns = product.freereturns ?? false
        self.productWishlisted = product.wishlist ?? false
        self.productPreorder = product.preorder ?? false
        self.productURL = product.productLink ?? ""
    }
}
