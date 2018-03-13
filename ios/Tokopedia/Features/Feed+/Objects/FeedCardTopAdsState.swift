//
//  FeedCardTopAdsState.swift
//  Tokopedia
//
//  Created by Kenneth Vincent on 1/30/18.
//  Copyright © 2018 TOKOPEDIA. All rights reserved.
//

import Render
import ReSwift
import UIKit

internal enum TopAdsDataValidity {
    case valid
    case invalid
}

internal struct FeedCardTopAdsState: Render.StateType, ReSwift.StateType {
    internal let onPad = (UI_USER_INTERFACE_IDIOM() == .pad)
    internal var products: [FeedCardProductState] = []
    internal var shop = FeedTopAdsShopState()
    internal var validity: TopAdsDataValidity = .valid
    
    internal init() {}
    
    internal init(content: FeedsQuery.Data.Feed.Datum.Content) {
        guard let display = content.display, let data = content.topads, data.count > 0 else {
            self.validity = .invalid
            return
        }
        
        if display == "shop" {
            if let firstData = data.first, let topAds = firstData, let topAdsShop = topAds.shop, let urlString = topAds.applinks, let shopClickURL = topAds.shopClickUrl {
                self.shop = FeedTopAdsShopState(shop: topAdsShop, url: urlString, topAdsURL: shopClickURL)
                
                if self.shop.productImages.count != (self.onPad ? 5 : 3) {
                    self.validity = .invalid
                }
            } else {
                self.validity = .invalid
            }
        } else if display == "product" {
            self.products = data.map { topads in
                if let topAds = topads, let product = topAds.product, let urlString = topAds.applinks, let productClickURL = topAds.productClickUrl, let productImage = product.image {
                    return FeedCardProductState(topAdsProduct: product, url: urlString, topAdsProductClickURL: productClickURL, topAdsProductImpressionURL: productImage.sUrl)
                }
                
                self.validity = .invalid
                return FeedCardProductState()
            }
            
            if self.products.count != (self.onPad ? 6 : 4) {
                self.validity = .invalid
            }
        }
    }
}

internal struct FeedTopAdsShopState: Render.StateType, ReSwift.StateType {
    internal let onPad = (UI_USER_INTERFACE_IDIOM() == .pad)
    internal var shopID = "0"
    internal var shopImage = ""
    internal var shopName = ""
    internal var shopLocation = ""
    internal var shopURL = ""
    internal var topadsClickURL = ""
    internal var topadsImpressionURL = ""
    internal var productImages: [String] = []
    internal var isGoldMerchant = false
    internal var isFavoritedShop = false
    internal var buttonIsLoading = false
    internal init() {}
    
    internal init(shop: FeedsQuery.Data.Feed.Datum.Content.Topad.Shop, url: String, topAdsURL: String) {
        self.shopID = shop.id ?? "0"
        self.shopImage = shop.imageShop?.sEcs ?? ""
        self.shopName = NSAttributedString(fromHTML: shop.name ?? "").string
        self.shopLocation = shop.location ?? ""
        self.shopURL = url
        self.isGoldMerchant = shop.goldShop ?? false
        self.topadsClickURL = topAdsURL
        self.topadsImpressionURL = shop.imageShop?.sUrl ?? ""
        
        if let products = shop.imageProduct {
            self.productImages = products.map { product in
                if let product = product {
                    return product.imageUrl
                } else {
                    return ""
                }
            }
        }
    }
}
