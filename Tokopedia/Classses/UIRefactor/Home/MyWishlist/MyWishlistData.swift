//
//  MyWishlistData.swift
//  Tokopedia
//
//  Created by Billion Goenawan on 10/14/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

import Foundation

@objc(MyWishlistData)
class MyWishlistData: NSObject {
    var id: String!
    var name: String!
    var url: String!
    var image: String!
    var price: NSNumber!
    var price_formatted: String!
    var minimum_order: NSNumber!
    var wholesale_price: [MyWishlistWholesalePrice]!
    var condition: String!
    var shop: MyWishlistShop!
    var badges: [MyWishlistBadge]!
    var labels: [MyWishlistLabel]!
    var available: Bool = false
    var status: String!
    var preorder: Bool = false
    
    var productModelView: ProductModelView!
    
    class func mapping() -> RKObjectMapping {
        let mapping = RKObjectMapping(forClass: MyWishlistData.self)
        
        mapping.addAttributeMappingsFromArray(["id", "name", "url", "image", "price", "price_formatted", "minimum_order", "condition", "available", "status", "preorder"])
        mapping.addPropertyMapping(RKRelationshipMapping(fromKeyPath: "wholesale_price", toKeyPath: "wholesale_price", withMapping: MyWishlistWholesalePrice.mapping()))
        mapping.addPropertyMapping(RKRelationshipMapping(fromKeyPath: "shop", toKeyPath: "shop", withMapping: MyWishlistShop.mapping()))
        mapping.addPropertyMapping(RKRelationshipMapping(fromKeyPath: "badges", toKeyPath: "badges", withMapping: MyWishlistBadge.mapping()))
        mapping.addPropertyMapping(RKRelationshipMapping(fromKeyPath: "labels", toKeyPath: "labels", withMapping: MyWishlistLabel.mapping()))
        
        
        return mapping
    }
    
    func viewModel() -> ProductModelView {
        if self.productModelView == nil {
            let productModelView = ProductModelView()
            productModelView.productName = self.name
            productModelView.productPrice = NSNumberFormatter.IDRFormatter().stringFromNumber(self.price)
            productModelView.productShop = self.shop.name
            productModelView.productThumbUrl = self.image
            productModelView.isGoldShopProduct = self.shop.gold_merchant
            productModelView.isProductBuyAble = self.available
            
            var luckyMerchantImageURL = ""
            for badge: MyWishlistBadge in self.badges {
                if badge.title == "Lucky Merchant" {
                    luckyMerchantImageURL = badge.image_url
                }
            }
            productModelView.luckyMerchantImageURL = luckyMerchantImageURL
            
            var isProductWholesale = false
            if self.wholesale_price != nil {
                isProductWholesale = true
            }
            
            productModelView.isWholesale = isProductWholesale
            productModelView.isProductPreorder = self.preorder
            productModelView.shopLocation = self.shop.location
            productModelView.badges = self.badges
            productModelView.labels = self.labels
            
            self.productModelView = productModelView
        }
        
        return self.productModelView
    }

    func productFieldObjects() -> NSDictionary{
        let productFieldObjects = [
            "name" : self.name,
            "id" : self.id,
            "price" : self.price,
            "brand" : self.shop.name]
        return productFieldObjects
    }
}
